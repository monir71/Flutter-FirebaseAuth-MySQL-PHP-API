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
    // Find logged-in MySQL user
    // -------------------------------------------------

    $sql = "
        SELECT id, username, email, role
        FROM users
        WHERE firebase_uid = :firebase_uid
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':firebase_uid' => $firebaseUid
    ]);

    $admin = $stmt->fetch();


    if (!$admin) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Logged-in user not found in MySQL database.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Admin-only operation
    // -------------------------------------------------

    if ($admin['role'] !== 'admin') {

        http_response_code(403);

        echo json_encode([
            'success' => false,
            'message' => 'Only admin users can link owners to users.'
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


    if (!is_array($input)) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON request body.'
        ]);

        exit;
    }


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
            'message' => 'owner_id is required.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Validate user_id
    // -------------------------------------------------

    if (
        !isset($input['user_id']) ||
        !is_numeric($input['user_id'])
    ) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'user_id is required.'
        ]);

        exit;
    }


    $ownerId = (int)$input['owner_id'];
    $userId = (int)$input['user_id'];


    // -------------------------------------------------
    // Find owner
    // -------------------------------------------------

    $sql = "
        SELECT
            owner_id,
            owner_name,
            user_id
        FROM owners
        WHERE owner_id = :owner_id
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);

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
    // Find user
    // -------------------------------------------------

    $sql = "
        SELECT
            id,
            username,
            email,
            role
        FROM users
        WHERE id = :user_id
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':user_id' => $userId
    ]);

    $user = $stmt->fetch();


    if (!$user) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'User not found.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // User must be general
    // -------------------------------------------------

    if ($user['role'] !== 'general') {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Only general users can be linked to an owner.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Check whether this user is already linked
    // -------------------------------------------------

    $sql = "
        SELECT
            owner_id,
            owner_name
        FROM owners
        WHERE user_id = :user_id
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':user_id' => $userId
    ]);

    $existingOwner = $stmt->fetch();


    if ($existingOwner) {

        // If the user is already linked to this owner
        if ((int)$existingOwner['owner_id'] === $ownerId) {

            http_response_code(409);

            echo json_encode([
                'success' => false,
                'message' => 'This owner is already linked to this user.'
            ]);

            exit;
        }


        // User belongs to another owner
        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' => 'This user is already linked to another owner.',
            'data' => [
                'owner_id' => (int)$existingOwner['owner_id'],
                'owner_name' => $existingOwner['owner_name']
            ]
        ]);

        exit;
    }


    // -------------------------------------------------
    // Check whether owner is already linked
    // -------------------------------------------------

    if (!empty($owner['user_id'])) {

        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' => 'This owner is already linked to a user.',
            'data' => [
                'owner_id' => (int)$owner['owner_id'],
                'owner_name' => $owner['owner_name'],
                'user_id' => (int)$owner['user_id']
            ]
        ]);

        exit;
    }


    // -------------------------------------------------
    // Link owner with user
    // -------------------------------------------------

    $sql = "
        UPDATE owners
        SET user_id = :user_id
        WHERE owner_id = :owner_id
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':user_id' => $userId,
        ':owner_id' => $ownerId
    ]);


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Owner linked to user successfully.',
        'data' => [
            'owner_id' => (int)$owner['owner_id'],
            'owner_name' => $owner['owner_name'],
            'user_id' => (int)$user['id'],
            'username' => $user['username'],
            'email' => $user['email']
        ]
    ]);

} catch (Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage()
    ]);
}