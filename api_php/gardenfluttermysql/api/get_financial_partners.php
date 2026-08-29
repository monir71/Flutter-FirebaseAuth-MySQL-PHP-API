<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    // Only logged-in admin can get all financial partners.
    requireAdmin();

    $stmt = $GLOBALS['conn']->prepare(
        'SELECT
            partner_id,
            partner_name,
            partner_institution,
            partner_photo,
            created_at
         FROM financial_partners
         ORDER BY partner_id DESC'
    );

    $stmt->execute();

    $partners = $stmt->fetchAll();

    echo json_encode([
        'success' => true,
        'message' => 'Financial partners retrieved successfully.',
        'data' => $partners,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}