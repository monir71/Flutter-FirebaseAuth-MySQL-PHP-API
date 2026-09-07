<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // -------------------------------------------------
    // Require Admin
    // -------------------------------------------------

    requireAdmin();


    // -------------------------------------------------
    // Get Profit Transactions
    // -------------------------------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            pt.profit_transaction_id,

            pt.owner_id,
            o.owner_name,

            pt.garden_id,
            g.garden_name,

            pt.profit_amount,
            pt.profit_date,

            pt.status,

            pt.profit_note,
            pt.admin_note,

            pt.approved_by,
            au.username AS approved_by_name,
            pt.approved_at,

            pt.created_at

         FROM profit_transactions pt

         INNER JOIN owners o
            ON pt.owner_id = o.owner_id

         INNER JOIN gardens g
            ON pt.garden_id = g.garden_id

         LEFT JOIN users au
            ON pt.approved_by = au.id

         ORDER BY pt.profit_transaction_id DESC'
    );

    $stmt->execute();

    $profitTransactions = $stmt->fetchAll();


    // -------------------------------------------------
    // Return Response
    // -------------------------------------------------

    echo json_encode([
        'success' => true,
        'message' =>
            'Profit transactions retrieved successfully.',
        'data' =>
            $profitTransactions,
    ]);


} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}