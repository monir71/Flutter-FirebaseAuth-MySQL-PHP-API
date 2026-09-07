<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $conn = $GLOBALS['conn'];

    /*
     * -------------------------------------------------
     * Get ONLY pending profit requests
     * -------------------------------------------------
     *
     * Approved and rejected transactions are intentionally
     * excluded from this endpoint.
     *
     * This endpoint is used by the Admin Profit Management
     * screen as the approval queue.
     */

    $stmt = $conn->prepare(
        'SELECT
            pt.profit_transaction_id,
            pt.owner_id,
            o.owner_name,
            pt.garden_id,
            g.garden_name,
            pt.profit_amount,
            pt.profit_date,
            pt.status,
            pt.profit_note,
            pt.admin_note,
            pt.approved_by,
            approver.owner_name AS approved_by_name,
            pt.approved_at,
            pt.created_at

         FROM profit_transactions pt

         INNER JOIN owners o
            ON pt.owner_id = o.owner_id

         INNER JOIN gardens g
            ON pt.garden_id = g.garden_id

         LEFT JOIN owners approver
            ON pt.approved_by = approver.owner_id

         WHERE pt.status = "pending"

         ORDER BY pt.profit_transaction_id DESC'
    );

    $stmt->execute();

    $transactions = $stmt->fetchAll();

    $result = [];

    foreach ($transactions as $transaction) {

        $ownerId =
            (int) $transaction['owner_id'];

        $gardenId =
            (int) $transaction['garden_id'];

        $transactionId =
            (int) $transaction['profit_transaction_id'];

        $requestedAmount =
            (float) $transaction['profit_amount'];


        /*
         * -------------------------------------------------
         * Owner Count
         * -------------------------------------------------
         */

        $stmtOwnerCount = $conn->prepare(
            'SELECT COUNT(*)
             FROM garden_owners
             WHERE garden_id = ?'
        );

        $stmtOwnerCount->execute([
            $gardenId
        ]);

        $ownerCount =
            (int) $stmtOwnerCount->fetchColumn();


        /*
         * -------------------------------------------------
         * Total Income
         * -------------------------------------------------
         */

        $stmtIncome = $conn->prepare(
            'SELECT COALESCE(SUM(income_amount), 0)
             FROM incomes
             WHERE garden_id = ?'
        );

        $stmtIncome->execute([
            $gardenId
        ]);

        $totalIncome =
            (float) $stmtIncome->fetchColumn();


        /*
         * -------------------------------------------------
         * Total Expense
         * -------------------------------------------------
         */

        $stmtExpense = $conn->prepare(
            'SELECT COALESCE(SUM(expense_amount), 0)
             FROM expenses
             WHERE garden_id = ?'
        );

        $stmtExpense->execute([
            $gardenId
        ]);

        $totalExpense =
            (float) $stmtExpense->fetchColumn();


        /*
         * -------------------------------------------------
         * Available Garden Profit
         * -------------------------------------------------
         */

        $availableProfit =
            $totalIncome - $totalExpense;

        if ($availableProfit < 0) {
            $availableProfit = 0.0;
        }


        /*
         * -------------------------------------------------
         * Equal Profit Share
         * -------------------------------------------------
         *
         * Current rule:
         *
         * Total available profit / number of owners
         *
         * Fund amount does NOT matter.
         */

        $equalProfitShare = 0.0;

        if ($ownerCount > 0) {

            $equalProfitShare =
                $availableProfit / $ownerCount;
        }


        /*
         * -------------------------------------------------
         * Owner's Already Approved Profit
         * -------------------------------------------------
         *
         * Approved withdrawals have already been paid
         * from the owner's equal share.
         */

        $stmtApproved = $conn->prepare(
            'SELECT COALESCE(SUM(profit_amount), 0)
             FROM profit_transactions
             WHERE owner_id = ?
               AND garden_id = ?
               AND status = "approved"'
        );

        $stmtApproved->execute([
            $ownerId,
            $gardenId
        ]);

        $ownerApprovedProfit =
            (float) $stmtApproved->fetchColumn();


        /*
         * -------------------------------------------------
         * OTHER Pending Profit
         * -------------------------------------------------
         *
         * IMPORTANT:
         *
         * The current transaction is excluded.
         *
         * Example:
         *
         * Equal share = 2105
         * Approved     = 50
         * Current req  = 2000
         *
         * There are NO other pending requests.
         *
         * Therefore:
         *
         * Available for current request
         * = 2105 - 50
         * = 2055
         *
         * So the 2000 request is eligible.
         */

        $stmtOtherPending = $conn->prepare(
            'SELECT COALESCE(SUM(profit_amount), 0)
             FROM profit_transactions
             WHERE owner_id = ?
               AND garden_id = ?
               AND status = "pending"
               AND profit_transaction_id != ?'
        );

        $stmtOtherPending->execute([
            $ownerId,
            $gardenId,
            $transactionId
        ]);

        $ownerOtherPendingProfit =
            (float) $stmtOtherPending->fetchColumn();


        /*
         * -------------------------------------------------
         * Owner's Available Profit For THIS Request
         * -------------------------------------------------
         */

        $ownerAvailableProfit =
            $equalProfitShare
            - $ownerApprovedProfit
            - $ownerOtherPendingProfit;

        if ($ownerAvailableProfit < 0) {
            $ownerAvailableProfit = 0.0;
        }


        /*
         * -------------------------------------------------
         * Total Pending Profit Including Current Request
         * -------------------------------------------------
         *
         * This is useful information for Admin.
         */

        $ownerPendingProfit =
            $ownerOtherPendingProfit
            + $requestedAmount;


        /*
         * -------------------------------------------------
         * Eligibility
         * -------------------------------------------------
         *
         * Only pending transactions reach this point
         * because the SQL query already filters them.
         */

        $eligible = false;

        $eligibilityMessage = '';


        if ($ownerCount <= 0) {

            $eligibilityMessage =
                'This garden has no owners.';

        } elseif ($equalProfitShare <= 0) {

            $eligibilityMessage =
                'No profit is currently available for distribution.';

        } elseif ($requestedAmount > $ownerAvailableProfit) {

            $eligibilityMessage =
                'Requested amount exceeds the owner\'s available profit.';

        } else {

            $eligible = true;

            $eligibilityMessage =
                'Owner is eligible for approval.';
        }


        /*
         * -------------------------------------------------
         * Build Response
         * -------------------------------------------------
         */

        $transaction['owner_count'] =
            $ownerCount;

        $transaction['total_income'] =
            number_format(
                $totalIncome,
                2,
                '.',
                ''
            );

        $transaction['total_expense'] =
            number_format(
                $totalExpense,
                2,
                '.',
                ''
            );

        $transaction['available_profit'] =
            number_format(
                $availableProfit,
                2,
                '.',
                ''
            );

        $transaction['equal_profit_share'] =
            number_format(
                $equalProfitShare,
                2,
                '.',
                ''
            );

        $transaction['owner_approved_profit'] =
            number_format(
                $ownerApprovedProfit,
                2,
                '.',
                ''
            );

        /*
         * Total pending amount belonging to this owner,
         * INCLUDING the current request.
         */

        $transaction['owner_pending_profit'] =
            number_format(
                $ownerPendingProfit,
                2,
                '.',
                ''
            );

        /*
         * Pending amount from OTHER requests only.
         *
         * This is useful when Admin needs to understand
         * why a request may or may not be eligible.
         */

        $transaction['owner_other_pending_profit'] =
            number_format(
                $ownerOtherPendingProfit,
                2,
                '.',
                ''
            );

        /*
         * Amount available for THIS particular request.
         */

        $transaction['owner_available_profit'] =
            number_format(
                $ownerAvailableProfit,
                2,
                '.',
                ''
            );

        $transaction['eligible'] =
            $eligible;

        $transaction['eligibility_message'] =
            $eligibilityMessage;

        $result[] =
            $transaction;
    }


    /*
     * -------------------------------------------------
     * Response
     * -------------------------------------------------
     */

    echo json_encode([
        'success' => true,
        'message' => 'Pending profit requests retrieved successfully.',
        'data' => $result,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}