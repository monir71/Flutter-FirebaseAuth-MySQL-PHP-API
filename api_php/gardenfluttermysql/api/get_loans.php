<?php

header('Content-Type: application/json');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // Require authenticated user
    $user = requireAuthenticatedUser();


    $stmt = $conn->prepare(
        'SELECT
            l.loan_id,
            l.partner_id,
            fp.partner_name,
            fp.partner_institution,
            l.garden_id,
            g.garden_name,
            l.loan_purpose,
            l.loan_amount,
            l.loan_date,
            l.created_at

         FROM loans l

         INNER JOIN financial_partners fp
            ON l.partner_id = fp.partner_id

         INNER JOIN gardens g
            ON l.garden_id = g.garden_id

         ORDER BY l.loan_id DESC'
    );

    $stmt->execute();

    $loans = $stmt->fetchAll();


    echo json_encode([
        'success' => true,

        'message' =>
            'Loans retrieved successfully.',

        'data' => $loans,
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