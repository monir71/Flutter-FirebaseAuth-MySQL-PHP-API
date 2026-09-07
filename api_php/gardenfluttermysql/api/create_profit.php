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


    $gardenId =
        isset($input['garden_id'])
            ? (int) $input['garden_id']
            : 0;

    $profitAmount =
        isset($input['profit_amount'])
            ? (float) $input['profit_amount']
            : 0;

    $profitDate =
        trim($input['profit_date'] ?? '');

    $profitNote =
        isset($input['profit_note'])
            ? trim($input['profit_note'])
            : null;


    // -------------------------------------------------
    // Basic Validation
    // -------------------------------------------------

    if ($gardenId <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Valid garden ID is required.',
        ]);

        exit;
    }


    if ($profitAmount <= 0) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Profit amount must be greater than zero.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Validate Profit Date
    // -------------------------------------------------

    $dateObject =
        DateTime::createFromFormat(
            'Y-m-d',
            $profitDate
        );

    $dateErrors =
        DateTime::getLastErrors();

    if (
        !$dateObject ||
        (
            $dateErrors !== false &&
            (
                $dateErrors['warning_count'] > 0 ||
                $dateErrors['error_count'] > 0
            )
        ) ||
        $dateObject->format('Y-m-d') !== $profitDate
    ) {

        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' =>
                'Valid profit date is required. Use YYYY-MM-DD.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Verify Owner Belongs to Garden
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'SELECT
            id

         FROM garden_owners

         WHERE garden_id = :garden_id
           AND owner_id = :owner_id

         LIMIT 1'
    );

    $stmt->execute([
        ':garden_id' => $gardenId,
        ':owner_id' => $ownerId,
    ]);

    $gardenOwner = $stmt->fetch();


    if (!$gardenOwner) {

        http_response_code(403);

        echo json_encode([
            'success' => false,
            'message' => 'You do not belong to this garden.',
        ]);

        exit;
    }


    // -------------------------------------------------
    // Create Profit Transaction
    // -------------------------------------------------
    //
    // New requests always start as PENDING.
    //
    // approved_by = NULL
    // approved_at = NULL
    // admin_note  = NULL
    //
    // Profit availability validation will be
    // implemented later.
    // -------------------------------------------------

    $stmt = $conn->prepare(
        'INSERT INTO profit_transactions (
            owner_id,
            garden_id,
            profit_amount,
            profit_date,
            status,
            profit_note
         )

         VALUES (
            :owner_id,
            :garden_id,
            :profit_amount,
            :profit_date,
            :status,
            :profit_note
         )'
    );

    $stmt->execute([
        ':owner_id' =>
            $ownerId,

        ':garden_id' =>
            $gardenId,

        ':profit_amount' =>
            $profitAmount,

        ':profit_date' =>
            $profitDate,

        ':status' =>
            'pending',

        ':profit_note' =>
            $profitNote,
    ]);


    $profitTransactionId =
        (int) $conn->lastInsertId();


    // -------------------------------------------------
    // Get Created Transaction
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

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' =>
            'Profit transaction created successfully.',
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