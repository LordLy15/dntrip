<?php

namespace App\Http\Controllers;

use App\Models\SuddenExpense;
use App\Models\Trip;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SuddenExpenseController extends Controller
{
    public function index(int $tripId): JsonResponse
    {
        $trip = Trip::findOrFail($tripId);
        $expenses = $trip->suddenExpenses()->with('category')->get();

        return response()->json([
            'status' => 'success',
            'data' => $expenses,
        ]);
    }

    public function store(Request $request, int $tripId): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category_id' => 'nullable|exists:expense_categories,id',
            'amount' => 'required|numeric|min:0',
            'description' => 'nullable|string',
        ]);

        $trip = Trip::findOrFail($tripId);

        $expense = $trip->suddenExpenses()->create([
            'name' => $validated['name'],
            'expense_category_id' => $validated['category_id'] ?? null,
            'amount' => $validated['amount'],
            'description' => $validated['description'] ?? null,
        ]);

        $expense->load('category');

        return response()->json([
            'status' => 'success',
            'data' => $expense,
            'message' => 'Sudden expense added successfully',
        ], 201);
    }

    public function destroy(int $tripId, int $id): JsonResponse
    {
        $expense = SuddenExpense::where('trip_id', $tripId)->findOrFail($id);
        $expense->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Sudden expense deleted successfully',
        ]);
    }
}