<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // -------------------------------------------------
    // Require Admin
    // -------------------------------------------------

    requireAdmin();


    // -------------------------------------------------
    // Get Authenticated User
    // -------------------------------------------------

    $user = requireAuthenticatedUser();

    $adminUserId = isset($user['id'])
        ? (int) $user['id']
        : 0;


    if ($adminUserId <= 0) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Authenticated admin information not found.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Get Request Data
    // -------------------------------------------------

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );


    if (!is_array($input)) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Invalid request data.',
        ]);

        exit;
    }


    $profitTransactionId =
        isset($input['profit_transaction_id'])
            ? (int) $input['profit_transaction_id']
            : 0;


    // -------------------------------------------------
    // Validate Transaction ID
    // -------------------------------------------------

    if ($profitTransactionId <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' =>
                'Valid profit transaction ID is required.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Find Profit Transaction
    // -------------------------------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            pt.profit_transaction_id,
            pt.owner_id,
            pt.garden_id,
            pt.profit_amount,
            pt.profit_date,
            pt.status

         FROM profit_transactions pt

         WHERE pt.profit_transaction_id =
               :profit_transaction_id

         LIMIT 1'
    );

    $stmt->execute([
        ':profit_transaction_id' =>
            $profitTransactionId,
    ]);

    $transaction = $stmt->fetch();


    // -------------------------------------------------
    // Transaction Not Found
    // -------------------------------------------------

    if (!$transaction) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' =>
                'Profit transaction not found.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Only Pending Transactions Can Be Approved
    // -------------------------------------------------

    if ($transaction['status'] !== 'pending') {

        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' =>
                'Only pending profit transactions can be approved.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Approve Transaction
    // -------------------------------------------------
    //
    // IMPORTANT:
    // Profit availability validation will be added
    // here later.
    //
    // For now this only performs the approval workflow.
    // -------------------------------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'UPDATE profit_transactions

         SET
            status = :status,
            approved_by = :approved_by,
            approved_at = CURRENT_TIMESTAMP

         WHERE profit_transaction_id =
               :profit_transaction_id

           AND status = :current_status'
    );

    $stmt->execute([
        ':status' =>
            'approved',

        ':approved_by' =>
            $adminUserId,

        ':profit_transaction_id' =>
            $profitTransactionId,

        ':current_status' =>
            'pending',
    ]);


    // -------------------------------------------------
    // Confirm Update
    // -------------------------------------------------

    if ($stmt->rowCount() === 0) {

        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' =>
                'Profit transaction could not be approved.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Get Updated Transaction
    // -------------------------------------------------

    $stmt = $GLOBALS['conn']->prepare(
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
            au.username AS approved_by_name,
            pt.approved_at,

            pt.created_at

         FROM profit_transactions pt

         INNER JOIN owners o
            ON pt.owner_id = o.owner_id

         INNER JOIN gardens g
            ON pt.garden_id = g.garden_id

         LEFT JOIN users au
            ON pt.approved_by = au.id

         WHERE pt.profit_transaction_id =
               :profit_transaction_id

         LIMIT 1'
    );

    $stmt->execute([
        ':profit_transaction_id' =>
            $profitTransactionId,
    ]);

    $profitTransaction =
        $stmt->fetch();


    // -------------------------------------------------
    // Return Response
    // -------------------------------------------------

    echo json_encode([
        'success' => true,

        'message' =>
            'Profit transaction approved successfully.',

        'data' =>
            $profitTransaction,
    ]);


} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}