<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

$user = requireAdmin();

$data = json_decode(file_get_contents('php://input'), true);

$ownerId = $data['owner_id'] ?? null;
$gardenIds = $data['garden_ids'] ?? [];

if (!$ownerId) {
    http_response_code(422);

    echo json_encode([
        'success' => false,
        'message' => 'Owner ID is required.'
    ]);

    exit;
}

if (!is_array($gardenIds)) {
    http_response_code(422);

    echo json_encode([
        'success' => false,
        'message' => 'Garden IDs must be an array.'
    ]);

    exit;
}

try {

    $conn->beginTransaction();

    // Remove existing garden assignments
    $stmt = $conn->prepare(
        'DELETE FROM garden_owners
         WHERE owner_id = :owner_id'
    );

    $stmt->execute([
        ':owner_id' => $ownerId
    ]);


    // Add new garden assignments
    if (!empty($gardenIds)) {

        $stmt = $conn->prepare(
            'INSERT INTO garden_owners
             (owner_id, garden_id)
             VALUES (:owner_id, :garden_id)'
        );

        foreach ($gardenIds as $gardenId) {

            $stmt->execute([
                ':owner_id' => $ownerId,
                ':garden_id' => $gardenId
            ]);
        }
    }

    $conn->commit();

    http_response_code(200);

    echo json_encode([
        'success' => true,
        'message' => 'Owner gardens updated successfully.'
    ]);

} catch (Throwable $e) {

    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Unable to update owner gardens.'
    ]);
}