<?php

header('Content-Type: application/json');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // -------------------------------------------------
    // Require authenticated Firebase user
    // -------------------------------------------------

    $user = requireAuthenticatedUser();

    // -------------------------------------------------
    // Get all gardens
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'SELECT
            garden_id,
            garden_name

         FROM gardens

         ORDER BY garden_id DESC'
    );

    $stmt->execute();

    $gardens = $stmt->fetchAll();

    // -------------------------------------------------
    // Prepare garden dashboard data
    // -------------------------------------------------

    $dashboardGardens = [];

    foreach ($gardens as $garden) {

        $gardenId = (int) $garden['garden_id'];


        // =================================================
        // OWNER COUNT
        // =================================================

        $stmt = $conn->prepare(
            'SELECT COUNT(*)
             FROM garden_owners
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $ownerCount = (int) $stmt->fetchColumn();


        // =================================================
        // TOTAL FUND
        // =================================================

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(fund_amount), 0)
             FROM funds
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $fundTotal = $stmt->fetchColumn();


        // =================================================
        // TOTAL EXPENSE
        // =================================================

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(expense_amount), 0)
             FROM expenses
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $expenseTotal = $stmt->fetchColumn();


        // =================================================
        // TOTAL INCOME
        // =================================================

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(income_amount), 0)
             FROM incomes
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $incomeTotal = $stmt->fetchColumn();


        // =================================================
        // TOTAL LOAN
        // =================================================

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(loan_amount), 0)
             FROM loans
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $loanTotal = $stmt->fetchColumn();


        // =================================================
        // BUILD GARDEN DATA
        // =================================================

        $dashboardGardens[] = [

            'garden_id' =>
                $gardenId,

            'garden_name' =>
                $garden['garden_name'],

            'owner_count' =>
                $ownerCount,

            'summary' => [

                'fund_total' =>
                    number_format(
                        (float) $fundTotal,
                        2,
                        '.',
                        ''
                    ),

                'expense_total' =>
                    number_format(
                        (float) $expenseTotal,
                        2,
                        '.',
                        ''
                    ),

                'income_total' =>
                    number_format(
                        (float) $incomeTotal,
                        2,
                        '.',
                        ''
                    ),

                'loan_total' =>
                    number_format(
                        (float) $loanTotal,
                        2,
                        '.',
                        ''
                    ),
            ],
        ];
    }


    // -------------------------------------------------
    // Return data
    // -------------------------------------------------

    echo json_encode([

        'success' => true,

        'message' =>
            'Admin garden data retrieved successfully.',

        'data' =>
            $dashboardGardens,
    ]);


} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([

        'success' => false,

        'message' =>
            'Server error.',

        'error' =>
            $e->getMessage(),
    ]);
}