<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $conn = $GLOBALS['conn'];

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $ownerId = isset($input['owner_id'])
        ? (int) $input['owner_id']
        : 0;

    if ($ownerId <= 0) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Owner ID is required.',
        ]);

        exit;
    }

    // Check owner exists
    $stmt = $conn->prepare(
        'SELECT owner_id, owner_name, user_id
         FROM owners
         WHERE owner_id = ?'
    );

    $stmt->execute([$ownerId]);

    $owner = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$owner) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.',
        ]);

        exit;
    }

    if ($owner['user_id'] === null) {

        echo json_encode([
            'success' => true,
            'message' => 'No user is linked to this owner.',
            'data' => [
                'owner_id' => (int) $owner['owner_id'],
                'owner_name' => $owner['owner_name'],
                'user_id' => null,
            ],
        ]);

        exit;
    }

    // Remove user connection
    $stmt = $conn->prepare(
        'UPDATE owners
         SET user_id = NULL
         WHERE owner_id = ?'
    );

    $stmt->execute([$ownerId]);

    echo json_encode([
        'success' => true,
        'message' => 'User removed from owner successfully.',
        'data' => [
            'owner_id' => (int) $owner['owner_id'],
            'owner_name' => $owner['owner_name'],
            'user_id' => null,
        ],
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}