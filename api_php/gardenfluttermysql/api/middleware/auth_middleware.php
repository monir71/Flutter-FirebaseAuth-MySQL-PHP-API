<?php

use Kreait\Firebase\Factory;

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../config/database.php';

date_default_timezone_set("Asia/Dhaka");


/**
 * Get the Firebase ID token from the Authorization header.
 */
function getBearerToken(): string
{
    $headers = getallheaders();

    $authorization = $headers['Authorization']
        ?? $headers['authorization']
        ?? null;

    if (!$authorization) {
        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Authorization header is missing.',
        ]);

        exit;
    }

    if (!preg_match('/Bearer\s+(.+)/i', $authorization, $matches)) {
        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Invalid Authorization header.',
        ]);

        exit;
    }

    return trim($matches[1]);
}


/**
 * Authenticate the Firebase user and retrieve
 * the corresponding MySQL user.
 */
function authenticateUser(): array
{
    $idToken = getBearerToken();

    try {
        $factory = (new Factory)
            ->withServiceAccount(
                'C:/xampp/firebase_credentials/nhgarden-ae870-firebase-adminsdk-fbsvc-8fc3c3fb7c.json'
            );

        $auth = $factory->createAuth();

        $verifiedIdToken = $auth->verifyIdToken($idToken);

        $firebaseUid = $verifiedIdToken->claims()->get('sub');

        if (!$firebaseUid) {
            http_response_code(401);

            echo json_encode([
                'success' => false,
                'message' => 'Firebase UID not found in token.',
            ]);

            exit;
        }

        $stmt = $GLOBALS['conn']->prepare(
            'SELECT
                id,
                firebase_uid,
                username,
                email,
                role,
                created_at
             FROM users
             WHERE firebase_uid = :firebase_uid
             LIMIT 1'
        );

        $stmt->execute([
            ':firebase_uid' => $firebaseUid,
        ]);

        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(404);

            echo json_encode([
                'success' => false,
                'message' => 'User not found in MySQL.',
            ]);

            exit;
        }

        return $user;

    } catch (\Throwable $e) {

        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => $e . 'Invalid or expired Firebase ID token.',
        ]);

        exit;
    }
}


/**
 * Require an authenticated Firebase user.
 */
function requireAuthenticatedUser(): array
{
    return authenticateUser();
}


/**
 * Require an authenticated admin user.
 */
function requireAdmin(): array
{
    $user = authenticateUser();

    if ($user['role'] !== 'admin') {

        http_response_code(403);

        echo json_encode([
            'success' => false,
            'message' => 'Admin access required.',
        ]);

        exit;
    }

    return $user;
}