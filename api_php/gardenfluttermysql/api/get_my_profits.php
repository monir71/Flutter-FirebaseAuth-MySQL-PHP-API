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
    // Get My Profit Transactions
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

            -- approved_by contains users.id
            au.username AS approved_by_name,

            pt.approved_at,
            pt.created_at

         FROM profit_transactions pt

         INNER JOIN owners o
            ON pt.owner_id = o.owner_id

         INNER JOIN gardens g
            ON pt.garden_id = g.garden_id

         -- approved_by references users.id
         LEFT JOIN users au
            ON pt.approved_by = au.id

         WHERE pt.owner_id = :owner_id

         ORDER BY
            pt.profit_transaction_id DESC'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    $transactions = $stmt->fetchAll();


    // -------------------------------------------------
    // Return Data
    // -------------------------------------------------

    echo json_encode([
        'success' => true,

        'message' =>
            'My profit transactions retrieved successfully.',

        'data' => $transactions,
    ]);


} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}