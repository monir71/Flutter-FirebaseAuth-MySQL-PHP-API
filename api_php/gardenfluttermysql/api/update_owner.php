<?php

require_once 'middleware/auth_middleware.php';

header('Content-Type: application/json');

try {

    // Only admin can update owner
    $admin = requireAdmin();

    // Get JSON data
    $data = json_decode(
        file_get_contents('php://input'),
        true
    );

    $ownerId = $data['owner_id'] ?? null;
    $ownerName = trim($data['owner_name'] ?? '');

    if (!$ownerId) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Owner ID is required.',
        ]);

        exit;
    }

    if ($ownerName === '') {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Owner name is required.',
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

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.',
        ]);

        exit;
    }

    // Update owner name
    $stmt = $conn->prepare(
        'UPDATE owners
         SET owner_name = :owner_name
         WHERE owner_id = :owner_id'
    );

    $stmt->execute([
        ':owner_name' => $ownerName,
        ':owner_id' => $ownerId,
    ]);

    // Get updated owner
    $stmt = $conn->prepare(
        'SELECT
            owner_id,
            owner_name
         FROM owners
         WHERE owner_id = :owner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    $owner = $stmt->fetch();

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Owner updated successfully.',
        'data' => $owner,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
    ]);
}