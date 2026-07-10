<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        env('CORS_ALLOWED_ORIGINS', 'https://dntrip-lilac.vercel.app'),
    ],

    'allowed_origins_patterns' => [
        '/^https:\/\/.*\.vercel\.app$/',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [
        'X-Total-Count',
    ],

    'max_age' => 86400,

    'supports_credentials' => true,

];
