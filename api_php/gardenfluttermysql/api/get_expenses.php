<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $stmt = $GLOBALS['conn']->query(
        'SELECT
            e.expense_id,
            e.owner_id,
            o.owner_name,
            e.garden_id,
            g.garden_name,
            e.expense_description,
            e.expense_amount,
            e.expense_date,
            e.created_at
        FROM expenses e
        INNER JOIN owners o
            ON e.owner_id = o.owner_id
        INNER JOIN gardens g
            ON e.garden_id = g.garden_id
        ORDER BY e.expense_id DESC'
    );

    $expenses = $stmt->fetchAll();

    echo json_encode([
        'success' => true,
        'message' => 'Expenses retrieved successfully.',
        'data' => $expenses,
    ]);

} catch (Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}