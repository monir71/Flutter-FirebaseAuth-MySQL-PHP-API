<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // -------------------------------------------------
    // Admin authentication
    // -------------------------------------------------

    requireAdmin();

    $conn = $GLOBALS['conn'];

    // -------------------------------------------------
    // Get parameters
    // -------------------------------------------------

    $ownerId = isset($_GET['owner_id'])
        ? (int) $_GET['owner_id']
        : 0;

    $gardenId = isset($_GET['garden_id'])
        ? (int) $_GET['garden_id']
        : 0;

    // -------------------------------------------------
    // Validate parameters
    // -------------------------------------------------

    if ($ownerId <= 0) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Valid owner_id is required.',
        ]);

        exit;
    }

    if ($gardenId <= 0) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Valid garden_id is required.',
        ]);

        exit;
    }

    // -------------------------------------------------
    // Get owner's profit transactions
    //
    // Admin can see all transactions belonging to
    // this owner in this particular garden.
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

         WHERE pt.owner_id = ?
           AND pt.garden_id = ?

         ORDER BY pt.profit_transaction_id DESC'
    );

    $stmt->execute([
        $ownerId,
        $gardenId,
    ]);

    $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // -------------------------------------------------
    // Return response
    // -------------------------------------------------

    echo json_encode([
        'success' => true,
        'message' => 'Owner profit history retrieved successfully.',
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