<?php

/*
|--------------------------------------------------------------------------
| Connection Configurations
|--------------------------------------------------------------------------
*/

$host    = 'localhost';
$db      = 'gardenfluttermysql';
$user    = 'root';
$pass    = '';
$charset = 'utf8mb4';


/*
|--------------------------------------------------------------------------
| Data Source Name (DSN)
|--------------------------------------------------------------------------
*/

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";


/*
|--------------------------------------------------------------------------
| PDO Options
|--------------------------------------------------------------------------
*/

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];


try {

    /*
    |--------------------------------------------------------------------------
    | Create PDO connection
    |--------------------------------------------------------------------------
    */

    $conn = new PDO(
        $dsn,
        $user,
        $pass,
        $options
    );

} catch (PDOException $e) {

    /*
    |--------------------------------------------------------------------------
    | Log the actual error
    |--------------------------------------------------------------------------
    |
    | Never expose database credentials or internal
    | database errors to the client.
    |
    */

    error_log($e->getMessage());

    throw new RuntimeException(
        "Database connection failed."
    );
}