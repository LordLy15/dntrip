<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

Route::get('/', function () {
    return view('welcome');
});

// Login route for Sanctum redirect
Route::get('/login', function () {
    return redirect('/');
})->name('login');

// Fallback route for SPA
Route::get('/{any}', function () {
    return view('welcome');
})->where('any', '.*');
