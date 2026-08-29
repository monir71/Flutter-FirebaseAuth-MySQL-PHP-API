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

    $incomeId =
        $input['income_id'] ?? null;


    // Validate income ID
    if (!$incomeId) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Income ID is required.',
        ]);

        exit;
    }


    // Check income exists
    $stmt = $conn->prepare(
        'SELECT income_id
         FROM incomes
         WHERE income_id = :income_id
         LIMIT 1'
    );

    $stmt->execute([
        ':income_id' => $incomeId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Income not found.',
        ]);

        exit;
    }


    // Delete income
    $stmt = $conn->prepare(
        'DELETE FROM incomes
         WHERE income_id = :income_id'
    );

    $stmt->execute([
        ':income_id' => $incomeId,
    ]);


    echo json_encode([
        'success' => true,
        'message' =>
            'Income deleted successfully.',
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