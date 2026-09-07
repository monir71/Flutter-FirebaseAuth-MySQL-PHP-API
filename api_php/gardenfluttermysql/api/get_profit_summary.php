<?php

header('Content-Type: application/json');

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // -------------------------------------------------
    // Require Authenticated Firebase User
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
    // Find Owner
    // -------------------------------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            o.owner_id,
            o.owner_name

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
    // Garden ID
    // -------------------------------------------------

    $gardenId =
        isset($_GET['garden_id'])
            ? (int) $_GET['garden_id']
            : 0;


    if ($gardenId <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Valid garden ID is required.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Verify Owner Belongs To Garden
    // -------------------------------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            g.garden_id,
            g.garden_name

         FROM garden_owners go

         INNER JOIN gardens g
            ON go.garden_id = g.garden_id

         WHERE go.garden_id = :garden_id
           AND go.owner_id = :owner_id

         LIMIT 1'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
        ':owner_id' => $ownerId,
    ]);

    $garden = $stmt->fetch();


    if (!$garden) {

        http_response_code(403);

        echo json_encode([
            'success' => false,
            'message' =>
                'You are not an owner of this garden.',
        ]);

        exit;
    }


    // =================================================
    // TOTAL INCOME
    // =================================================

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            COALESCE(SUM(income_amount), 0)

         FROM incomes

         WHERE garden_id = :garden_id'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    $totalIncome =
        (float) $stmt->fetchColumn();


    // =================================================
    // TOTAL EXPENSE
    // =================================================

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            COALESCE(SUM(expense_amount), 0)

         FROM expenses

         WHERE garden_id = :garden_id'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    $totalExpense =
        (float) $stmt->fetchColumn();


    // =================================================
    // AVAILABLE GARDEN PROFIT
    // =================================================

    $availableProfit =
        $totalIncome - $totalExpense;


    // -------------------------------------------------
    // Profit cannot be negative
    // -------------------------------------------------

    if ($availableProfit < 0) {
        $availableProfit = 0;
    }


    // =================================================
    // NUMBER OF OWNERS
    // =================================================

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT COUNT(*)

         FROM garden_owners

         WHERE garden_id = :garden_id'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
    ]);

    $ownerCount =
        (int) $stmt->fetchColumn();


    // -------------------------------------------------
    // Equal Profit Share
    // -------------------------------------------------

    $equalProfitShare = 0;

    if ($ownerCount > 0) {

        $equalProfitShare =
            $availableProfit / $ownerCount;
    }


    // =================================================
    // MY APPROVED WITHDRAWALS
    // =================================================

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            COALESCE(SUM(profit_amount), 0)

         FROM profit_transactions

         WHERE garden_id = :garden_id
           AND owner_id = :owner_id
           AND status = :status'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
        ':owner_id' => $ownerId,
        ':status' => 'approved',
    ]);

    $myApprovedProfit =
        (float) $stmt->fetchColumn();


    // =================================================
    // MY PENDING WITHDRAWALS
    // =================================================

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            COALESCE(SUM(profit_amount), 0)

         FROM profit_transactions

         WHERE garden_id = :garden_id
           AND owner_id = :owner_id
           AND status = :status'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
        ':owner_id' => $ownerId,
        ':status' => 'pending',
    ]);

    $myPendingProfit =
        (float) $stmt->fetchColumn();


    // =================================================
    // MY AVAILABLE PROFIT
    // =================================================

    $myAvailableProfit =
        $equalProfitShare
        - $myApprovedProfit
        - $myPendingProfit;


    // -------------------------------------------------
    // Prevent Negative Available Amount
    // -------------------------------------------------

    if ($myAvailableProfit < 0) {
        $myAvailableProfit = 0;
    }


    // =================================================
    // RETURN RESULT
    // =================================================

    echo json_encode([

        'success' => true,

        'message' =>
            'Profit summary retrieved successfully.',

        'data' => [

            'garden_id' =>
                $gardenId,

            'garden_name' =>
                $garden['garden_name'],

            'owner_id' =>
                $ownerId,

            'owner_name' =>
                $owner['owner_name'],

            'owner_count' =>
                $ownerCount,

            'total_income' =>
                number_format(
                    $totalIncome,
                    2,
                    '.',
                    ''
                ),

            'total_expense' =>
                number_format(
                    $totalExpense,
                    2,
                    '.',
                    ''
                ),

            'available_profit' =>
                number_format(
                    $availableProfit,
                    2,
                    '.',
                    ''
                ),

            'equal_profit_share' =>
                number_format(
                    $equalProfitShare,
                    2,
                    '.',
                    ''
                ),

            'my_approved_profit' =>
                number_format(
                    $myApprovedProfit,
                    2,
                    '.',
                    ''
                ),

            'my_pending_profit' =>
                number_format(
                    $myPendingProfit,
                    2,
                    '.',
                    ''
                ),

            'my_available_profit' =>
                number_format(
                    $myAvailableProfit,
                    2,
                    '.',
                    ''
                ),
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