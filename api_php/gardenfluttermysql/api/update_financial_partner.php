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
    $partnerName = trim($input['partner_name'] ?? '');
    $partnerInstitution = trim(
        $input['partner_institution'] ?? ''
    );

    if (!$partnerId) {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Partner ID is required.',
        ]);

        exit;
    }

    if ($partnerName === '') {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Partner name is required.',
        ]);

        exit;
    }

    if ($partnerInstitution === '') {
        http_response_code(422);

        echo json_encode([
            'success' => false,
            'message' => 'Partner institution is required.',
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

    // Update partner
    $stmt = $GLOBALS['conn']->prepare(
        'UPDATE financial_partners
         SET
            partner_name = :partner_name,
            partner_institution = :partner_institution
         WHERE partner_id = :partner_id'
    );

    $stmt->execute([
        ':partner_name' => $partnerName,
        ':partner_institution' => $partnerInstitution,
        ':partner_id' => $partnerId,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Financial partner updated successfully.',
        'data' => [
            'partner_id' => (int) $partnerId,
            'partner_name' => $partnerName,
            'partner_institution' => $partnerInstitution,
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