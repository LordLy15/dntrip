<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

$app = Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->statefulApi();
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            if ($request->expectsJson() || $request->wantsJson()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Route not found.',
                ], 404);
            }
        });

        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if ($request->expectsJson() || $request->wantsJson()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Unauthenticated.',
                ], 401);
            }
        });
    })->create();

// Vercel: Set URL for proper routing
if (getenv('VERCEL_URL')) {
    $app['config']->set('app.url', 'https://' . getenv('VERCEL_URL'));
    $app['config']->set('sanctum.stateful', explode(',', env('SANCTUM_STATEFUL_DOMAINS',
        'localhost:3000,dntrip-lilac.vercel.app'
    )));
}

return $app;
