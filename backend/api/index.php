<?php

use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Vercel: Set the request URI
$_SERVER['REQUEST_URI'] = '/api' . parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->handleRequest(Request::capture());
