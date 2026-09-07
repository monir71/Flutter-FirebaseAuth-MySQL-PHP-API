<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $conn = $GLOBALS['conn'];

    /*
     * Get general users who are not currently
     * linked to any owner.
     */

    $stmt = $conn->prepare(
        'SELECT
            u.id AS user_id,
            u.username,
            u.email
         FROM users u
         LEFT JOIN owners o
            ON o.user_id = u.id
         WHERE u.role = "general"
           AND o.owner_id IS NULL
         ORDER BY u.username ASC'
    );

    $stmt->execute();

    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'message' => 'Available users retrieved successfully.',
        'data' => $users,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}