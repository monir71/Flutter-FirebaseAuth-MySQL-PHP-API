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

    $expenseId =
        $input['expense_id'] ?? null;

    if (!$expenseId) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Expense ID is required.',
        ]);

        exit;
    }

    // Check expense exists
    $stmt = $conn->prepare(
        'SELECT expense_id
         FROM expenses
         WHERE expense_id = :expense_id
         LIMIT 1'
    );

    $stmt->execute([
        ':expense_id' => $expenseId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Expense not found.',
        ]);

        exit;
    }

    // Delete expense
    $stmt = $conn->prepare(
        'DELETE FROM expenses
         WHERE expense_id = :expense_id'
    );

    $stmt->execute([
        ':expense_id' => $expenseId,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Expense deleted successfully.',
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}