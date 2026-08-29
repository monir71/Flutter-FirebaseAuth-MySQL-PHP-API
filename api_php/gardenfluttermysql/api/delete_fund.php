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

    if (!$fundId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Fund ID is required.',
        ]);

        exit;
    }

    // Check Fund
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

    // Delete Fund
    $stmt = $GLOBALS['conn']->prepare(
        'DELETE FROM funds
         WHERE fund_id = :fund_id'
    );

    $stmt->execute([
        ':fund_id' => $fundId,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Fund deleted successfully.',
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}