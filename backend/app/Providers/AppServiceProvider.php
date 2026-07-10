<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configureRateLimiting();
    }

    /**
     * Configure the rate limiters for the application.
     */
    protected function configureRateLimiting(): void
    {
        // Default API rate limit - more lenient for development
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(120)->by($request->user()?->id ?: $request->ip());
        });

        // Login rate limit - allow more attempts
        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(30)->by($request->ip());
        });

        // CSRF/Sanctum rate limit - very lenient for preflight
        RateLimiter::for('sanctum', function (Request $request) {
            // Allow OPTIONS requests (CORS preflight) without rate limiting
            if ($request->isMethod('OPTIONS')) {
                return Limit::none();
            }
            return Limit::perMinute(60)->by($request->ip());
        });
    }
}
