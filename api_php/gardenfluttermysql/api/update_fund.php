<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $fundId = $input['fund_id'] ?? null;
    $ownerId = $input['owner_id'] ?? null;
    $gardenId = $input['garden_id'] ?? null;
    $fundAmount = $input['fund_amount'] ?? null;
    $fundDate = $input['fund_date'] ?? null;

    // -----------------------------
    // Validation
    // -----------------------------

    if (!$fundId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Fund ID is required.',
        ]);

        exit;
    }

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
    // Check Fund
    // -----------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT fund_id
         FROM funds
         WHERE fund_id = :fund_id
         LIMIT 1'
    );

    $stmt->execute([
        ':fund_id' => $fundId,
    ]);

    if (!$stmt->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Fund not found.',
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
    // Update Fund
    // -----------------------------

    $stmt = $GLOBALS['conn']->prepare(
        'UPDATE funds
         SET
            owner_id = :owner_id,
            garden_id = :garden_id,
            fund_amount = :fund_amount,
            fund_date = :fund_date
         WHERE fund_id = :fund_id'
    );

    $stmt->execute([
        ':owner_id' => $ownerId,
        ':garden_id' => $gardenId,
        ':fund_amount' => $fundAmount,
        ':fund_date' => $fundDate,
        ':fund_id' => $fundId,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Fund updated successfully.',
        'data' => [
            'fund_id' => (int) $fundId,
            'owner_id' => (int) $ownerId,
            'garden_id' => (int) $gardenId,
            'fund_amount' => number_format(
                (float) $fundAmount,
                2,
                '.',
                ''
            ),
            'fund_date' => $fundDate,
        ],
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}