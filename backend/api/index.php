<?php

use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
$maintenance = __DIR__.'/../storage/framework/maintenance.php';
if (file_exists($maintenance)) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
$app = require_once __DIR__.'/../bootstrap/app.php';

// Set the request URI for Laravel routing
$uri = $_SERVER['REQUEST_URI'] ?? '/';

// Remove query string if present
$uri = strtok($uri, '?');

// Strip the /api prefix if present (Vercel routes /api/* to this file)
if (str_starts_with($uri, '/api')) {
    $uri = substr($uri, 4);
}
if ($uri === '') {
    $uri = '/';
}

// Override the request URI for Laravel
$_SERVER['REQUEST_URI'] = $uri;
$_SERVER['SCRIPT_NAME'] = '/index.php';

$app->handleRequest(Request::capture());
