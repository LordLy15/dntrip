<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TripController;
use App\Http\Controllers\Api\ItineraryController;
use App\Http\Controllers\ExpenseCategoryController;
use App\Http\Controllers\SuddenExpenseController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user', [AuthController::class, 'updateProfile']);
    Route::patch('/user', [AuthController::class, 'updateProfile']);

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
    Route::post('/trips/{tripId}/days', [ItineraryController::class, 'createDay']);
    Route::post('/trips/{tripId}/activities', [ItineraryController::class, 'createActivity']);
    Route::put('/trips/{tripId}/activities/{activityId}', [ItineraryController::class, 'updateActivity']);
    Route::put('/trips/{tripId}/activities/{activityId}/complete', [ItineraryController::class, 'completeActivity']);
    Route::delete('/trips/{tripId}/activities/{activityId}', [ItineraryController::class, 'deleteActivity']);

    // Expense Categories
    Route::get('/expense-categories', [ExpenseCategoryController::class, 'index']);
    Route::post('/expense-categories', [ExpenseCategoryController::class, 'store']);

    // Sudden Expenses
    Route::get('/trips/{trip}/sudden-expenses', [SuddenExpenseController::class, 'index']);
    Route::post('/trips/{trip}/sudden-expenses', [SuddenExpenseController::class, 'store']);
    Route::delete('/trips/{trip}/sudden-expenses/{expense}', [SuddenExpenseController::class, 'destroy']);
});
