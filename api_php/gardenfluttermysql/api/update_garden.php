<?php

require_once 'middleware/auth_middleware.php';

header('Content-Type: application/json');

try {

    // Only admin can update a garden
    $admin = requireAdmin();

    // Get JSON data
    $data = json_decode(
        file_get_contents('php://input'),
        true
    );

    $gardenId = $data['garden_id'] ?? null;
    $gardenName = trim($data['garden_name'] ?? '');

    if (!$gardenId) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Garden ID is required.',
        ]);

        exit;
    }

    if ($gardenName === '') {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Garden name is required.',
        ]);

        exit;
    }

    // Check garden exists
    $stmt = $conn->prepare(
        'SELECT garden_id
         FROM gardens
         WHERE garden_id = :garden_id
         LIMIT 1'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Garden not found.',
        ]);

        exit;
    }

    // Update garden
    $stmt = $conn->prepare(
        'UPDATE gardens
         SET garden_name = :garden_name
         WHERE garden_id = :garden_id'
    );

    $stmt->execute([
        ':garden_name' => $gardenName,
        ':garden_id' => $gardenId,
    ]);

    // Get updated garden
    $stmt = $conn->prepare(
        'SELECT
            garden_id,
            garden_name
         FROM gardens
         WHERE garden_id = :garden_id
         LIMIT 1'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    $garden = $stmt->fetch();

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Garden updated successfully.',
        'data' => $garden,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
    ]);
}