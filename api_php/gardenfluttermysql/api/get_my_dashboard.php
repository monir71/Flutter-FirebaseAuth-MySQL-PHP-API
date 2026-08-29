<?php

header('Content-Type: application/json');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // -------------------------------------------------
    // Require authenticated Firebase user
    // -------------------------------------------------

    $user = requireAuthenticatedUser();

    $firebaseUid = $user['firebase_uid'] ?? null;

    if (!$firebaseUid) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Firebase UID not found.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Find Owner belonging to this user
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'SELECT
            o.owner_id,
            o.owner_name,
            o.owner_photo,
            o.created_at

         FROM owners o

         INNER JOIN users u
            ON o.user_id = u.id

         WHERE u.firebase_uid = :firebase_uid

         LIMIT 1'
    );

    $stmt->execute([
        ':firebase_uid' => $firebaseUid,
    ]);

    $owner = $stmt->fetch();


    if (!$owner) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner information not found.',
        ]);

        exit;
    }


    $ownerId = (int) $owner['owner_id'];


    // -------------------------------------------------
    // Find Owner's Gardens
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'SELECT
            g.garden_id,
            g.garden_name

         FROM garden_owners go

         INNER JOIN gardens g
            ON go.garden_id = g.garden_id

         WHERE go.owner_id = :owner_id

         ORDER BY g.garden_id DESC'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    $gardens = $stmt->fetchAll();


    // -------------------------------------------------
    // Prepare Dashboard Gardens
    // -------------------------------------------------

    $dashboardGardens = [];


    foreach ($gardens as $garden) {

        $gardenId = (int) $garden['garden_id'];


        // =================================================
        // SUMMARY
        // =================================================


        // -------------------------------------------------
        // Total Fund
        // -------------------------------------------------

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(fund_amount), 0)
             FROM funds
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $fundTotal = $stmt->fetchColumn();


        // -------------------------------------------------
        // Total Expense
        // -------------------------------------------------

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(expense_amount), 0)
             FROM expenses
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $expenseTotal = $stmt->fetchColumn();


        // -------------------------------------------------
        // Total Income
        // -------------------------------------------------

        $stmt = $conn->prepare(
            'SELECT COALESCE(SUM(income_amount), 0)
             FROM incomes
             WHERE garden_id = :garden_id'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $incomeTotal = $stmt->fetchColumn();


        // -------------------------------------------------
        // Total Loan
        // -------------------------------------------------

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
        // MY FUNDS
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                f.fund_id,
                f.owner_id,
                o.owner_name,
                f.fund_amount,
                f.fund_date,
                f.created_at

             FROM funds f

             INNER JOIN owners o
                ON f.owner_id = o.owner_id

             WHERE f.garden_id = :garden_id
               AND f.owner_id = :owner_id

             ORDER BY f.fund_date DESC,
                      f.fund_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
            ':owner_id' => $ownerId,
        ]);

        $myFunds = $stmt->fetchAll();


        // =================================================
        // MY EXPENSES
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                e.expense_id,
                e.owner_id,
                o.owner_name,
                e.expense_description,
                e.expense_amount,
                e.expense_date,
                e.created_at

             FROM expenses e

             INNER JOIN owners o
                ON e.owner_id = o.owner_id

             WHERE e.garden_id = :garden_id
               AND e.owner_id = :owner_id

             ORDER BY e.expense_date DESC,
                      e.expense_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
            ':owner_id' => $ownerId,
        ]);

        $myExpenses = $stmt->fetchAll();


        // =================================================
        // MY INCOME
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                i.income_id,
                i.owner_id,
                o.owner_name,
                i.income_source,
                i.income_amount,
                i.income_date,
                i.created_at

             FROM incomes i

             INNER JOIN owners o
                ON i.owner_id = o.owner_id

             WHERE i.garden_id = :garden_id
               AND i.owner_id = :owner_id

             ORDER BY i.income_date DESC,
                      i.income_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
            ':owner_id' => $ownerId,
        ]);

        $myIncomes = $stmt->fetchAll();


        // =================================================
        // ALL FUNDS
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                f.fund_id,
                f.owner_id,
                o.owner_name,
                f.fund_amount,
                f.fund_date,
                f.created_at

             FROM funds f

             INNER JOIN owners o
                ON f.owner_id = o.owner_id

             WHERE f.garden_id = :garden_id

             ORDER BY f.fund_date DESC,
                      f.fund_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $allFunds = $stmt->fetchAll();


        // =================================================
        // ALL EXPENSES
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                e.expense_id,
                e.owner_id,
                o.owner_name,
                e.expense_description,
                e.expense_amount,
                e.expense_date,
                e.created_at

             FROM expenses e

             INNER JOIN owners o
                ON e.owner_id = o.owner_id

             WHERE e.garden_id = :garden_id

             ORDER BY e.expense_date DESC,
                      e.expense_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $allExpenses = $stmt->fetchAll();


        // =================================================
        // ALL INCOME
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                i.income_id,
                i.owner_id,
                o.owner_name,
                i.income_source,
                i.income_amount,
                i.income_date,
                i.created_at

             FROM incomes i

             INNER JOIN owners o
                ON i.owner_id = o.owner_id

             WHERE i.garden_id = :garden_id

             ORDER BY i.income_date DESC,
                      i.income_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $allIncomes = $stmt->fetchAll();


        // =================================================
        // ALL LOANS
        // =================================================

        $stmt = $conn->prepare(
            'SELECT
                l.loan_id,
                l.partner_id,
                fp.partner_name,
                fp.partner_institution,
                l.garden_id,
                l.loan_purpose,
                l.loan_amount,
                l.loan_date,
                l.created_at

             FROM loans l

             INNER JOIN financial_partners fp
                ON l.partner_id = fp.partner_id

             WHERE l.garden_id = :garden_id

             ORDER BY l.loan_date DESC,
                      l.loan_id DESC'
        );

        $stmt->execute([
            ':garden_id' => $gardenId,
        ]);

        $allLoans = $stmt->fetchAll();


        // =================================================
        // Build Garden Dashboard
        // =================================================

        $dashboardGardens[] = [

            'garden_id' =>
                $gardenId,

            'garden_name' =>
                $garden['garden_name'],


            // -------------------------------------------------
            // Summary
            // -------------------------------------------------

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


            // -------------------------------------------------
            // My Transactions
            // -------------------------------------------------

            'my_funds' =>
                $myFunds,

            'my_expenses' =>
                $myExpenses,

            'my_incomes' =>
                $myIncomes,


            // -------------------------------------------------
            // All Transactions
            // -------------------------------------------------

            'all_funds' =>
                $allFunds,

            'all_expenses' =>
                $allExpenses,

            'all_incomes' =>
                $allIncomes,

            'all_loans' =>
                $allLoans,
        ];
    }


    // -------------------------------------------------
    // Return Dashboard Data
    // -------------------------------------------------

    echo json_encode([

        'success' => true,

        'message' =>
            'Dashboard data retrieved successfully.',

        'data' => [

            'owner' => [

                'owner_id' =>
                    $ownerId,

                'owner_name' =>
                    $owner['owner_name'],

                'owner_photo' =>
                    $owner['owner_photo'],

                'created_at' =>
                    $owner['created_at'],
            ],

            'gardens' =>
                $dashboardGardens,
        ],
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