<?php

header('Content-Type: application/json');

echo json_encode([
    'server' => $_SERVER,
    'headers' => function_exists('getallheaders')
        ? getallheaders()
        : []
], JSON_PRETTY_PRINT);