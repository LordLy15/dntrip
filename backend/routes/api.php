<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TripController;
use App\Http\Controllers\Api\ItineraryController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // Trips
    Route::get('/trips', [TripController::class, 'index']);
    Route::post('/trips', [TripController::class, 'store']);
    Route::get('/trips/{id}', [TripController::class, 'show']);
    Route::put('/trips/{id}', [TripController::class, 'update']);
    Route::delete('/trips/{id}', [TripController::class, 'destroy']);
    Route::post('/trips/join', [TripController::class, 'join']);
    Route::get('/trips/{id}/members', [TripController::class, 'members']);
    Route::put('/trips/{id}/members/{userId}/role', [TripController::class, 'updateMemberRole']);
    Route::delete('/trips/{id}/members/{userId}', [TripController::class, 'removeMember']);

    // Itinerary / Activities
    Route::get('/trips/{id}/days', [ItineraryController::class, 'index']);
    Route::post('/trips/{tripId}/activities', [ItineraryController::class, 'createActivity']);
    Route::put('/trips/{tripId}/activities/{activityId}', [ItineraryController::class, 'updateActivity']);
    Route::put('/trips/{tripId}/activities/{activityId}/complete', [ItineraryController::class, 'completeActivity']);
    Route::delete('/trips/{tripId}/activities/{activityId}', [ItineraryController::class, 'deleteActivity']);
});
