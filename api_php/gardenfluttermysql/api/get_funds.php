<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            f.fund_id,
            f.owner_id,
            o.owner_name,
            f.garden_id,
            g.garden_name,
            f.fund_amount,
            f.fund_date,
            f.created_at
         FROM funds f
         INNER JOIN owners o
            ON f.owner_id = o.owner_id
         INNER JOIN gardens g
            ON f.garden_id = g.garden_id
         ORDER BY f.fund_id DESC'
    );

    $stmt->execute();

    $funds = $stmt->fetchAll();

    echo json_encode([
        'success' => true,
        'message' => 'Funds retrieved successfully.',
        'data' => $funds,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}