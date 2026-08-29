<?php

require __DIR__ . '/vendor/autoload.php';

use Kreait\Firebase\Factory;

header('Content-Type: application/json');

try {

    // Firebase Admin SDK
    $factory = (new Factory)
        ->withServiceAccount(
            'C:/xampp/firebase_credentials/nhgarden-ae870-firebase-adminsdk-fbsvc-8fc3c3fb7c.json'
        );

    $auth = $factory->createAuth();


    // -------------------------------------------------
    // Get Authorization header
    // -------------------------------------------------

    $authorizationHeader = '';

    // Method 1: Standard Apache/PHP variable
    if (!empty($_SERVER['HTTP_AUTHORIZATION'])) {
        $authorizationHeader = $_SERVER['HTTP_AUTHORIZATION'];
    }

    // Method 2: getallheaders()
    if (
        empty($authorizationHeader) &&
        function_exists('getallheaders')
    ) {
        $headers = getallheaders();

        if (!empty($headers['Authorization'])) {
            $authorizationHeader = $headers['Authorization'];
        }

        // Some servers may change the capitalization
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
    // Get Firebase claims
    // -------------------------------------------------

    $uid = $verifiedIdToken->claims()->get('sub');

    $email = $verifiedIdToken->claims()->get(
        'email',
        null
    );


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    echo json_encode([
        'success' => true,
        'message' => 'Firebase ID token verified successfully.',
        'data' => [
            'firebase_uid' => $uid,
            'email' => $email,
        ]
    ]);

} catch (Throwable $e) {

    http_response_code(401);

    echo json_encode([
        'success' => false,
        'message' => 'Invalid Firebase ID token.',
        'error' => $e->getMessage()
    ]);
}