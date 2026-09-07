<?php

header('Content-Type: application/json');

require_once __DIR__ . '/middleware/auth_middleware.php';

requireAdmin();

require __DIR__ . '/config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method.'
    ]);
    exit;
}

if (!isset($_POST['owner_id'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Owner ID is required.'
    ]);
    exit;
}

$ownerId = (int) $_POST['owner_id'];

if ($ownerId <= 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid owner ID.'
    ]);
    exit;
}

if (!isset($_FILES['photo'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Photo is required.'
    ]);
    exit;
}

$file = $_FILES['photo'];

if ($file['error'] !== UPLOAD_ERR_OK) {
    echo json_encode([
        'success' => false,
        'message' => 'Photo upload failed.'
    ]);
    exit;
}

/*
|--------------------------------------------------------------------------
| Check owner
|--------------------------------------------------------------------------
*/

$stmt = $conn->prepare(
    "SELECT owner_id
     FROM owners
     WHERE owner_id = ?
     LIMIT 1"
);

$stmt->execute([$ownerId]);

if ($stmt->fetch() === false) {
    echo json_encode([
        'success' => false,
        'message' => 'Owner not found.'
    ]);
    exit;
}

/*
|--------------------------------------------------------------------------
| Validate image
|--------------------------------------------------------------------------
*/

$allowedTypes = [
    'image/jpeg' => 'jpg',
    'image/png'  => 'png',
    'image/webp' => 'webp',
];

$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimeType = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);

if (!isset($allowedTypes[$mimeType])) {
    echo json_encode([
        'success' => false,
        'message' => 'Only JPG, PNG and WEBP images are allowed.'
    ]);
    exit;
}

/*
|--------------------------------------------------------------------------
| Create upload directory
|--------------------------------------------------------------------------
*/

$uploadDir = __DIR__ . '/../uploads/owners/';

if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

/*
|--------------------------------------------------------------------------
| Generate filename
|--------------------------------------------------------------------------
*/

$extension = $allowedTypes[$mimeType];

$fileName = 'owner_' . $ownerId . '_' . time() . '.' . $extension;

$filePath = $uploadDir . $fileName;

/*
|--------------------------------------------------------------------------
| Move uploaded file
|--------------------------------------------------------------------------
*/

if (!move_uploaded_file($file['tmp_name'], $filePath)) {
    echo json_encode([
        'success' => false,
        'message' => 'Unable to save photo.'
    ]);
    exit;
}

/*
|--------------------------------------------------------------------------
| Save path in database
|--------------------------------------------------------------------------
*/

$photoPath = '/../uploads/owners/' . $fileName;

$stmt = $conn->prepare(
    "UPDATE owners
     SET owner_photo = ?
     WHERE owner_id = ?"
);

$success = $stmt->execute([
    $photoPath,
    $ownerId
]);

if (!$success) {

    // Remove uploaded file if database update fails.
    if (file_exists($filePath)) {
        unlink($filePath);
    }

    echo json_encode([
        'success' => false,
        'message' => 'Unable to save photo information.'
    ]);
    exit;
}

echo json_encode([
    'success' => true,
    'message' => 'Owner photo uploaded successfully.',
    'data' => [
        'owner_id' => $ownerId,
        'owner_photo' => $photoPath
    ]
]);