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

    // Required fields
    $expenseId = $input['expense_id'] ?? null;
    $ownerId = $input['owner_id'] ?? null;
    $gardenId = $input['garden_id'] ?? null;
    $description = trim(
        $input['expense_description'] ?? ''
    );
    $amount = $input['expense_amount'] ?? null;
    $expenseDate = $input['expense_date'] ?? null;

    if (!$expenseId ||
        !$ownerId ||
        !$gardenId ||
        $description === '' ||
        $amount === null ||
        !$expenseDate) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'All expense fields are required.',
        ]);

        exit;
    }

    if (!is_numeric($amount) || $amount <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Expense amount must be greater than zero.',
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

    // Update expense
    $stmt = $conn->prepare(
        'UPDATE expenses
         SET
            owner_id = :owner_id,
            garden_id = :garden_id,
            expense_description = :expense_description,
            expense_amount = :expense_amount,
            expense_date = :expense_date
         WHERE expense_id = :expense_id'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
        ':garden_id' => $gardenId,
        ':expense_description' => $description,
        ':expense_amount' => $amount,
        ':expense_date' => $expenseDate,
        ':expense_id' => $expenseId,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Expense updated successfully.',
        'data' => [
            'expense_id' => (int) $expenseId,
            'owner_id' => (int) $ownerId,
            'garden_id' => (int) $gardenId,
            'expense_description' => $description,
            'expense_amount' => number_format(
                (float) $amount,
                2,
                '.',
                ''
            ),
            'expense_date' => $expenseDate,
        ],
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}