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

    $ownerId =
        $input['owner_id'] ?? null;

    $gardenId =
        $input['garden_id'] ?? null;

    $incomeSource =
        trim($input['income_source'] ?? '');

    $incomeAmount =
        $input['income_amount'] ?? null;

    $incomeDate =
        $input['income_date'] ?? null;


    // Validate required fields
    if (!$incomeId ||
        !$ownerId ||
        !$gardenId ||
        $incomeSource === '' ||
        $incomeAmount === null ||
        !$incomeDate) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'All income fields are required.',
        ]);

        exit;
    }


    // Validate amount
    if (!is_numeric($incomeAmount) ||
        $incomeAmount <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' =>
                'Income amount must be greater than zero.',
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


    // Check owner exists
    $stmt = $conn->prepare(
        'SELECT owner_id
         FROM owners
         WHERE owner_id = :owner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.',
        ]);

        exit;
    }


    // Check garden exists
    $stmt = $conn->prepare(
        'SELECT garden_id
         FROM gardens
         WHERE garden_id = :garden_id
         LIMIT 1'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Garden not found.',
        ]);

        exit;
    }


    // Update income
    $stmt = $conn->prepare(
        'UPDATE incomes
         SET
            owner_id = :owner_id,
            garden_id = :garden_id,
            income_source = :income_source,
            income_amount = :income_amount,
            income_date = :income_date
         WHERE income_id = :income_id'
    );

    $stmt->execute([
        ':owner_id' =>
            $ownerId,

        ':garden_id' =>
            $gardenId,

        ':income_source' =>
            $incomeSource,

        ':income_amount' =>
            $incomeAmount,

        ':income_date' =>
            $incomeDate,

        ':income_id' =>
            $incomeId,
    ]);


    echo json_encode([
        'success' => true,

        'message' =>
            'Income updated successfully.',

        'data' => [
            'income_id' =>
                (int) $incomeId,

            'owner_id' =>
                (int) $ownerId,

            'garden_id' =>
                (int) $gardenId,

            'income_source' =>
                $incomeSource,

            'income_amount' =>
                number_format(
                    (float) $incomeAmount,
                    2,
                    '.',
                    ''
                ),

            'income_date' =>
                $incomeDate,
        ],
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