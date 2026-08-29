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
    // Get Firebase user information
    // -------------------------------------------------

    $firebaseUid = $verifiedIdToken->claims()->get('sub');

    $email = $verifiedIdToken->claims()->get(
        'email',
        null
    );

    if (empty($firebaseUid) || empty($email)) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Firebase user information is incomplete.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Get Flutter request body
    // -------------------------------------------------

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $username = trim($input['username'] ?? '');


    if ($username === '') {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Username is required.'
        ]);

        exit;
    }


    // -------------------------------------------------
    // Check whether user already exists
    // -------------------------------------------------

    $sql = "
        SELECT
            id,
            firebase_uid,
            username,
            email,
            role,
            created_at
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
    // Existing user
    // -------------------------------------------------

    if ($user) {

        // Update username/email if necessary
        $updateSql = "
            UPDATE users
            SET
                username = :username,
                email = :email
            WHERE firebase_uid = :firebase_uid
        ";

        $updateStmt = $conn->prepare($updateSql);

        $updateStmt->execute([
            ':username' => $username,
            ':email' => $email,
            ':firebase_uid' => $firebaseUid
        ]);

        // Get updated user
        $stmt->execute([
            ':firebase_uid' => $firebaseUid
        ]);

        $user = $stmt->fetch();


        echo json_encode([
            'success' => true,
            'message' => 'User synchronized successfully.',
            'data' => $user
        ]);

        exit;
    }


    // -------------------------------------------------
    // New user
    // -------------------------------------------------

    $insertSql = "
        INSERT INTO users (
            firebase_uid,
            username,
            email,
            role
        )
        VALUES (
            :firebase_uid,
            :username,
            :email,
            'general'
        )
    ";

    $insertStmt = $conn->prepare($insertSql);

    $insertStmt->execute([
        ':firebase_uid' => $firebaseUid,
        ':username' => $username,
        ':email' => $email
    ]);


    // -------------------------------------------------
    // Get newly created user
    // -------------------------------------------------

    $userId = $conn->lastInsertId();

    $selectSql = "
        SELECT
            id,
            firebase_uid,
            username,
            email,
            role,
            created_at
        FROM users
        WHERE id = :id
        LIMIT 1
    ";

    $selectStmt = $conn->prepare($selectSql);

    $selectStmt->execute([
        ':id' => $userId
    ]);

    $user = $selectStmt->fetch();


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'User created successfully.',
        'data' => $user
    ]);

} catch (Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage()
    ]);
}