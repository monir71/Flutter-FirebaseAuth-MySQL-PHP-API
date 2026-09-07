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
    // Find Owner
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'SELECT
            o.owner_id

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
    // Find Owner's Pending Transaction
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'SELECT
            pt.profit_transaction_id,
            pt.status

         FROM profit_transactions pt

         WHERE pt.profit_transaction_id =
               :profit_transaction_id

           AND pt.owner_id = :owner_id

         LIMIT 1'
    );

    $stmt->execute([
        ':profit_transaction_id' =>
            $profitTransactionId,

        ':owner_id' =>
            $ownerId,
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
    // Only Pending Transactions Can Be Cancelled
    // -------------------------------------------------

    if ($transaction['status'] !== 'pending') {

        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' =>
                'Only pending profit transactions can be cancelled.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Mark Transaction as Rejected
    // -------------------------------------------------
    //
    // We do NOT delete the database row.
    //
    // The financial history remains permanently stored.
    //
    // Owner cancellation is recorded as "rejected".
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'UPDATE profit_transactions

         SET
            status = :status,
            admin_note = :admin_note

         WHERE profit_transaction_id =
               :profit_transaction_id

           AND owner_id = :owner_id

           AND status = :current_status'
    );

    $stmt->execute([
        ':status' =>
            'rejected',

        ':admin_note' =>
            'Owner cancelled the profit withdrawal request.',

        ':profit_transaction_id' =>
            $profitTransactionId,

        ':owner_id' =>
            $ownerId,

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
                'Profit transaction could not be cancelled.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Get Updated Transaction
    // -------------------------------------------------

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
            'Profit transaction cancelled successfully.',

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