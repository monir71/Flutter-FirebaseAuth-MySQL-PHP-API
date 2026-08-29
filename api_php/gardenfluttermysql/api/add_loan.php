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

    $partnerId =
        $input['partner_id'] ?? null;

    $gardenId =
        $input['garden_id'] ?? null;

    $loanPurpose =
        trim($input['loan_purpose'] ?? '');

    $loanAmount =
        $input['loan_amount'] ?? null;

    $loanDate =
        $input['loan_date'] ?? null;


    // Validate required fields
    if (!$partnerId ||
        !$gardenId ||
        $loanPurpose === '' ||
        $loanAmount === null ||
        !$loanDate) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'All loan fields are required.',
        ]);

        exit;
    }


    // Validate amount
    if (!is_numeric($loanAmount) ||
        $loanAmount <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' =>
                'Loan amount must be greater than zero.',
        ]);

        exit;
    }


    // Check financial partner
    $stmt = $conn->prepare(
        'SELECT partner_id
         FROM financial_partners
         WHERE partner_id = :partner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Financial partner not found.',
        ]);

        exit;
    }


    // Check garden
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


    // Insert loan
    $stmt = $conn->prepare(
        'INSERT INTO loans (
            partner_id,
            loan_purpose,
            garden_id,
            loan_amount,
            loan_date
         )
         VALUES (
            :partner_id,
            :loan_purpose,
            :garden_id,
            :loan_amount,
            :loan_date
         )'
    );

    $stmt->execute([
        ':partner_id' =>
            $partnerId,

        ':loan_purpose' =>
            $loanPurpose,

        ':garden_id' =>
            $gardenId,

        ':loan_amount' =>
            $loanAmount,

        ':loan_date' =>
            $loanDate,
    ]);


    $loanId =
        $conn->lastInsertId();


    echo json_encode([
        'success' => true,

        'message' =>
            'Loan created successfully.',

        'data' => [
            'loan_id' =>
                (int) $loanId,

            'partner_id' =>
                (int) $partnerId,

            'garden_id' =>
                (int) $gardenId,

            'loan_purpose' =>
                $loanPurpose,

            'loan_amount' =>
                number_format(
                    (float) $loanAmount,
                    2,
                    '.',
                    ''
                ),

            'loan_date' =>
                $loanDate,
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