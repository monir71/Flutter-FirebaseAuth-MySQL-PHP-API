<?php

header('Content-Type: application/json');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // Require authenticated user
    $user = requireAuthenticatedUser();

    // Read JSON body
    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    if (!$input) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON data.',
        ]);

        exit;
    }

    $loanId =
        $input['loan_id'] ?? null;


    // Validate loan ID
    if (!$loanId) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' =>
                'Loan ID is required.',
        ]);

        exit;
    }


    // Check loan exists
    $stmt = $conn->prepare(
        'SELECT loan_id
         FROM loans
         WHERE loan_id = :loan_id
         LIMIT 1'
    );

    $stmt->execute([
        ':loan_id' => $loanId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Loan not found.',
        ]);

        exit;
    }


    // Delete loan
    $stmt = $conn->prepare(
        'DELETE FROM loans
         WHERE loan_id = :loan_id'
    );

    $stmt->execute([
        ':loan_id' => $loanId,
    ]);


    echo json_encode([
        'success' => true,

        'message' =>
            'Loan deleted successfully.',
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