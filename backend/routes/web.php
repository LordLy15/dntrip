<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

Route::get('/', function () {
    return view('welcome');
});

// Fallback route for SPA
Route::get('/{any}', function () {
    return view('welcome');
})->where('any', '.*');
