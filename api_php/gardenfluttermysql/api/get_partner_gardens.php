<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $partnerId = $_GET['partner_id'] ?? null;

    if (!$partnerId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Partner ID is required.',
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

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            g.garden_id,
            g.garden_name
         FROM gardens g
         INNER JOIN partner_gardens pg
            ON g.garden_id = pg.garden_id
         WHERE pg.partner_id = :partner_id
         ORDER BY g.garden_id'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    $gardens = $stmt->fetchAll();

    echo json_encode([
        'success' => true,
        'message' => 'Partner gardens retrieved successfully.',
        'data' => $gardens,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}