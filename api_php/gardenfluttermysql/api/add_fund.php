<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $ownerId = $input['owner_id'] ?? null;
    $gardenId = $input['garden_id'] ?? null;
    $fundAmount = $input['fund_amount'] ?? null;
    $fundDate = $input['fund_date'] ?? null;

    // -----------------------------
    // Validation
    // -----------------------------

    if (!$ownerId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Owner ID is required.',
        ]);

        exit;
    }

    if (!$gardenId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Garden ID is required.',
        ]);

        exit;
    }

    if ($fundAmount === null || $fundAmount === '') {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Fund amount is required.',
        ]);

        exit;
    }

    if (!is_numeric($fundAmount) || $fundAmount <= 0) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Fund amount must be greater than zero.',
        ]);

        exit;
    }

    if (!$fundDate) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Fund date is required.',
        ]);

        exit;
    }

    // -----------------------------
    // Check Owner
    // -----------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT owner_id
         FROM owners
         WHERE owner_id = :owner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.',
        ]);

        exit;
    }

    // -----------------------------
    // Check Garden
    // -----------------------------

    $stmt = $GLOBALS['conn']->prepare(
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

    // -----------------------------
    // Insert Fund
    // -----------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'INSERT INTO funds
            (
                owner_id,
                garden_id,
                fund_amount,
                fund_date
            )
         VALUES
            (
                :owner_id,
                :garden_id,
                :fund_amount,
                :fund_date
            )'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
        ':garden_id' => $gardenId,
        ':fund_amount' => $fundAmount,
        ':fund_date' => $fundDate,
    ]);

    $fundId = $GLOBALS['conn']->lastInsertId();

    // -----------------------------
    // Get inserted fund
    // -----------------------------

    $stmt = $GLOBALS['conn']->prepare(
		'SELECT
			f.fund_id,
			f.owner_id,
			o.owner_name,
			f.garden_id,
			g.garden_name,
			f.fund_amount,
			f.fund_date,
			f.created_at
		 FROM funds f
		 INNER JOIN owners o
			ON f.owner_id = o.owner_id
		 INNER JOIN gardens g
			ON f.garden_id = g.garden_id
		 WHERE f.fund_id = :fund_id
		 LIMIT 1'
	);

    $stmt->execute([
        ':fund_id' => $fundId,
    ]);

    $fund = $stmt->fetch();

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Fund created successfully.',
        'data' => $fund,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}