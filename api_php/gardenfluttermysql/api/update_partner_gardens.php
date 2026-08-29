<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $partnerId = $input['partner_id'] ?? null;
    $gardenIds = $input['garden_ids'] ?? [];

    if (!$partnerId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Partner ID is required.',
        ]);

        exit;
    }

    if (!is_array($gardenIds)) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Garden IDs must be an array.',
        ]);

        exit;
    }

    // Check partner exists
    $stmt = $GLOBALS['conn']->prepare(
        'SELECT partner_id
         FROM financial_partners
         WHERE partner_id = :partner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    if (!$stmt->fetch()) {
        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Financial partner not found.',
        ]);

        exit;
    }

    // Validate all gardens
    foreach ($gardenIds as $gardenId) {

        $stmt = $GLOBALS['conn']->prepare(
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
                'message' => "Garden ID $gardenId not found.",
            ]);

            exit;
        }
    }

    $conn = $GLOBALS['conn'];

    // Start transaction
    $conn->beginTransaction();

    // Remove existing assignments
    $stmt = $conn->prepare(
        'DELETE FROM partner_gardens
         WHERE partner_id = :partner_id'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    // Add new assignments
    if (!empty($gardenIds)) {

        $stmt = $conn->prepare(
            'INSERT INTO partner_gardens
                (partner_id, garden_id)
             VALUES
                (:partner_id, :garden_id)'
        );

        foreach ($gardenIds as $gardenId) {

            $stmt->execute([
                ':partner_id' => $partnerId,
                ':garden_id' => $gardenId,
            ]);
        }
    }

    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Partner gardens updated successfully.',
    ]);

} catch (\Throwable $e) {

    if (
        isset($conn) &&
        $conn->inTransaction()
    ) {
        $conn->rollBack();
    }

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}