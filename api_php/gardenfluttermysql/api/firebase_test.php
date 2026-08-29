<?php

require __DIR__ . '/vendor/autoload.php';

use Kreait\Firebase\Factory;

try {

    $factory = (new Factory)
        ->withServiceAccount(
            'C:/xampp/firebase_credentials/nhgarden-ae870-firebase-adminsdk-fbsvc-8fc3c3fb7c.json'
        );

    $auth = $factory->createAuth();

    echo "Firebase Admin SDK connection successful!";

} catch (Throwable $e) {

    http_response_code(500);

    echo "Firebase connection failed: " . $e->getMessage();
}