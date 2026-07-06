# Task 3: Backend - Seeder & Controllers

## Overview
Create the ExpenseCategorySeeder, ExpenseCategoryController, SuddenExpenseController, and update routes.

## Files to Create/Modify

### 1. Create: `backend/database/seeders/ExpenseCategorySeeder.php`

```php
<?php
namespace Database\Seeders;

use App\Models\ExpenseCategory;
use Illuminate\Database\Seeder;

class ExpenseCategorySeeder extends Seeder
{
    public function run(): void
    {
        foreach (ExpenseCategory::defaultCategories() as $category) {
            ExpenseCategory::firstOrCreate(
                ['slug' => $category['slug']],
                $category
            );
        }
    }
}
```

### 2. Create: `backend/app/Http/Controllers/ExpenseCategoryController.php`

```php
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
```

### 3. Create: `backend/app/Http/Controllers/SuddenExpenseController.php`

```php
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
```

### 4. Modify: `backend/routes/api.php`

Add these imports and routes:
```php
use App\Http\Controllers\ExpenseCategoryController;
use App\Http\Controllers\SuddenExpenseController;

// Expense Categories
Route::get('/expense-categories', [ExpenseCategoryController::class, 'index']);
Route::post('/expense-categories', [ExpenseCategoryController::class, 'store']);

// Sudden Expenses
Route::get('/trips/{trip}/sudden-expenses', [SuddenExpenseController::class, 'index']);
Route::post('/trips/{trip}/sudden-expenses', [SuddenExpenseController::class, 'store']);
Route::delete('/trips/{trip}/sudden-expenses/{expense}', [SuddenExpenseController::class, 'destroy']);
```

Also add to `database/seeders/DatabaseSeeder.php`:
```php
$this->call([ExpenseCategorySeeder::class]);
```

## Acceptance Criteria

- [ ] ExpenseCategorySeeder created and can be run
- [ ] ExpenseCategoryController handles index and store
- [ ] SuddenExpenseController handles index, store, destroy
- [ ] Routes added for all endpoints
- [ ] Seeder added to DatabaseSeeder

## Notes

- Depends on Task 2 models being completed
- Run `php artisan db:seed --class=ExpenseCategorySeeder` to test
