<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

$user = requireAdmin();

echo json_encode([
    'success' => true,
    'message' => 'Admin authentication successful.',
    'data' => [
        'id' => $user['id'],
        'firebase_uid' => $user['firebase_uid'],
        'username' => $user['username'],
        'email' => $user['email'],
        'role' => $user['role'],
    ],
]);