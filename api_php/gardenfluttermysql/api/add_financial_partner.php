<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // Only admin can add a financial partner.
    requireAdmin();

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $partnerName = trim($input['partner_name'] ?? '');
    $partnerInstitution = trim(
        $input['partner_institution'] ?? ''
    );

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

    $stmt = $GLOBALS['conn']->prepare(
        'INSERT INTO financial_partners
            (partner_name, partner_institution)
         VALUES
            (:partner_name, :partner_institution)'
    );

    $stmt->execute([
        ':partner_name' => $partnerName,
        ':partner_institution' => $partnerInstitution,
    ]);

    $partnerId = $GLOBALS['conn']->lastInsertId();

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            partner_id,
            partner_name,
            partner_institution,
            partner_photo,
            created_at
         FROM financial_partners
         WHERE partner_id = :partner_id
         LIMIT 1'
    );

    $stmt->execute([
        ':partner_id' => $partnerId,
    ]);

    $partner = $stmt->fetch();

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Financial partner created successfully.',
        'data' => $partner,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}