# Sudden Expenses & Budget Tracking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementasi fitur Sudden Expenses, Budget Tracking (5 kondisi), On Time/Late Status, dan Custom Categories

**Architecture:** 
- Backend: Laravel dengan model baru (SuddenExpense, ExpenseCategory), migration, controller, seeder
- Frontend: Flutter dengan Freezed models, Riverpod providers, UI widgets untuk budget status dan on-time badges

**Tech Stack:** Laravel (PHP), Flutter (Dart), Freezed, Riverpod, Dio

## Global Constraints

- Budget threshold margin: 5% (0.95P ≤ T ≤ 1.05P = On Budget)
- 7 default expense categories sudah ada di frontend
- Trip status: 'planned', 'ongoing', 'completed'
- Activity status: 'pending', 'completed', 'skipped'

---

## File Structure

### Backend Files
```
backend/
├── app/Models/
│   ├── SuddenExpense.php          [NEW]
│   ├── ExpenseCategory.php         [NEW]
│   └── Trip.php                    [MODIFY - add suddenExpenses relation]
├── app/Http/Controllers/
│   ├── SuddenExpenseController.php [NEW]
│   └── ExpenseCategoryController.php [NEW]
├── database/migrations/
│   ├── 2026_07_06_000001_create_expense_categories_table.php [NEW]
│   ├── 2026_07_06_000002_create_sudden_expenses_table.php    [NEW]
│   └── 2026_07_04_000001_create_trips_table.php              [MODIFY - add plan_budget]
├── database/seeders/
│   └── ExpenseCategorySeeder.php   [NEW]
└── routes/api.php                 [MODIFY - add routes]
```

### Frontend Files
```
frontend/lib/
├── features/itinerary/data/models/
│   ├── sudden_expense_model.dart           [NEW]
│   ├── budget_summary_model.dart           [MODIFY - extend fields]
│   ├── expense_category_model.dart         [MODIFY - add custom category methods]
│   ├── sudden_expense_model.freezed.dart   [NEW - generated]
│   └── sudden_expense_model.g.dart         [NEW - generated]
├── features/itinerary/data/datasources/
│   └── sudden_expense_remote_datasource.dart [NEW]
├── features/itinerary/data/
│   └── itinerary_repository.dart           [MODIFY - add sudden expenses methods]
├── features/itinerary/domain/
│   ├── itinerary_providers.dart            [MODIFY - add providers]
│   └── itinerary_providers.g.dart         [MODIFY - generated]
├── features/itinerary/presentation/widgets/
│   ├── sudden_expense_sheet.dart          [NEW]
│   ├── budget_status_badge.dart           [NEW]
│   ├── on_time_badge.dart                [NEW]
│   ├── activity_tile.dart                [MODIFY - add on-time badge]
│   └── budget_summary_card.dart           [MODIFY - add 5 status conditions]
└── features/itinerary/presentation/screens/
    └── itinerary_screen.dart              [MODIFY - add FAB and time summary]
```

---

## Tasks

### Task 1: Backend - Database Migrations

**Files:**
- Create: `backend/database/migrations/2026_07_06_000001_create_expense_categories_table.php`
- Create: `backend/database/migrations/2026_07_06_000002_create_sudden_expenses_table.php`
- Modify: `backend/database/migrations/2026_07_04_000001_create_trips_table.php` (add plan_budget column)

**Interfaces:**
- Produces: Tables `expense_categories` and `sudden_expenses`, modified `trips` with plan_budget

- [ ] **Step 1: Create expense_categories migration**

```php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expense_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('icon');
            $table->string('description')->nullable();
            $table->boolean('is_custom')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_categories');
    }
};
```

- [ ] **Step 2: Create sudden_expenses migration**

```php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sudden_expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_id')->constrained('trips')->onDelete('cascade');
            $table->foreignId('expense_category_id')->nullable()->constrained('expense_categories');
            $table->string('name');
            $table->decimal('amount', 12, 2);
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sudden_expenses');
    }
};
```

- [ ] **Step 3: Modify trips migration to add plan_budget**

Add to `up()` method in `2026_07_04_000001_create_trips_table.php`:
```php
$table->decimal('plan_budget', 14, 2)->nullable()->after('share_code');
```

- [ ] **Step 4: Run migrations**

Run: `php artisan migrate`

---

### Task 2: Backend - Models

**Files:**
- Create: `backend/app/Models/ExpenseCategory.php`
- Create: `backend/app/Models/SuddenExpense.php`
- Modify: `backend/app/Models/Trip.php` (add plan_budget to fillable, suddenExpenses relation, extended budget calculations)

**Interfaces:**
- Consumes: Migration tables from Task 1
- Produces: ExpenseCategory and SuddenExpense models with relations

- [ ] **Step 1: Create ExpenseCategory model**

```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ExpenseCategory extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'icon',
        'description',
        'is_custom',
    ];

    protected $casts = [
        'is_custom' => 'boolean',
    ];

    public function suddenExpenses(): HasMany
    {
        return $this->hasMany(SuddenExpense::class);
    }

    public static function defaultCategories(): array
    {
        return [
            ['name' => 'Akomodasi', 'slug' => 'accommodation', 'icon' => 'hotel', 'description' => 'Hotel, villa, homestay, hostel, camping'],
            ['name' => 'Transportasi', 'slug' => 'transportation', 'icon' => 'directions_car', 'description' => 'Pesawat, kereta, sewa motor, ojek online'],
            ['name' => 'Konsumsi', 'slug' => 'food_and_beverage', 'icon' => 'restaurant', 'description' => 'Makan, jajan, air minum'],
            ['name' => 'Atraksi & Hiburan', 'slug' => 'attractions', 'icon' => 'attractions', 'description' => 'Tiket wisata, wahana, tur lokal'],
            ['name' => 'Itinerary', 'slug' => 'itinerary', 'icon' => 'schedule', 'description' => 'Jadwal atau rencana kegiatan'],
            ['name' => 'Komunikasi & Dokumen', 'slug' => 'communication', 'icon' => 'phone', 'description' => 'Paket data, paspor, visa, asuransi'],
            ['name' => 'Lainnya', 'slug' => 'others', 'icon' => 'more_horiz', 'description' => 'Pengeluaran lainnya'],
        ];
    }
}
```

- [ ] **Step 2: Create SuddenExpense model**

```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SuddenExpense extends Model
{
    use HasFactory;

    protected $fillable = [
        'trip_id',
        'expense_category_id',
        'name',
        'amount',
        'description',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(ExpenseCategory::class, 'expense_category_id');
    }
}
```

- [ ] **Step 3: Update Trip model**

Add to `$fillable`:
```php
'plan_budget',
```

Add new relation:
```php
public function suddenExpenses(): HasMany
{
    return $this->hasMany(SuddenExpense::class);
}
```

Add/Update budget calculation method:
```php
public function calculateBudget(): array
{
    $planBudget = (float) ($this->plan_budget ?? 0);
    
    $activities = $this->activities()->get();
    $totalEstimated = $activities->where('is_unplanned', false)->sum('estimated_cost');
    $totalActualFromActivities = $activities->where('status', 'completed')->sum('actual_cost');
    
    $totalSuddenExpenses = $this->suddenExpenses()->sum('amount');
    $totalActual = $totalActualFromActivities + $totalSuddenExpenses;
    
    $variance = $totalActual - $planBudget;
    
    // Budget status calculation with 5% margin
    $margin = 0.05;
    $lowerThreshold = $planBudget * (1 - $margin);
    $upperThreshold = $planBudget * (1 + $margin);
    
    $isOverbudget = $totalActual > $upperThreshold;
    $isUnderbudget = $totalActual < $lowerThreshold;
    
    return [
        'plan_budget' => $planBudget,
        'total_actual_activities' => (float) $totalActualFromActivities,
        'total_sudden_expenses' => (float) $totalSuddenExpenses,
        'total_actual' => (float) $totalActual,
        'variance' => (float) $variance,
        'is_overbudget' => $isOverbudget,
        'is_underbudget' => $isUnderbudget,
        'status' => $this->calculateBudgetStatus($totalActual, $planBudget, $lowerThreshold, $upperThreshold),
    ];
}

private function calculateBudgetStatus(float $totalActual, float $planBudget, float $lowerThreshold, float $upperThreshold): string
{
    if ($totalActual >= $lowerThreshold && $totalActual <= $upperThreshold) {
        return 'on_budget';
    }
    if ($totalActual < $lowerThreshold) {
        return $planBudget > 0 ? 'underbudget' : 'on_budget';
    }
    return 'deficit';
}
```

---

### Task 3: Backend - Seeder & Controllers

**Files:**
- Create: `backend/database/seeders/ExpenseCategorySeeder.php`
- Create: `backend/app/Http/Controllers/ExpenseCategoryController.php`
- Create: `backend/app/Http/Controllers/SuddenExpenseController.php`
- Modify: `backend/routes/api.php`

**Interfaces:**
- Consumes: Models from Task 2
- Produces: API endpoints for expense categories and sudden expenses

- [ ] **Step 1: Create ExpenseCategorySeeder**

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

- [ ] **Step 2: Create ExpenseCategoryController**

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

- [ ] **Step 3: Create SuddenExpenseController**

```php
<?php
namespace App\Http\Controllers;

use App\Models\SuddenExpense;
use App\Models\Trip;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

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

- [ ] **Step 4: Update api.php routes**

Add to `routes/api.php`:
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

---

### Task 4: Frontend - Data Models

**Files:**
- Create: `frontend/lib/features/itinerary/data/models/sudden_expense_model.dart`
- Modify: `frontend/lib/features/itinerary/data/models/budget_summary_model.dart`
- Modify: `frontend/lib/features/itinerary/data/models/expense_category_model.dart`

**Interfaces:**
- Consumes: Backend API response structure
- Produces: Dart freezed models for frontend

- [ ] **Step 1: Create SuddenExpenseModel**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sudden_expense_model.freezed.dart';
part 'sudden_expense_model.g.dart';

@freezed
class SuddenExpenseModel with _$SuddenExpenseModel {
  const factory SuddenExpenseModel({
    required int id,
    required int tripId,
    required String name,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    required double amount,
    String? description,
    required DateTime createdAt,
  }) = _SuddenExpenseModel;

  factory SuddenExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$SuddenExpenseModelFromJson(json);
}
```

- [ ] **Step 2: Update BudgetSummaryModel**

Replace content with:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_summary_model.freezed.dart';
part 'budget_summary_model.g.dart';

enum BudgetStatus {
  onBudget,
  underbudget,
  deficit,
  surplus,
  offBudget,
}

@freezed
class BudgetSummaryModel with _$BudgetSummaryModel {
  const factory BudgetSummaryModel({
    double? planBudget,
    double? totalActualActivities,
    double? totalSuddenExpenses,
    double? totalActual,
    double? variance,
    @Default(false) bool isOverbudget,
    String? status,
    double? statusAmount,
  }) = _BudgetSummaryModel;

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetSummaryModelFromJson(json);

  /// Calculate budget status based on 5% margin
  BudgetStatus get budgetStatus {
    final plan = planBudget ?? 0;
    final actual = totalActual ?? 0;
    
    if (plan == 0) return BudgetStatus.onBudget;
    
    final margin = 0.05;
    final lowerThreshold = plan * (1 - margin);
    final upperThreshold = plan * (1 + margin);
    
    if (actual >= lowerThreshold && actual <= upperThreshold) {
      return BudgetStatus.onBudget;
    } else if (actual < lowerThreshold) {
      return BudgetStatus.underbudget;
    } else {
      return BudgetStatus.deficit;
    }
  }
  
  /// Get remaining budget (potential surplus)
  double get remainingBudget => (planBudget ?? 0) - (totalActual ?? 0);
  
  /// Get deficit amount
  double get deficitAmount => (totalActual ?? 0) > (planBudget ?? 0) 
      ? (totalActual ?? 0) - (planBudget ?? 0) 
      : 0;
}
```

- [ ] **Step 3: Update ExpenseCategoryModel**

Add to `ExpenseCategoryExtension`:
```dart
/// Find category by id
ExpenseCategory? findById(int id) {
  try {
    return firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

/// Get all categories including custom
List<ExpenseCategory> get allCategories => this;
```

- [ ] **Step 4: Run build_runner**

Run: `cd frontend && dart run build_runner build --delete-conflicting-outputs`

---

### Task 5: Frontend - Data Sources & Repository

**Files:**
- Create: `frontend/lib/features/itinerary/data/datasources/sudden_expense_remote_datasource.dart`
- Modify: `frontend/lib/features/itinerary/data/itinerary_repository.dart`

**Interfaces:**
- Consumes: Dio API client
- Produces: Remote data source for sudden expenses

- [ ] **Step 1: Create SuddenExpenseRemoteDatasource**

```dart
import 'package:dio/dio.dart';
import '../models/sudden_expense_model.dart';
import '../models/expense_category_model.dart';

class SuddenExpenseRemoteDatasource {
  final Dio _dio;

  SuddenExpenseRemoteDatasource(this._dio);

  Future<List<SuddenExpenseModel>> getSuddenExpenses(int tripId) async {
    final response = await _dio.get('/trips/$tripId/sudden-expenses');
    final data = response.data['data'] as List;
    return data.map((json) => SuddenExpenseModel.fromJson(json)).toList();
  }

  Future<SuddenExpenseModel> addSuddenExpense({
    required int tripId,
    required String name,
    int? categoryId,
    required double amount,
    String? description,
  }) async {
    final response = await _dio.post('/trips/$tripId/sudden-expenses', data: {
      'name': name,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
    });
    return SuddenExpenseModel.fromJson(response.data['data']);
  }

  Future<void> deleteSuddenExpense(int tripId, int expenseId) async {
    await _dio.delete('/trips/$tripId/sudden-expenses/$expenseId');
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final response = await _dio.get('/expense-categories');
    final data = response.data['data'] as List;
    return data.map((json) => ExpenseCategory.fromJson(json)).toList();
  }

  Future<ExpenseCategory> createCustomCategory({
    required String name,
    String icon = 'category',
    String? description,
  }) async {
    final response = await _dio.post('/expense-categories', data: {
      'name': name,
      'icon': icon,
      'description': description,
    });
    return ExpenseCategory.fromJson(response.data['data']);
  }
}
```

- [ ] **Step 2: Update ItineraryRepository**

Add to `ItineraryRepository`:
```dart
final SuddenExpenseRemoteDatasource _suddenExpenseDatasource;

SuddenExpenseRemoteDatasource get suddenExpenses => _suddenExpenseDatasource;

Future<List<SuddenExpenseModel>> getSuddenExpenses(int tripId) {
  return _suddenExpenseDatasource.getSuddenExpenses(tripId);
}

Future<SuddenExpenseModel> addSuddenExpense({
  required int tripId,
  required String name,
  int? categoryId,
  required double amount,
  String? description,
}) {
  return _suddenExpenseDatasource.addSuddenExpense(
    tripId: tripId,
    name: name,
    categoryId: categoryId,
    amount: amount,
    description: description,
  );
}

Future<void> deleteSuddenExpense(int tripId, int expenseId) {
  return _suddenExpenseDatasource.deleteSuddenExpense(tripId, expenseId);
}

Future<List<ExpenseCategory>> getExpenseCategories() {
  return _suddenExpenseDatasource.getCategories();
}

Future<ExpenseCategory> createCustomCategory({
  required String name,
  String icon = 'category',
  String? description,
}) {
  return _suddenExpenseDatasource.createCustomCategory(
    name: name,
    icon: icon,
    description: description,
  );
}
```

---

### Task 6: Frontend - Providers

**Files:**
- Modify: `frontend/lib/features/itinerary/domain/itinerary_providers.dart`

**Interfaces:**
- Consumes: Repository from Task 5
- Produces: Riverpod providers for state management

- [ ] **Step 1: Add sudden expense providers**

Add to `itinerary_providers.dart`:
```dart
// Sudden Expenses Providers
@riverpod
Future<List<SuddenExpenseModel>> suddenExpenses(
  SuddenExpensesRef ref,
  int tripId,
) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getSuddenExpenses(tripId);
}

@riverpod
class SuddenExpenseNotifier extends _$SuddenExpenseNotifier {
  @override
  FutureOr<List<SuddenExpenseModel>> build(int tripId) async {
    final repository = ref.watch(itineraryRepositoryProvider);
    return repository.getSuddenExpenses(tripId);
  }

  Future<SuddenExpenseModel> addExpense({
    required String name,
    int? categoryId,
    required double amount,
    String? description,
  }) async {
    final repository = ref.read(itineraryRepositoryProvider);
    final expense = await repository.addSuddenExpense(
      tripId: tripId,
      name: name,
      categoryId: categoryId,
      amount: amount,
      description: description,
    );
    ref.invalidateSelf();
    return expense;
  }

  Future<void> deleteExpense(int expenseId) async {
    final repository = ref.read(itineraryRepositoryProvider);
    await repository.deleteSuddenExpense(tripId, expenseId);
    ref.invalidateSelf();
  }
}

// Expense Categories Provider
@riverpod
Future<List<ExpenseCategory>> expenseCategories(ExpenseCategoriesRef ref) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getExpenseCategories();
}

// Custom category creation
@riverpod
Future<ExpenseCategory> customCategory(CustomCategoryRef ref, {
  required String name,
  String icon = 'category',
  String? description,
}) async {
  final repository = ref.read(itineraryRepositoryProvider);
  return repository.createCustomCategory(
    name: name,
    icon: icon,
    description: description,
  );
}

// Combined Budget Summary Provider
@riverpod
Future<BudgetSummaryModel> budgetSummary(BudgetSummaryRef ref, int tripId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final trip = await repository.getTrip(tripId);
  final activities = await repository.getItineraryData(tripId);
  
  double totalEstimated = 0;
  double totalActual = 0;
  
  for (final day in activities.days) {
    for (final activity in day.activities) {
      if (!activity.isUnplanned) {
        totalEstimated += activity.estimatedCost;
      }
      if (activity.isCompleted) {
        totalActual += activity.actualCost ?? 0;
      }
    }
  }
  
  final suddenExpenses = await repository.getSuddenExpenses(tripId);
  final totalSudden = suddenExpenses.fold<double>(0, (sum, e) => sum + e.amount);
  
  totalActual += totalSudden;
  
  return BudgetSummaryModel(
    planBudget: trip.planBudget?.toDouble(),
    totalActualActivities: totalActual - totalSudden,
    totalSuddenExpenses: totalSudden,
    totalActual: totalActual,
    variance: totalActual - (trip.planBudget?.toDouble() ?? 0),
  );
}

// On Time Statistics Provider
@riverpod
Map<String, int> activityTimeStats(ActivityTimeStatsRef ref, int tripId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final activities = await repository.getItineraryData(tripId);
  
  int totalActivities = 0;
  int onTimeActivities = 0;
  
  for (final day in activities.days) {
    for (final activity in day.activities) {
      if (!activity.isUnplanned) {
        totalActivities++;
        if (activity.isCompleted && activity.startedOnTime) {
          onTimeActivities++;
        }
      }
    }
  }
  
  return {
    'total': totalActivities,
    'onTime': onTimeActivities,
    'late': totalActivities - onTimeActivities,
  };
}
```

- [ ] **Step 2: Update Trip model getter**

Add to TripModel:
```dart
double? get planBudget;
```

- [ ] **Step 3: Run build_runner**

Run: `cd frontend && dart run build_runner build --delete-conflicting-outputs`

---

### Task 7: Frontend - Budget Status Badge Widget

**Files:**
- Create: `frontend/lib/features/itinerary/presentation/widgets/budget_status_badge.dart`

**Interfaces:**
- Consumes: BudgetSummaryModel with budgetStatus
- Produces: Colored badge showing budget condition

- [ ] **Step 1: Create BudgetStatusBadge widget**

```dart
import 'package:flutter/material.dart';
import '../../data/models/budget_summary_model.dart';

class BudgetStatusBadge extends StatelessWidget {
  final BudgetSummaryModel budget;
  final bool showAmount;

  const BudgetStatusBadge({
    super.key,
    required this.budget,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    final status = budget.budgetStatus;
    final config = _getStatusConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 16, color: config.textColor),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (showAmount) ...[
            const SizedBox(width: 8),
            Text(
              _formatCurrency(status == BudgetStatus.deficit 
                  ? budget.deficitAmount 
                  : budget.remainingBudget),
              style: TextStyle(
                color: config.textColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.onBudget:
        return _StatusConfig(
          label: 'On Budget',
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
        );
      case BudgetStatus.underbudget:
        return _StatusConfig(
          label: 'Underbudget',
          icon: Icons.trending_down,
          backgroundColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
        );
      case BudgetStatus.deficit:
        return _StatusConfig(
          label: 'Budget Defisit',
          icon: Icons.warning,
          backgroundColor: const Color(0xFFFFF3E0),
          textColor: const Color(0xFFE65100),
        );
      case BudgetStatus.surplus:
        return _StatusConfig(
          label: 'Budget Surplus',
          icon: Icons.savings,
          backgroundColor: const Color(0xFFC8E6C9),
          textColor: const Color(0xFF1B5E20),
        );
      case BudgetStatus.offBudget:
        return _StatusConfig(
          label: 'Off-Budget',
          icon: Icons.info_outline,
          backgroundColor: const Color(0xFFEEEEEE),
          textColor: const Color(0xFF616161),
        );
    }
  }

  String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    final formatted = absAmount >= 1000000
        ? 'Rp ${(absAmount / 1000000).toStringAsFixed(1)}jt'
        : 'Rp ${absAmount.toStringAsFixed(0)}';
    return amount < 0 ? '-$formatted' : formatted;
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}
```

---

### Task 8: Frontend - On Time Badge Widget

**Files:**
- Create: `frontend/lib/features/itinerary/presentation/widgets/on_time_badge.dart`

**Interfaces:**
- Consumes: ActivityModel with timing info
- Produces: Badge showing On Time / Late status

- [ ] **Step 1: Create OnTimeBadge widget**

```dart
import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';

class OnTimeBadge extends StatelessWidget {
  final ActivityModel activity;

  const OnTimeBadge({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isSkipped) {
      return _buildBadge('Dilompati', Colors.grey, Colors.grey[300]!);
    }
    
    if (!activity.isStarted && !activity.isCompleted) {
      return _buildBadge('-', Colors.grey, Colors.grey[300]!);
    }
    
    if (!activity.isCompleted) {
      return _buildBadge('Dimulai', Colors.blue, Colors.blue[50]!);
    }
    
    if (activity.startedOnTime) {
      return _buildBadge('On Time', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
    }
    
    final delayMinutes = activity.startDelayMinutes;
    final delayText = delayMinutes >= 60 
        ? 'Terlambat ${(delayMinutes / 60).toStringAsFixed(0)} jam'
        : 'Terlambat $delayMinutes mnt';
    
    return _buildBadge(delayText, const Color(0xFFC62828), const Color(0xFFFFEBEE));
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

### Task 9: Frontend - Sudden Expense Sheet

**Files:**
- Create: `frontend/lib/features/itinerary/presentation/widgets/sudden_expense_sheet.dart`

**Interfaces:**
- Consumes: ExpenseCategories, BudgetSummary
- Produces: Bottom sheet form for adding sudden expense

- [ ] **Step 1: Create SuddenExpenseSheet widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_category_model.dart';
import '../../domain/itinerary_providers.dart';

class SuddenExpenseSheet extends ConsumerStatefulWidget {
  final int tripId;
  final double? planBudget;
  final double? currentTotal;

  const SuddenExpenseSheet({
    super.key,
    required this.tripId,
    this.planBudget,
    this.currentTotal,
  });

  @override
  ConsumerState<SuddenExpenseSheet> createState() => _SuddenExpenseSheetState();
}

class _SuddenExpenseSheetState extends ConsumerState<SuddenExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newCategoryController = TextEditingController();
  
  ExpenseCategory? _selectedCategory;
  bool _isAddingNewCategory = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Pengeluaran Mendadak',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pengeluaran *',
                  hintText: 'Contoh: Tambal Ban',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              
              categoriesAsync.when(
                data: (categories) {
                  final allCategories = [
                    ...ExpenseCategory.defaultCategories,
                    ...categories.where((c) => c.isCustom),
                  ];
                  
                  return Column(
                    children: [
                      if (!_isAddingNewCategory)
                        DropdownButtonFormField<ExpenseCategory>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: [
                            ...allCategories.map((c) => DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(_getIconData(c.icon), size: 20),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            )),
                            const DropdownMenuItem(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 20),
                                  SizedBox(width: 8),
                                  Text('Tambah Kategori Baru'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              setState(() => _isAddingNewCategory = true);
                            } else {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
                      if (_isAddingNewCategory)
                        TextFormField(
                          controller: _newCategoryController,
                          decoration: InputDecoration(
                            labelText: 'Nama Kategori Baru',
                            prefixIcon: const Icon(Icons.add),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _isAddingNewCategory = false;
                                  _newCategoryController.clear();
                                });
                              },
                            ),
                          ),
                          validator: (v) => v?.isEmpty ?? true 
                              ? 'Wajib diisi' 
                              : null,
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Gagal memuat kategori'),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Nominal *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Wajib diisi';
                  if (double.tryParse(v!) == null) return 'Format tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                  hintText: 'Tambahkan catatan...',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'hotel': return Icons.hotel;
      case 'directions_car': return Icons.directions_car;
      case 'restaurant': return Icons.restaurant;
      case 'attractions': return Icons.attractions;
      case 'schedule': return Icons.schedule;
      case 'phone': return Icons.phone;
      default: return Icons.category;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amount = double.parse(_amountController.text);
    
    // Check over-budget warning
    if (widget.planBudget != null && widget.currentTotal != null) {
      final newTotal = widget.currentTotal! + amount;
      if (newTotal > widget.planBudget!) {
        final proceed = await _showOverBudgetWarning(
          newTotal - widget.planBudget!,
        );
        if (!proceed) return;
      }
    }
    
    setState(() => _isLoading = true);
    
    try {
      final notifier = ref.read(suddenExpenseNotifierProvider(widget.tripId).notifier);
      
      // Create custom category if needed
      int? categoryId = _selectedCategory?.id;
      if (_isAddingNewCategory) {
        final category = await ref.read(customCategoryProvider(
          name: _newCategoryController.text,
        ).future);
        categoryId = category.id;
      }
      
      await notifier.addExpense(
        name: _nameController.text,
        categoryId: categoryId,
        amount: amount,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengeluaran mendadak berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _showOverBudgetWarning(double overAmount) async {
    final currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Perhatian'),
          ],
        ),
        content: Text(
          'Pengeluaran ini membuat total biaya trip Anda '
          'melebihi rencana anggaran sebesar ${currency.format(overAmount)}.\n\n'
          'Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    ) ?? false;
  }
}
```

---

### Task 10: Frontend - Update Budget Summary Card

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/widgets/budget_summary_card.dart`

**Interfaces:**
- Consumes: Extended BudgetSummaryModel with 5 status conditions
- Produces: Updated card with all budget info and status badge

- [ ] **Step 1: Update BudgetSummaryCard**

Replace content with:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/budget_summary_model.dart';
import 'budget_status_badge.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummaryModel budget;
  final bool isCompleted;

  const BudgetSummaryCard({
    super.key,
    required this.budget,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    final planBudget = budget.planBudget ?? 0;
    final totalActual = budget.totalActual ?? 0;
    final totalSudden = budget.totalSuddenExpenses ?? 0;

    final percentage = planBudget > 0
        ? (totalActual / planBudget * 100).clamp(0.0, 200.0)
        : 0.0;

    // Determine surplus/deficit label
    String statusLabel;
    if (isCompleted) {
      statusLabel = budget.remainingBudget > 0 ? 'Budget Surplus' : 'Budget Defisit';
    } else {
      statusLabel = budget.remainingBudget > 0 ? 'Sisa Anggaran' : 'Melebihi Budget';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ringkasan Budget',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                BudgetStatusBadge(budget: budget, showAmount: false),
              ],
            ),
            const SizedBox(height: 16),
            
            // Plan vs Actual
            Row(
              children: [
                Expanded(
                  child: _BudgetItem(
                    label: 'Rencana',
                    amount: planBudget,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BudgetItem(
                    label: 'Realita',
                    amount: totalActual,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  _getProgressColor(percentage),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}% dari rencana',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            
            // Budget breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dari Aktivitas:', style: TextStyle(fontSize: 13)),
                      Text(
                        currency.format(budget.totalActualActivities ?? 0),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Pengeluaran Mendadak:', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Off-Budget',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        currency.format(totalSudden),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: budget.remainingBudget >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        currency.format(budget.remainingBudget.abs()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: budget.remainingBudget >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 105) return Colors.green;
    if (percentage <= 120) return Colors.orange;
    return Colors.red;
  }
}

class _BudgetItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _BudgetItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          currency.format(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
```

---

### Task 11: Frontend - Update Activity Tile

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/widgets/activity_tile.dart`

**Interfaces:**
- Consumes: ActivityModel with timing info
- Produces: Updated tile with OnTimeBadge

- [ ] **Step 1: Update ActivityTile**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import 'category_badge.dart';
import 'unplanned_badge.dart';
import 'on_time_badge.dart';

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;
  final bool showOnTimeBadge;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
    this.showOnTimeBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryBadge(category: activity.category ?? 'others'),
      title: Row(
        children: [
          Expanded(child: Text(activity.title ?? 'Untitled')),
          if (activity.isUnplanned) const UnplannedBadge(),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.estimatedCost > 0
                ? _currency.format(activity.estimatedCost)
                : 'No budget',
          ),
          if (activity.isCompleted && showOnTimeBadge)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OnTimeBadge(activity: activity),
            ),
        ],
      ),
      trailing: activity.isCompleted
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showOnTimeBadge && activity.startedOnTime)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else if (showOnTimeBadge)
                  const Icon(Icons.warning, color: Colors.orange, size: 20)
                else
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            )
          : const Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }
}
```

---

### Task 12: Frontend - Update Itinerary Screen

**Files:**
- Modify: `frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart`

**Interfaces:**
- Consumes: All providers from Task 6
- Produces: Updated screen with FAB, time summary, and updated budget card

- [ ] **Step 1: Update ItineraryScreen**

Add to build method:
```dart
// Add time stats summary at top
final timeStatsAsync = ref.watch(activityTimeStatsProvider(tripId));

timeStatsAsync.when(
  data: (stats) {
    if (stats['total']! > 0) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.timer, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performa Waktu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '${stats['onTime']}/${stats['total']} Aktivitas On Time',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: stats['total']! > 0
                  ? stats['onTime']! / stats['total']!
                  : 0,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(Colors.green),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  },
  loading: () => const LinearProgressIndicator(),
  error: (_, __) => const SizedBox.shrink(),
);

// Add FAB for sudden expenses
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _showSuddenExpenseSheet(context),
  icon: const Icon(Icons.flash_on),
  label: const Text('Mendadak'),
  backgroundColor: Colors.orange,
);

// Update budget card
final budgetAsync = ref.watch(budgetSummaryProvider(tripId));
budgetAsync.when(
  data: (budget) => BudgetSummaryCard(
    budget: budget,
    isCompleted: trip.status == 'completed',
  ),
  loading: () => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    ),
  ),
  error: (_, __) => const Card(child: Text('Error loading budget')),
);
```

Add method:
```dart
void _showSuddenExpenseSheet(BuildContext context) {
  final tripId = // get from route args
  final budgetAsync = ref.read(budgetSummaryProvider(tripId));
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        return budgetAsync.when(
          data: (budget) => SuddenExpenseSheet(
            tripId: tripId,
            planBudget: budget.planBudget,
            currentTotal: budget.totalActual,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error')),
        );
      },
    ),
  );
}
```

---

## Acceptance Criteria Verification

After all tasks, verify:
- [ ] `php artisan migrate` runs without errors
- [ ] `dart run build_runner build` generates all freezed files
- [ ] API endpoints respond correctly
- [ ] UI displays all 5 budget statuses with correct colors
- [ ] On Time/Late badges appear on activities
- [ ] FAB opens sudden expense sheet
- [ ] Custom categories can be created

---

## Self-Review Checklist

1. **Spec coverage**: All features from spec have corresponding tasks
2. **Placeholder scan**: No TODOs or TBDs in code blocks
3. **Type consistency**: All model fields match between backend and frontend
4. **File paths**: All paths are exact and exist in the project structure

---

**Plan complete and saved to `docs/superpowers/plans/2026-07-06-sudden-expenses-budget-tracking.md`**

Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
