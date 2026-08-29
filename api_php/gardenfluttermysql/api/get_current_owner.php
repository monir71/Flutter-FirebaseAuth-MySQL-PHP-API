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
        SELECT
            id,
            firebase_uid,
            username,
            email,
            role
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
    // Find owner linked to this user
    // -------------------------------------------------

    $sql = "
        SELECT
            owner_id,
            owner_name,
            user_id,
            owner_photo,
            created_at
        FROM owners
        WHERE user_id = :user_id
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':user_id' => $user['id']
    ]);

    $owner = $stmt->fetch();


    // -------------------------------------------------
    // Owner not linked
    // -------------------------------------------------

    if (!$owner) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'No owner is linked to this user.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Current owner retrieved successfully.',
        'data' => [
            'owner_id' => (int)$owner['owner_id'],
            'owner_name' => $owner['owner_name'],
            'user_id' => (int)$user['id'],
            'firebase_uid' => $user['firebase_uid'],
            'email' => $user['email'],
            'role' => $user['role'],
            'owner_photo' => $owner['owner_photo'],
            'created_at' => $owner['created_at']
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