# DNTrip Epic 3: Itinerary & Budget Tracking - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement itinerary days auto-generation, activities CRUD, budget tracking with variance calculation

**Architecture:** 
- Backend: Laravel 11 with Sanctum authentication
- Frontend: Flutter with Riverpod, Feature-First architecture
- Monorepo structure with `backend/` and `frontend/` directories

**Tech Stack:** Laravel 11, PHP 8.2+, Flutter 3.x, Riverpod, Dio, go_router, freezed

---

## Global Constraints

- Laravel 11
- Flutter SDK: >=3.0.0
- PHP: ^8.2
- Response format: `{ "status": "success"|"error", "data": {...}, "message": "..." }`
- Categories: transport, food, accommodation, tickets, shopping, others
- Activity status: pending, completed, skipped
- Currency: IDR (Rupiah)

---

## Part A: Backend (Laravel)

### Task A1: Database & Models

**Files:**
- Create: `backend/database/migrations/2026_07_05_000001_create_trip_days_table.php`
- Create: `backend/database/migrations/2026_07_05_000002_create_trip_activities_table.php`
- Create: `backend/app/Models/TripDay.php`
- Create: `backend/app/Models/TripActivity.php`
- Modify: `backend/app/Models/Trip.php`

---

- [ ] **Step 1: Create TripDay migration**

Create `backend/database/migrations/2026_07_05_000001_create_trip_days_table.php`:
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trip_days', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_id')->constrained('trips')->onDelete('cascade');
            $table->integer('day_number');
            $table->date('date');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trip_days');
    }
};
```

---

- [ ] **Step 2: Create TripActivity migration**

Create `backend/database/migrations/2026_07_05_000002_create_trip_activities_table.php`:
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trip_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_id')->constrained('trips')->onDelete('cascade');
            $table->foreignId('trip_day_id')->constrained('trip_days')->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('category', ['transport', 'food', 'accommodation', 'tickets', 'shopping', 'others'])->default('others');
            $table->decimal('estimated_cost', 12, 2)->default(0);
            $table->decimal('actual_cost', 12, 2)->nullable();
            $table->enum('status', ['pending', 'completed', 'skipped'])->default('pending');
            $table->boolean('is_unplanned')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trip_activities');
    }
};
```

---

- [ ] **Step 3: Create TripDay model**

Create `backend/app/Models/TripDay.php`:
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TripDay extends Model
{
    use HasFactory;

    protected $fillable = [
        'trip_id',
        'day_number',
        'date',
        'notes',
    ];

    protected $casts = [
        'date' => 'date',
    ];

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }

    public function activities(): HasMany
    {
        return $this->hasMany(TripActivity::class);
    }
}
```

---

- [ ] **Step 4: Create TripActivity model**

Create `backend/app/Models/TripActivity.php`:
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TripActivity extends Model
{
    use HasFactory;

    protected $fillable = [
        'trip_id',
        'trip_day_id',
        'title',
        'description',
        'category',
        'estimated_cost',
        'actual_cost',
        'status',
        'is_unplanned',
    ];

    protected $casts = [
        'estimated_cost' => 'decimal:2',
        'actual_cost' => 'decimal:2',
        'is_unplanned' => 'boolean',
    ];

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }

    public function tripDay(): BelongsTo
    {
        return $this->belongsTo(TripDay::class);
    }

    public function scopePlanned($query)
    {
        return $query->where('is_unplanned', false);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }
}
```

---

- [ ] **Step 5: Update Trip model**

Modify `backend/app/Models/Trip.php` - add methods:
```php
// Add after existing code in Trip model:

public function days(): HasMany
{
    return $this->hasMany(TripDay::class)->orderBy('day_number');
}

public function activities(): HasMany
{
    return $this->hasMany(TripActivity::class);
}

// Auto-generate days when trip is created
protected static function booted()
{
    static::created(function (Trip $trip) {
        if ($trip->start_date && $trip->end_date) {
            $trip->generateDays();
        }
    });
}

public function generateDays(): void
{
    if (!$this->start_date || !$this->end_date) return;

    $current = $this->start_date->copy();
    $dayNumber = 1;

    while ($current <= $this->end_date) {
        TripDay::create([
            'trip_id' => $this->id,
            'day_number' => $dayNumber,
            'date' => $current->format('Y-m-d'),
        ]);
        $current->addDay();
        $dayNumber++;
    }
}

// Budget calculations
public function calculateBudget(): array
{
    $activities = $this->activities()->get();

    $totalEstimated = $activities->where('is_unplanned', false)->sum('estimated_cost');
    $totalActual = $activities->where('status', 'completed')->sum('actual_cost');
    $variance = $totalActual - $totalEstimated;

    return [
        'total_estimated' => $totalEstimated,
        'total_actual' => $totalActual,
        'variance' => $variance,
        'is_overbudget' => $variance > 0,
    ];
}
```

---

- [ ] **Step 6: Run migrations**

Run:
```powershell
cd backend && php artisan migrate --force
```

---

### Task A2: Itinerary Controller

**Files:**
- Create: `backend/app/Http/Controllers/Api/ItineraryController.php`
- Modify: `backend/routes/api.php`

---

- [ ] **Step 1: Create ItineraryController**

Create `backend/app/Http/Controllers/Api/ItineraryController.php`:
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Trip;
use App\Models\TripDay;
use App\Models\TripActivity;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ItineraryController extends Controller
{
    /**
     * Get trip days with activities and budget summary
     */
    public function index(Request $request, int $tripId): JsonResponse
    {
        $trip = Trip::with(['days.activities'])->findOrFail($tripId);
        $this->checkAccess($request->user(), $trip);

        $days = $trip->days->map(function ($day) {
            return [
                'id' => $day->id,
                'day_number' => $day->day_number,
                'date' => $day->date->format('Y-m-d'),
                'notes' => $day->notes,
                'activities' => $day->activities->map(function ($activity) {
                    return [
                        'id' => $activity->id,
                        'title' => $activity->title,
                        'description' => $activity->description,
                        'category' => $activity->category,
                        'estimated_cost' => (int) $activity->estimated_cost,
                        'actual_cost' => $activity->actual_cost ? (int) $activity->actual_cost : null,
                        'status' => $activity->status,
                        'is_unplanned' => $activity->is_unplanned,
                    ];
                }),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => [
                'trip_id' => $trip->id,
                'budget_summary' => $trip->calculateBudget(),
                'days' => $days,
            ],
        ]);
    }

    /**
     * Create activity
     */
    public function createActivity(Request $request, int $tripId): JsonResponse
    {
        $trip = Trip::with('days')->findOrFail($tripId);
        $this->checkAccess($request->user(), $trip);
        $this->checkEditAccess($request->user(), $trip);

        $request->validate([
            'trip_day_id' => 'required|exists:trip_days,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|in:transport,food,accommodation,tickets,shopping,others',
            'estimated_cost' => 'nullable|numeric|min:0',
        ]);

        $tripDay = $trip->days()->findOrFail($request->trip_day_id);

        // Check if unplanned (added after the day has passed)
        $isUnplanned = now()->toDateString() >= $tripDay->date->format('Y-m-d');

        $activity = TripActivity::create([
            'trip_id' => $tripId,
            'trip_day_id' => $request->trip_day_id,
            'title' => $request->title,
            'description' => $request->description,
            'category' => $request->category,
            'estimated_cost' => $request->estimated_cost ?? 0,
            'status' => 'pending',
            'is_unplanned' => $isUnplanned,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => ['activity' => $this->formatActivity($activity)],
            'message' => 'Activity created successfully',
        ], 201);
    }

    /**
     * Update activity
     */
    public function updateActivity(Request $request, int $tripId, int $activityId): JsonResponse
    {
        $trip = Trip::findOrFail($tripId);
        $this->checkAccess($request->user(), $trip);
        $this->checkEditAccess($request->user(), $trip);

        $activity = TripActivity::where('trip_id', $tripId)->findOrFail($activityId);

        $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'sometimes|required|in:transport,food,accommodation,tickets,shopping,others',
            'estimated_cost' => 'nullable|numeric|min:0',
            'actual_cost' => 'nullable|numeric|min:0',
            'status' => 'sometimes|in:pending,completed,skipped',
        ]);

        $activity->update($request->validated());

        return response()->json([
            'status' => 'success',
            'data' => [
                'activity' => $this->formatActivity($activity->fresh()),
                'budget_summary' => $trip->fresh()->calculateBudget(),
            ],
            'message' => 'Activity updated successfully',
        ]);
    }

    /**
     * Mark activity as completed
     */
    public function completeActivity(Request $request, int $tripId, int $activityId): JsonResponse
    {
        $trip = Trip::findOrFail($tripId);
        $this->checkAccess($request->user(), $trip);
        $this->checkEditAccess($request->user(), $trip);

        $activity = TripActivity::where('trip_id', $tripId)->findOrFail($activityId);

        $request->validate([
            'actual_cost' => 'required|numeric|min:0',
        ]);

        $activity->update([
            'status' => 'completed',
            'actual_cost' => $request->actual_cost,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'activity' => $this->formatActivity($activity->fresh()),
                'budget_summary' => $trip->fresh()->calculateBudget(),
            ],
            'message' => 'Activity marked as completed',
        ]);
    }

    /**
     * Delete activity
     */
    public function deleteActivity(Request $request, int $tripId, int $activityId): JsonResponse
    {
        $trip = Trip::findOrFail($tripId);
        $this->checkAccess($request->user(), $trip);
        $this->checkEditAccess($request->user(), $trip);

        TripActivity::where('trip_id', $tripId)->findOrFail($activityId)->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Activity deleted successfully',
        ]);
    }

    // Helpers
    private function checkAccess($user, $trip): void
    {
        if ($trip->owner_id !== $user->id && !$trip->members()->where('user_id', $user->id)->exists()) {
            abort(403, 'Unauthorized access');
        }
    }

    private function checkEditAccess($user, $trip): void
    {
        if ($trip->owner_id !== $user->id && !$trip->members()->where('user_id', $user->id)->whereIn('role', ['owner', 'editor'])->exists()) {
            abort(403, 'Edit access required');
        }
    }

    private function formatActivity($activity): array
    {
        return [
            'id' => $activity->id,
            'title' => $activity->title,
            'description' => $activity->description,
            'category' => $activity->category,
            'estimated_cost' => (int) $activity->estimated_cost,
            'actual_cost' => $activity->actual_cost ? (int) $activity->actual_cost : null,
            'status' => $activity->status,
            'is_unplanned' => $activity->is_unplanned,
        ];
    }
}
```

---

- [ ] **Step 2: Add routes**

Modify `backend/routes/api.php`:
```php
// Add after trips routes:
Route::get('/trips/{id}/days', [ItineraryController::class, 'index']);
Route::post('/trips/{tripId}/activities', [ItineraryController::class, 'createActivity']);
Route::put('/trips/{tripId}/activities/{activityId}', [ItineraryController::class, 'updateActivity']);
Route::put('/trips/{tripId}/activities/{activityId}/complete', [ItineraryController::class, 'completeActivity']);
Route::delete('/trips/{tripId}/activities/{activityId}', [ItineraryController::class, 'deleteActivity']);
```

---

## Part B: Frontend (Flutter)

### Task B1: Models

**Files:**
- Create: `frontend/lib/features/itinerary/data/models/activity_model.dart`
- Create: `frontend/lib/features/itinerary/data/models/trip_day_model.dart`
- Create: `frontend/lib/features/itinerary/data/models/budget_summary_model.dart`
- Create: `frontend/lib/features/itinerary/data/models/itinerary_data.dart`

---

- [ ] **Step 1: Create ActivityModel**

Create `frontend/lib/features/itinerary/data/models/activity_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
class ActivityModel with _$ActivityModel {
  const factory ActivityModel({
    required int id,
    required String title,
    String? description,
    required String category,
    required int estimatedCost,
    int? actualCost,
    required String status,
    required bool isUnplanned,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isSkipped => status == 'skipped';
}
```

---

- [ ] **Step 2: Create TripDayModel**

Create `frontend/lib/features/itinerary/data/models/trip_day_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'activity_model.dart';

part 'trip_day_model.freezed.dart';
part 'trip_day_model.g.dart';

@freezed
class TripDayModel with _$TripDayModel {
  const factory TripDayModel({
    required int id,
    required int dayNumber,
    required String date,
    String? notes,
    @Default([]) List<ActivityModel> activities,
  }) = _TripDayModel;

  factory TripDayModel.fromJson(Map<String, dynamic> json) =>
      _$TripDayModelFromJson(json);
}
```

---

- [ ] **Step 3: Create BudgetSummaryModel**

Create `frontend/lib/features/itinerary/data/models/budget_summary_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_summary_model.freezed.dart';
part 'budget_summary_model.g.dart';

@freezed
class BudgetSummaryModel with _$BudgetSummaryModel {
  const factory BudgetSummaryModel({
    required int totalEstimated,
    required int totalActual,
    required int variance,
    required bool isOverbudget,
  }) = _BudgetSummaryModel;

  factory BudgetSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetSummaryModelFromJson(json);
}
```

---

- [ ] **Step 4: Create ItineraryData model**

Create `frontend/lib/features/itinerary/data/models/itinerary_data.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'trip_day_model.dart';
import 'budget_summary_model.dart';

part 'itinerary_data.freezed.dart';
part 'itinerary_data.g.dart';

@freezed
class ItineraryData with _$ItineraryData {
  const factory ItineraryData({
    required int tripId,
    required BudgetSummaryModel budgetSummary,
    @Default([]) List<TripDayModel> days,
  }) = _ItineraryData;

  factory ItineraryData.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDataFromJson(json);
}
```

---

- [ ] **Step 5: Run code generation**

Run:
```bash
cd frontend && flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Task B2: Data Layer

**Files:**
- Create: `frontend/lib/features/itinerary/data/datasources/itinerary_remote_datasource.dart`
- Create: `frontend/lib/features/itinerary/data/itinerary_repository.dart`

---

- [ ] **Step 1: Create ItineraryRemoteDatasource**

Create `frontend/lib/features/itinerary/data/datasources/itinerary_remote_datasource.dart`:
```dart
import 'package:dntrip/core/api/api_client.dart';
import '../models/itinerary_data.dart';
import '../models/activity_model.dart';

class ItineraryRemoteDatasource {
  final ApiClient _apiClient;

  ItineraryRemoteDatasource(this._apiClient);

  Future<ItineraryData> getItinerary(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/days');
    return ItineraryData.fromJson(response['data']);
  }

  Future<ActivityModel> createActivity({
    required int tripId,
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) async {
    final data = <String, dynamic>{
      'trip_day_id': tripDayId,
      'title': title,
      'category': category,
      'estimated_cost': estimatedCost ?? 0,
    };
    if (description != null) data['description'] = description;

    final response = await _apiClient.post('/trips/$tripId/activities', data: data);
    return ActivityModel.fromJson(response['data']['activity']);
  }

  Future<({ActivityModel activity, BudgetSummaryModel budget}) completeActivity({
    required int tripId,
    required int activityId,
    required int actualCost,
  }) async {
    final response = await _apiClient.post(
      '/trips/$tripId/activities/$activityId/complete',
      data: {'actual_cost': actualCost},
    );
    return (
      activity: ActivityModel.fromJson(response['data']['activity']),
      budget: BudgetSummaryModel.fromJson(response['data']['budget_summary']),
    );
  }

  Future<void> deleteActivity(int tripId, int activityId) async {
    await _apiClient.post('/trips/$tripId/activities/$activityId', data: {'_method': 'DELETE'});
  }
}
```

---

- [ ] **Step 2: Create ItineraryRepository**

Create `frontend/lib/features/itinerary/data/itinerary_repository.dart`:
```dart
import '../datasources/itinerary_remote_datasource.dart';
import '../models/itinerary_data.dart';
import '../models/activity_model.dart';
import '../models/budget_summary_model.dart';

class ItineraryRepository {
  final ItineraryRemoteDatasource _remote;

  ItineraryRepository(this._remote);

  Future<ItineraryData> getItinerary(int tripId) => _remote.getItinerary(tripId);

  Future<ActivityModel> createActivity({
    required int tripId,
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) =>
      _remote.createActivity(
        tripId: tripId,
        tripDayId: tripDayId,
        title: title,
        description: description,
        category: category,
        estimatedCost: estimatedCost,
      );

  Future<void> deleteActivity(int tripId, int activityId) =>
      _remote.deleteActivity(tripId, activityId);

  Future<({ActivityModel activity, BudgetSummaryModel budget}) completeActivity({
    required int tripId,
    required int activityId,
    required int actualCost,
  }) =>
      _remote.completeActivity(
        tripId: tripId,
        activityId: activityId,
        actualCost: actualCost,
      );
}
```

---

### Task B3: Providers

**Files:**
- Create: `frontend/lib/features/itinerary/domain/itinerary_providers.dart`

---

- [ ] **Step 1: Create ItineraryProviders**

Create `frontend/lib/features/itinerary/domain/itinerary_providers.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/datasources/itinerary_remote_datasource.dart';
import '../data/itinerary_repository.dart';
import '../data/models/itinerary_data.dart';
import '../data/models/activity_model.dart';
import '../data/models/budget_summary_model.dart';

part 'itinerary_providers.g.dart';

@riverpod
ItineraryRemoteDatasource itineraryRemoteDatasource(ItineraryRemoteDatasourceRef ref) {
  return ItineraryRemoteDatasource(ref.watch(apiClientProvider));
}

@riverpod
ItineraryRepository itineraryRepository(ItineraryRepositoryRef ref) {
  return ItineraryRepository(ref.watch(itineraryRemoteDatasourceProvider));
}

// Note: apiClient is inherited from auth/providers
@riverpod
ApiClient apiClient(ApiClientRef ref);

@riverpod
class ItineraryNotifier extends _$ItineraryNotifier {
  @override
  ItineraryData? build() => null;

  Future<void> loadItinerary(int tripId) async {
    state = await ref.read(itineraryRepositoryProvider).getItinerary(tripId);
  }

  Future<void> createActivity({
    required int tripDayId,
    required String title,
    String? description,
    required String category,
    int? estimatedCost,
  }) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).createActivity(
      tripId: tripId,
      tripDayId: tripDayId,
      title: title,
      description: description,
      category: category,
      estimatedCost: estimatedCost,
    );

    await loadItinerary(tripId);
  }

  Future<void> completeActivity({
    required int activityId,
    required int actualCost,
  }) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).completeActivity(
      tripId: tripId,
      activityId: activityId,
      actualCost: actualCost,
    );

    await loadItinerary(tripId);
  }

  Future<void> deleteActivity(int activityId) async {
    final tripId = state?.tripId;
    if (tripId == null) return;

    await ref.read(itineraryRepositoryProvider).deleteActivity(tripId, activityId);
    await loadItinerary(tripId);
  }
}
```

---

### Task B4: Widgets

**Files:**
- Create: `frontend/lib/features/itinerary/presentation/widgets/budget_summary_card.dart`
- Create: `frontend/lib/features/itinerary/presentation/widgets/activity_tile.dart`
- Create: `frontend/lib/features/itinerary/presentation/widgets/day_card.dart`
- Create: `frontend/lib/features/itinerary/presentation/widgets/category_badge.dart`
- Create: `frontend/lib/features/itinerary/presentation/widgets/unplanned_badge.dart`

---

- [ ] **Step 1: Create CategoryBadge**

Create `frontend/lib/features/itinerary/presentation/widgets/category_badge.dart`:
```dart
import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  IconData get icon {
    switch (category) {
      case 'transport': return Icons.directions_car;
      case 'food': return Icons.restaurant;
      case 'accommodation': return Icons.hotel;
      case 'tickets': return Icons.confirmation_number;
      case 'shopping': return Icons.shopping_bag;
      default: return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary);
  }
}
```

---

- [ ] **Step 2: Create UnplannedBadge**

Create `frontend/lib/features/itinerary/presentation/widgets/unplanned_badge.dart`:
```dart
import 'package:flutter/material.dart';

class UnplannedBadge extends StatelessWidget {
  const UnplannedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Unplanned', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
```

---

- [ ] **Step 3: Create BudgetSummaryCard**

Create `frontend/lib/features/itinerary/presentation/widgets/budget_summary_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../data/models/budget_summary_model.dart';
import 'package:intl/intl.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummaryModel budget;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  BudgetSummaryCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final percentage = budget.totalEstimated > 0
        ? (budget.totalActual / budget.totalEstimated * 100).clamp(0, 200)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.account_balance_wallet),
              const SizedBox(width: 8),
              Text('Budget Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Planned', style: Theme.of(context).textTheme.bodySmall),
                Text(_currency.format(budget.totalEstimated)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Actual', style: Theme.of(context).textTheme.bodySmall),
                Text(_currency.format(budget.totalActual)),
              ]),
            ]),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(budget.isOverbudget ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 8),
            if (budget.isOverbudget)
              Text('Overbudget: ${_currency.format(budget.variance)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
            else
              const Text('On track', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 4: Create ActivityTile**

Create `frontend/lib/features/itinerary/presentation/widgets/activity_tile.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';
import 'category_badge.dart';
import 'unplanned_badge.dart';

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  ActivityTile({super.key, required this.activity, required this.onTap});

  @override
  Widget build(Build context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryBadge(category: activity.category),
      title: Row(children: [
        Expanded(child: Text(activity.title)),
        if (activity.isUnplanned) const UnplannedBadge(),
      ]),
      subtitle: Text(activity.estimatedCost > 0 ? _currency.format(activity.estimatedCost) : 'No budget'),
      trailing: activity.isCompleted
          ? Icon(Icons.check_circle, color: Colors.green)
          : Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }
}
```

---

- [ ] **Step 5: Create DayCard**

Create `frontend/lib/features/itinerary/presentation/widgets/day_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../data/models/trip_day_model.dart';
import 'activity_tile.dart';

class DayCard extends StatelessWidget {
  final TripDayModel day;
  final Function(int activityId) onActivityTap;
  final VoidCallback onAddActivity;

  DayCard({super.key, required this.day, required this.onActivityTap, required this.onAddActivity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('Day ${day.dayNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(day.date),
        initiallyExpanded: true,
        children: [
          if (day.notes != null) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(day.notes!, style: Theme.of(context).textTheme.bodySmall),
          ),
          ...day.activities.map((a) => ActivityTile(
            activity: a,
            onTap: () => onActivityTap(a.id),
          )),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.green),
            title: const Text('Add Activity', style: TextStyle(color: Colors.green)),
            onTap: onAddActivity,
          ),
        ],
      ),
    );
  }
}
```

---

### Task B5: Screens & Sheets

**Files:**
- Create: `frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart`
- Create: `frontend/lib/features/itinerary/presentation/screens/activity_form_screen.dart`
- Create: `frontend/lib/features/itinerary/presentation/screens/activity_complete_sheet.dart`

---

- [ ] **Step 1: Create ActivityCompleteSheet**

Create `frontend/lib/features/itinerary/presentation/screens/activity_complete_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_model.dart';

class ActivityCompleteSheet extends StatefulWidget {
  final ActivityModel activity;
  final Function(int actualCost) onComplete;

  const ActivityCompleteSheet({super.key, required this.activity, required this.onComplete});

  @override
  State<ActivityCompleteSheet> createState() => _ActivityCompleteSheetState();
}

class _ActivityCompleteSheetState extends State<ActivityCompleteSheet> {
  late final TextEditingController _costCtrl;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _costCtrl = TextEditingController(
      text: widget.activity.estimatedCost.toString(),
    );
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mark Activity Complete', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text(widget.activity.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Estimated: ${_currency.format(widget.activity.estimatedCost)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Actual Cost',
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final cost = int.tryParse(_costController.text) ?? 0;
              widget.onComplete(cost);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
```

---

- [ ] **Step 2: Create ActivityFormScreen**

Create `frontend/lib/features/itinerary/presentation/screens/activity_form_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/itinerary_providers.dart';
import '../../data/models/trip_day_model.dart';

class ActivityFormScreen extends ConsumerStatefulWidget {
  final int tripDayId;
  final TripDayModel day;

  const ActivityFormScreen({super.key, required this.tripDayId, required this.day});

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String _category = 'others';

  final _categories = [
    ('transport', 'Transport'),
    ('food', 'Food'),
    ('accommodation', 'Accommodation'),
    ('tickets', 'Tickets'),
    ('shopping', 'Shopping'),
    ('others', 'Others'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(itineraryNotifierProvider.notifier).createActivity(
      tripDayId: widget.tripDayId,
      title: _titleCtrl.text,
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
      category: _category,
      estimatedCost: int.tryParse(_costCtrl.text),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title *'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2))).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'others'),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _costCtrl, decoration: const InputDecoration(labelText: 'Estimated Cost', prefixText: 'Rp '), keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _submit, child: const Text('Add Activity')),
          ],
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 3: Create ItineraryScreen**

Create `frontend/lib/features/itinerary/presentation/screens/itinerary_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/itinerary_providers.dart';
import '../widgets/budget_summary_card.dart';
import '../screens/day_card.dart';
import '../screens/activity_complete_sheet.dart';
import '../screens/activity_form_screen.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  final int tripId;

  const ItineraryScreen({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId));
  }

  void _showCompleteSheet(int activityId) {
    final activity = ref.read(itineraryNotifierProvider)?.days
        .expand((d) => d.activities)
        .firstWhere((a) => a.id == activityId);

    if (activity == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ActivityCompleteSheet(
        activity: activity,
        onComplete: (cost) {
          ref.read(itineraryNotifierProvider.notifier).completeActivity(
            activityId: activityId,
            actualCost: cost,
          );
        },
      ),
    );
  }

  void _navigateToAddActivity(int tripDayId, day) {
    context.push('/trips/${widget.tripId}/activities/new?dayId=$tripDayId');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(itineraryNotifierProvider);

    if (data == null) {
      return Scaffold(appBar: AppBar(title: const Text('Itinerary')), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(itineraryNotifierProvider.notifier).loadItinerary(widget.tripId),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BudgetSummaryCard(budget: data.budgetSummary),
            ),
            ...data.days.map((day) => DayCard(
              day: day,
              onActivityTap: _showCompleteSheet,
              onAddActivity: () => _navigateToAddActivity(day.id, day),
            )),
          ],
        ),
      ),
    );
  }
}
```

---

### Task B6: Navigation Integration

**Files:**
- Modify: `frontend/lib/core/router/app_router.dart`

---

- [ ] **Step 1: Update Router**

Modify `frontend/lib/core/router/app_router.dart`:
```dart
// Add import:
import '../../features/itinerary/presentation/screens/itinerary_screen.dart';

// Add routes:
GoRoute(path: '/trips/:id/itinerary', builder: (_, state) => ItineraryScreen(tripId: int.parse(state.pathParameters['id']!))),
```

---

- [ ] **Step 2: Run code generation & verify**

Run:
```bash
cd frontend && flutter pub run build_runner build --delete-conflicting-outputs && flutter analyze
```

---

## Verification Checklist

### Backend
- [ ] Days auto-generated on trip create
- [ ] Activities CRUD works
- [ ] Budget calculations correct
- [ ] Unplanned detection works

### Frontend
- [ ] Itinerary displays correctly
- [ ] Activity form works
- [ ] Complete sheet works
- [ ] Budget card shows correct values

---

*Implementation plan v1.0 - 2026-07-05*
