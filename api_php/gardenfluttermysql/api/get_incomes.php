<?php

header('Content-Type: application/json');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // Require authenticated user
    $user = requireAuthenticatedUser();


    $stmt = $conn->prepare(
        'SELECT
            i.income_id,
            i.owner_id,
            o.owner_name,
            i.garden_id,
            g.garden_name,
            i.income_source,
            i.income_amount,
            i.income_date,
            i.created_at

         FROM incomes i

         INNER JOIN owners o
            ON i.owner_id = o.owner_id

         INNER JOIN gardens g
            ON i.garden_id = g.garden_id

         ORDER BY
            i.income_id DESC'
    );

    $stmt->execute();

    $incomes =
        $stmt->fetchAll();


    echo json_encode([
        'success' => true,

        'message' =>
            'Incomes retrieved successfully.',

        'data' => $incomes,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' =>
            $e->getMessage(),
    ]);
}