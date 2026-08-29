<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    $user = requireAdmin();

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $ownerId = $input['owner_id'] ?? null;
    $gardenId = $input['garden_id'] ?? null;
    $description = trim(
        $input['expense_description'] ?? ''
    );
    $amount = $input['expense_amount'] ?? null;
    $date = $input['expense_date'] ?? null;

    if (!$ownerId ||
        !$gardenId ||
        $description === '' ||
        $amount === null ||
        !$date) {

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
            'message' => 'Invalid expense amount.',
        ]);

        exit;
    }

    $stmt = $GLOBALS['conn']->prepare(
        'INSERT INTO expenses
        (
            owner_id,
            garden_id,
            expense_description,
            expense_amount,
            expense_date
        )
        VALUES
        (
            :owner_id,
            :garden_id,
            :description,
            :amount,
            :expense_date
        )'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
        ':garden_id' => $gardenId,
        ':description' => $description,
        ':amount' => $amount,
        ':expense_date' => $date,
    ]);

    $expenseId =
        $GLOBALS['conn']->lastInsertId();

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Expense created successfully.',
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
            'expense_date' => $date,
        ],
    ]);

} catch (Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}