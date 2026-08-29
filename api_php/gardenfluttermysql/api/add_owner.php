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
    // Check logged-in user in MySQL
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
            'message' => 'Only admin users can add owners.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Read JSON body
    // -------------------------------------------------

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );


    // -------------------------------------------------
    // Validate JSON
    // -------------------------------------------------

    if (!is_array($input)) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON request body.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Validate owner name
    // -------------------------------------------------

    if (
        !isset($input['owner_name']) ||
        trim($input['owner_name']) === ''
    ) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Owner name is required.'
        ]);

        exit;
    }

    $ownerName = trim($input['owner_name']);


    // -------------------------------------------------
    // Validate garden IDs
    // -------------------------------------------------

    if (
        !isset($input['garden_ids']) ||
        !is_array($input['garden_ids'])
    ) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'garden_ids must be an array.'
        ]);

        exit;
    }


    $gardenIds = $input['garden_ids'];


    if (count($gardenIds) === 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'At least one garden must be selected.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Clean and validate garden IDs
    // -------------------------------------------------

    $gardenIds = array_map('intval', $gardenIds);

    $gardenIds = array_values(
        array_unique($gardenIds)
    );


    foreach ($gardenIds as $gardenId) {

        if ($gardenId <= 0) {

            http_response_code(422);

            echo json_encode([
                'success' => false,
                'message' => 'Invalid garden ID.'
            ]);

            exit;
        }
    }


    // -------------------------------------------------
    // Verify that all gardens exist
    // -------------------------------------------------

    $placeholders = implode(
        ',',
        array_fill(0, count($gardenIds), '?')
    );

    $sql = "
        SELECT garden_id, garden_name
        FROM gardens
        WHERE garden_id IN ($placeholders)
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute($gardenIds);

    $gardens = $stmt->fetchAll(PDO::FETCH_ASSOC);


    if (count($gardens) !== count($gardenIds)) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'One or more selected gardens do not exist.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Start database transaction
    // -------------------------------------------------

    $conn->beginTransaction();


    // -------------------------------------------------
    // Insert owner
    // -------------------------------------------------

    $sql = "
        INSERT INTO owners (owner_name)
        VALUES (:owner_name)
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':owner_name' => $ownerName
    ]);


    // -------------------------------------------------
    // Get newly created owner ID
    // -------------------------------------------------

    $ownerId = (int)$conn->lastInsertId();


    // -------------------------------------------------
    // Assign owner to gardens
    // -------------------------------------------------

    $sql = "
        INSERT INTO garden_owners
        (garden_id, owner_id)
        VALUES (:garden_id, :owner_id)
    ";

    $stmt = $conn->prepare($sql);


    foreach ($gardenIds as $gardenId) {

        $stmt->execute([
            ':garden_id' => $gardenId,
            ':owner_id' => $ownerId
        ]);
    }


    // -------------------------------------------------
    // Commit transaction
    // -------------------------------------------------

    $conn->commit();


    // -------------------------------------------------
    // Success response
    // -------------------------------------------------

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Owner added successfully.',
        'data' => [
            'owner_id' => $ownerId,
            'owner_name' => $ownerName,
            'garden_ids' => $gardenIds,
            'gardens' => $gardens
        ]
    ]);


} catch (Throwable $e) {

    // -------------------------------------------------
    // Rollback transaction if necessary
    // -------------------------------------------------

    if (
        isset($conn) &&
        $conn->inTransaction()
    ) {
        $conn->rollBack();
    }


    // -------------------------------------------------
    // Server error
    // -------------------------------------------------

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage()
    ]);
}