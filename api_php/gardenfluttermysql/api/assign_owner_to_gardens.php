<?php

require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/config/database.php';

use Kreait\Firebase\Factory;

header('Content-Type: application/json');

try {

    // -------------------------------------------------
    // Firebase Admin SDK
    // -------------------------------------------------

    $factory = (new Factory)
        ->withServiceAccount(
            'C:/xampp/firebase_credentials/nhgarden-ae870-firebase-adminsdk-fbsvc-8fc3c3fb7c.json'
        );

    $auth = $factory->createAuth();


    // -------------------------------------------------
    // Get Authorization header
    // -------------------------------------------------

    $authorizationHeader = '';

    if (!empty($_SERVER['HTTP_AUTHORIZATION'])) {
        $authorizationHeader = $_SERVER['HTTP_AUTHORIZATION'];
    }

    if (
        empty($authorizationHeader) &&
        function_exists('getallheaders')
    ) {
        $headers = getallheaders();

        if (!empty($headers['Authorization'])) {
            $authorizationHeader = $headers['Authorization'];
        }

        if (
            empty($authorizationHeader) &&
            !empty($headers['authorization'])
        ) {
            $authorizationHeader = $headers['authorization'];
        }
    }


    // -------------------------------------------------
    // Check Authorization header
    // -------------------------------------------------

    if (empty($authorizationHeader)) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Authorization header is missing.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Extract Bearer token
    // -------------------------------------------------

    if (!preg_match(
        '/Bearer\s+(.+)$/i',
        $authorizationHeader,
        $matches
    )) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Invalid Authorization header format.'
        ]);

        exit;
    }

    $idToken = trim($matches[1]);


    // -------------------------------------------------
    // Verify Firebase ID token
    // -------------------------------------------------

    $verifiedIdToken = $auth->verifyIdToken($idToken);


    // -------------------------------------------------
    // Get Firebase UID
    // -------------------------------------------------

    $firebaseUid = $verifiedIdToken->claims()->get('sub');

    if (empty($firebaseUid)) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Firebase UID not found.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Find logged-in user
    // -------------------------------------------------

    $sql = "
        SELECT id, role
        FROM users
        WHERE firebase_uid = :firebase_uid
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':firebase_uid' => $firebaseUid
    ]);

    $user = $stmt->fetch();


    if (!$user) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'User not found in MySQL database.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Admin-only operation
    // -------------------------------------------------

    if ($user['role'] !== 'admin') {

        http_response_code(403);

        echo json_encode([
            'success' => false,
            'message' => 'Only admin users can assign owners to gardens.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Read JSON request body
    // -------------------------------------------------

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );


    // -------------------------------------------------
    // Validate owner_id
    // -------------------------------------------------

    if (
        !isset($input['owner_id']) ||
        !is_numeric($input['owner_id'])
    ) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Owner ID is required.'
        ]);

        exit;
    }

    $ownerId = (int)$input['owner_id'];


    // -------------------------------------------------
    // Validate garden_ids
    // -------------------------------------------------

    if (
        !isset($input['garden_ids']) ||
        !is_array($input['garden_ids']) ||
        count($input['garden_ids']) === 0
    ) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'At least one garden ID is required.'
        ]);

        exit;
    }


    $gardenIds = array_map(
        'intval',
        $input['garden_ids']
    );

    $gardenIds = array_unique($gardenIds);


    // -------------------------------------------------
    // Check owner exists
    // -------------------------------------------------

    $stmt = $conn->prepare("
        SELECT owner_id, owner_name
        FROM owners
        WHERE owner_id = :owner_id
        LIMIT 1
    ");

    $stmt->execute([
        ':owner_id' => $ownerId
    ]);

    $owner = $stmt->fetch();


    if (!$owner) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Begin transaction
    // -------------------------------------------------

    $conn->beginTransaction();


    $inserted = 0;
    $alreadyAssigned = 0;


    // -------------------------------------------------
    // Insert relationships
    // -------------------------------------------------

    $checkStmt = $conn->prepare("
        SELECT id
        FROM garden_owners
        WHERE garden_id = :garden_id
        AND owner_id = :owner_id
        LIMIT 1
    ");

    $insertStmt = $conn->prepare("
        INSERT INTO garden_owners
        (garden_id, owner_id)
        VALUES
        (:garden_id, :owner_id)
    ");


    foreach ($gardenIds as $gardenId) {

        // ---------------------------------------------
        // Check garden exists
        // ---------------------------------------------

        $gardenStmt = $conn->prepare("
            SELECT garden_id, garden_name
            FROM gardens
            WHERE garden_id = :garden_id
            LIMIT 1
        ");

        $gardenStmt->execute([
            ':garden_id' => $gardenId
        ]);

        $garden = $gardenStmt->fetch();


        if (!$garden) {

            $conn->rollBack();

            http_response_code(404);

            echo json_encode([
                'success' => false,
                'message' => "Garden ID {$gardenId} not found."
            ]);

            exit;
        }


        // ---------------------------------------------
        // Check existing relationship
        // ---------------------------------------------

        $checkStmt->execute([
            ':garden_id' => $gardenId,
            ':owner_id' => $ownerId
        ]);

        $existing = $checkStmt->fetch();


        if ($existing) {

            $alreadyAssigned++;

            continue;
        }


        // ---------------------------------------------
        // Insert relationship
        // ---------------------------------------------

        $insertStmt->execute([
            ':garden_id' => $gardenId,
            ':owner_id' => $ownerId
        ]);

        $inserted++;
    }


    // -------------------------------------------------
    // Commit transaction
    // -------------------------------------------------

    $conn->commit();


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Owner garden assignment completed successfully.',
        'data' => [
            'owner_id' => $ownerId,
            'owner_name' => $owner['owner_name'],
            'inserted' => $inserted,
            'already_assigned' => $alreadyAssigned
        ]
    ]);

} catch (Throwable $e) {

    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage()
    ]);
}