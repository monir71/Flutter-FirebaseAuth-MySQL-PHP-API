<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $partnerId = $input['partner_id'] ?? null;

    if (!$partnerId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Partner ID is required.',
        ]);

        exit;
    }

    // Check partner exists
    $stmt = $GLOBALS['conn']->prepare(
        'SELECT partner_id
         FROM financial_partners
         WHERE partner_id = :partner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    if (!$stmt->fetch()) {
        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Financial partner not found.',
        ]);

        exit;
    }

    // Delete partner
    $stmt = $GLOBALS['conn']->prepare(
        'DELETE FROM financial_partners
         WHERE partner_id = :partner_id'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Financial partner deleted successfully.',
    ]);

} catch (\Throwable $e) {

    /*
     * Because loans.partner_id uses ON DELETE RESTRICT,
     * a partner with existing loans cannot be deleted.
     */
    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}