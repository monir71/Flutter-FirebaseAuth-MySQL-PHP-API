<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

try {

    requireAdmin();

    $conn = $GLOBALS['conn'];

    $input = json_decode(
        file_get_contents('php://input'),
        true
    );

    $ownerId = isset($input['owner_id'])
        ? (int) $input['owner_id']
        : 0;

    $userId = isset($input['user_id'])
        ? (int) $input['user_id']
        : 0;

    if ($ownerId <= 0 || $userId <= 0) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Owner ID and User ID are required.',
        ]);

        exit;
    }

    /*
     * Verify owner exists.
     */

    $stmtOwner = $conn->prepare(
        'SELECT owner_id
         FROM owners
         WHERE owner_id = ?'
    );

    $stmtOwner->execute([
        $ownerId
    ]);

    if (!$stmtOwner->fetch()) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'Owner not found.',
        ]);

        exit;
    }

    /*
     * Verify user exists and is a general user.
     */

    $stmtUser = $conn->prepare(
        'SELECT
            id,
            username,
            email,
            role
         FROM users
         WHERE id = ?'
    );

    $stmtUser->execute([
        $userId
    ]);

    $user = $stmtUser->fetch();

    if (!$user) {

        http_response_code(404);

        echo json_encode([
            'success' => false,
            'message' => 'User not found.',
        ]);

        exit;
    }

    if ($user['role'] !== 'general') {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Only general users can be linked to an owner.',
        ]);

        exit;
    }

    /*
     * Check whether this user is already linked
     * to another owner.
     */

    $stmtExisting = $conn->prepare(
        'SELECT
            owner_id,
            owner_name
         FROM owners
         WHERE user_id = ?'
    );

    $stmtExisting->execute([
        $userId
    ]);

    $existingOwner = $stmtExisting->fetch();

    if ($existingOwner) {

        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' =>
                'This user is already linked to owner: '
                . $existingOwner['owner_name'],
        ]);

        exit;
    }

    /*
     * Link user to owner.
     */

    $stmtUpdate = $conn->prepare(
        'UPDATE owners
         SET user_id = ?
         WHERE owner_id = ?'
    );

    $stmtUpdate->execute([
        $userId,
        $ownerId
    ]);

    /*
     * Return updated owner information.
     */

    $stmtResult = $conn->prepare(
        'SELECT
            o.owner_id,
            o.owner_name,
            o.user_id,
            u.username,
            u.email
         FROM owners o
         LEFT JOIN users u
            ON o.user_id = u.id
         WHERE o.owner_id = ?'
    );

    $stmtResult->execute([
        $ownerId
    ]);

    $owner = $stmtResult->fetch();

    echo json_encode([
        'success' => true,
        'message' => 'User linked to owner successfully.',
        'data' => $owner,
    ]);

} catch (\Throwable $e) {

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Server error.',
        'error' => $e->getMessage(),
    ]);
}