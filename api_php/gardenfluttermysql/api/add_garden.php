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
    // Find user in MySQL
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


    // -------------------------------------------------
    // User not found
    // -------------------------------------------------

    if (!$user) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'User not found in MySQL database.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Check Admin Role
    // -------------------------------------------------

    if ($user['role'] !== 'admin') {

        http_response_code(403);

        echo json_encode([
            'success' => false,
            'message' => 'Access denied. Admin privileges are required.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Get JSON request body
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
    // Validate garden name
    // -------------------------------------------------

    $gardenName = trim($input['garden_name'] ?? '');

    if ($gardenName === '') {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Garden name is required.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Insert Garden
    // -------------------------------------------------

    $sql = "
        INSERT INTO gardens (garden_name)
        VALUES (:garden_name)
    ";

    $stmt = $conn->prepare($sql);

    $stmt->execute([
        ':garden_name' => $gardenName
    ]);


    // -------------------------------------------------
    // Get newly created Garden ID
    // -------------------------------------------------

    $gardenId = $conn->lastInsertId();


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Garden added successfully.',
        'data' => [
            'id' => (int) $gardenId,
            'garden_name' => $gardenName
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