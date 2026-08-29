<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

$user = requireAdmin();

$data = json_decode(file_get_contents('php://input'), true);

$gardenId = $data['garden_id'] ?? null;

if (!$gardenId) {
    http_response_code(422);

    echo json_encode([
        'success' => false,
        'message' => 'Garden ID is required.',
    ]);

    exit;
}

try {

    $stmt = $conn->prepare(
        'SELECT garden_id
         FROM gardens
         WHERE garden_id = :garden_id
         LIMIT 1'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    $garden = $stmt->fetch();

    if (!$garden) {
        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Garden not found.',
        ]);

        exit;
    }

    $stmt = $conn->prepare(
        'DELETE FROM gardens
         WHERE garden_id = :garden_id'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Garden deleted successfully.',
    ]);

} catch (Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Unable to delete garden.',
    ]);
}