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
    if (!$ownerId ||
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


    // Insert income
    $stmt = $conn->prepare(
        'INSERT INTO incomes (
            owner_id,
            garden_id,
            income_source,
            income_amount,
            income_date
         )
         VALUES (
            :owner_id,
            :garden_id,
            :income_source,
            :income_amount,
            :income_date
         )'
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
    ]);


    $incomeId =
        $conn->lastInsertId();


    echo json_encode([
        'success' => true,

        'message' =>
            'Income created successfully.',

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