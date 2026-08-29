<?php

require_once 'middleware/auth_middleware.php';

header('Content-Type: application/json');

try {

    // Only admin can delete an owner
    $admin = requireAdmin();

    // Get JSON request
    $data = json_decode(
        file_get_contents('php://input'),
        true
    );

    $ownerId = $data['owner_id'] ?? null;

    if (!$ownerId) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Owner ID is required.',
        ]);

        exit;
    }

    // Check owner exists
    $stmt = $conn->prepare(
        'SELECT owner_id
         FROM owners
         WHERE owner_id = :owner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    $owner = $stmt->fetch();

    if (!$owner) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.',
        ]);

        exit;
    }

    // Delete owner
    $stmt = $conn->prepare(
        'DELETE FROM owners
         WHERE owner_id = :owner_id'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Owner deleted successfully.',
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
    ]);
}