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
    // Get owners, linked users and their gardens
    // -------------------------------------------------

    $sql = "
        SELECT
            o.owner_id,
            o.owner_name,

            o.user_id,

            u.username,
            u.email,

            g.garden_id,
            g.garden_name

        FROM owners o

        LEFT JOIN users u
            ON o.user_id = u.id

        LEFT JOIN garden_owners go
            ON o.owner_id = go.owner_id

        LEFT JOIN gardens g
            ON go.garden_id = g.garden_id

        ORDER BY
            o.owner_id ASC,
            g.garden_id ASC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);


    // -------------------------------------------------
    // Build owner list
    // -------------------------------------------------

    $owners = [];

    foreach ($rows as $row) {

        $ownerId = (int) $row['owner_id'];

        if (!isset($owners[$ownerId])) {

            $owners[$ownerId] = [
                'owner_id' => $ownerId,
                'owner_name' => $row['owner_name'],

                // -------------------------------------
                // Linked user information
                // -------------------------------------

                'user_id' => $row['user_id'] !== null
                    ? (int) $row['user_id']
                    : null,

                'username' => $row['username'] !== null
                    ? $row['username']
                    : null,

                'email' => $row['email'] !== null
                    ? $row['email']
                    : null,

                'gardens' => []
            ];
        }

        if ($row['garden_id'] !== null) {

            $owners[$ownerId]['gardens'][] = [
                'garden_id' => (int) $row['garden_id'],
                'garden_name' => $row['garden_name']
            ];
        }
    }


    // -------------------------------------------------
    // Success
    // -------------------------------------------------

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Owner list retrieved successfully.',
        'data' => array_values($owners)
    ]);

} catch (Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage()
    ]);
}