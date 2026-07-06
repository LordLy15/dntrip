<?php

namespace App\Http\Controllers;

use App\Models\ExpenseCategory;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ExpenseCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ExpenseCategory::all();
        return response()->json([
            'status' => 'success',
            'data' => $categories,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'icon' => 'required|string|max:50',
            'description' => 'nullable|string',
        ]);

        $slug = \Illuminate\Support\Str::slug($validated['name']);

        $category = ExpenseCategory::create([
            'name' => $validated['name'],
            'slug' => $slug . '-' . time(),
            'icon' => $validated['icon'] ?? 'category',
            'description' => $validated['description'] ?? null,
            'is_custom' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => $category,
            'message' => 'Custom category created successfully',
        ], 201);
    }
}