# DNTrip Epic 2: Trip Management + Members - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement complete trip management system with CRUD, share codes, and member collaboration

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
- Share code: 6-character alphanumeric (uppercase)
- Status values: 'planned', 'ongoing', 'completed'
- Role values: 'owner', 'editor', 'viewer'
- Date format: YYYY-MM-DD

---

## Part A: Backend (Laravel)

### Task A1: Database Migrations

**Files:**
- Create: `backend/database/migrations/2026_07_04_000001_create_trips_table.php`
- Create: `backend/database/migrations/2026_07_04_000002_create_trip_members_table.php`

---

- [ ] **Step 1: Create trips migration**

Create `backend/database/migrations/2026_07_04_000001_create_trips_table.php`:
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trips', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->onDelete('cascade');
            $table->string('title');
            $table->string('destination')->nullable();
            $table->text('description')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->string('share_code', 10)->unique()->nullable();
            $table->enum('status', ['planned', 'ongoing', 'completed'])->default('planned');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trips');
    }
};
```

---

- [ ] **Step 2: Create trip_members migration**

Create `backend/database/migrations/2026_07_04_000002_create_trip_members_table.php`:
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trip_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_id')->constrained('trips')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('role', ['owner', 'editor', 'viewer'])->default('viewer');
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();

            $table->unique(['trip_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trip_members');
    }
};
```

---

- [ ] **Step 3: Run migrations**

Run:
```powershell
cd backend && php artisan migrate --force
```

Expected: 2 new tables created

---

### Task A2: Trip Model

**Files:**
- Create: `backend/app/Models/Trip.php`
- Modify: `backend/app/Models/User.php`

---

- [ ] **Step 1: Create Trip model**

Create `backend/app/Models/Trip.php`:
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Trip extends Model
{
    use HasFactory;

    protected $fillable = [
        'owner_id',
        'title',
        'destination',
        'description',
        'start_date',
        'end_date',
        'share_code',
        'status',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function members(): HasMany
    {
        return $this->hasMany(TripMember::class);
    }

    public function getMembersCountAttribute(): int
    {
        return $this->members()->count();
    }

    /**
     * Generate unique share code
     */
    public static function generateShareCode(): string
    {
        $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        $length = 6;

        do {
            $code = '';
            for ($i = 0; $i < $length; $i++) {
                $code .= $characters[random_int(0, strlen($characters) - 1)];
            }
        } while (self::where('share_code', $code)->exists());

        return $code;
    }

    /**
     * Auto-update status based on dates
     */
    public function updateStatusFromDates(): void
    {
        $today = now()->toDateString();
        $startDate = $this->start_date?->toDateString();
        $endDate = $this->end_date?->toDateString();

        if ($this->status === 'completed') {
            return; // Don't auto-change if already completed
        }

        if ($endDate && $today > $endDate) {
            $this->update(['status' => 'completed']);
        } elseif ($startDate && $today >= $startDate && $this->status === 'planned') {
            $this->update(['status' => 'ongoing']);
        }
    }
}
```

---

- [ ] **Step 2: Create TripMember model**

Create `backend/app/Models/TripMember.php`:
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TripMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'trip_id',
        'user_id',
        'role',
        'joined_at',
    ];

    protected $casts = [
        'joined_at' => 'datetime',
    ];

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isOwner(): bool
    {
        return $this->role === 'owner';
    }

    public function isEditor(): bool
    {
        return in_array($this->role, ['owner', 'editor']);
    }

    public function canEdit(): bool
    {
        return in_array($this->role, ['owner', 'editor']);
    }

    public function canManageMembers(): bool
    {
        return $this->role === 'owner';
    }
}
```

---

- [ ] **Step 3: Update User model**

Modify `backend/app/Models/User.php` - add relationships:
```php
// Add to User model after existing code:

public function ownedTrips(): HasMany
{
    return $this->hasMany(Trip::class, 'owner_id');
}

public function tripMemberships(): HasMany
{
    return $this->hasMany(TripMember::class);
}

public function trips(): Builder
{
    return Trip::where('owner_id', $this->id)
        ->orWhereHas('members', function ($query) {
            $query->where('user_id', $this->id);
        });
}
```

---

### Task A3: Form Requests

**Files:**
- Create: `backend/app/Http/Requests/CreateTripRequest.php`
- Create: `backend/app/Http/Requests/UpdateTripRequest.php`
- Create: `backend/app/Http/Requests/JoinTripRequest.php`

---

- [ ] **Step 1: Create CreateTripRequest**

Create `backend/app/Http/Requests/CreateTripRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class CreateTripRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'min:1', 'max:255'],
            'destination' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'start_date' => ['required', 'date', 'after_or_equal:today'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Trip title is required',
            'start_date.required' => 'Start date is required',
            'start_date.after_or_equal' => 'Start date must be today or later',
            'end_date.required' => 'End date is required',
            'end_date.after_or_equal' => 'End date must be after or equal to start date',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

- [ ] **Step 2: Create UpdateTripRequest**

Create `backend/app/Http/Requests/UpdateTripRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class UpdateTripRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'required', 'string', 'min:1', 'max:255'],
            'destination' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'start_date' => ['sometimes', 'required', 'date'],
            'end_date' => ['sometimes', 'required', 'date', 'after_or_equal:start_date'],
            'status' => ['sometimes', 'in:planned,ongoing,completed'],
        ];
    }

    public function messages(): array
    {
        return [
            'status.in' => 'Invalid status. Must be: planned, ongoing, or completed',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

- [ ] **Step 3: Create JoinTripRequest**

Create `backend/app/Http/Requests/JoinTripRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class JoinTripRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'share_code' => ['required', 'string', 'size:6'],
        ];
    }

    public function messages(): array
    {
        return [
            'share_code.required' => 'Share code is required',
            'share_code.size' => 'Share code must be 6 characters',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

### Task A4: Trip Controller

**Files:**
- Create: `backend/app/Http/Controllers/Api/TripController.php`
- Modify: `backend/routes/api.php`

---

- [ ] **Step 1: Create TripController**

Create `backend/app/Http/Controllers/Api/TripController.php`:
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CreateTripRequest;
use App\Http\Requests\UpdateTripRequest;
use App\Http\Requests\JoinTripRequest;
use App\Models\Trip;
use App\Models\TripMember;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TripController extends Controller
{
    /**
     * List user's trips
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $trips = Trip::where('owner_id', $user->id)
            ->orWhereHas('members', function ($query) use ($user) {
                $query->where('user_id', $user->id);
            })
            ->with('owner')
            ->withCount('members')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => ['trips' => $trips],
        ]);
    }

    /**
     * Create new trip
     */
    public function store(CreateTripRequest $request): JsonResponse
    {
        $user = $request->user();

        $trip = Trip::create([
            'owner_id' => $user->id,
            'title' => $request->title,
            'destination' => $request->destination,
            'description' => $request->description,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'share_code' => Trip::generateShareCode(),
            'status' => 'planned',
        ]);

        // Add owner as member
        TripMember::create([
            'trip_id' => $trip->id,
            'user_id' => $user->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        $trip->load('owner');
        $trip->load('members');

        return response()->json([
            'status' => 'success',
            'data' => ['trip' => $trip],
            'message' => 'Trip created successfully',
        ], 201);
    }

    /**
     * Get trip detail
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $trip = Trip::with(['owner', 'members.user'])
            ->findOrFail($id);

        // Check if user has access
        if (!$this->userHasAccess($user, $trip)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized access to this trip',
            ], 403);
        }

        // Auto-update status from dates
        $trip->updateStatusFromDates();
        $trip->refresh();

        return response()->json([
            'status' => 'success',
            'data' => ['trip' => $trip],
        ]);
    }

    /**
     * Update trip
     */
    public function update(UpdateTripRequest $request, int $id): JsonResponse
    {
        $user = $request->user();
        $trip = Trip::findOrFail($id);

        // Check permission
        $membership = $this->getMembership($user, $trip);
        if (!$membership || !$membership->canEdit()) {
            return response()->json([
                'status' => 'error',
                'message' => 'You do not have permission to edit this trip',
            ], 403);
        }

        // Validate status change to 'planned'
        if ($request->has('status') && $request->status === 'planned') {
            $today = now()->toDateString();
            $startDate = $trip->start_date?->toDateString();
            if ($startDate && $today > $startDate) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Cannot set status to planned if trip has already started',
                ], 422);
            }
        }

        $trip->update($request->validated());

        return response()->json([
            'status' => 'success',
            'data' => ['trip' => $trip->fresh(['owner', 'members'])],
            'message' => 'Trip updated successfully',
        ]);
    }

    /**
     * Delete trip
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $trip = Trip::findOrFail($id);

        // Only owner can delete
        if ($trip->owner_id !== $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Only the owner can delete this trip',
            ], 403);
        }

        $trip->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Trip deleted successfully',
        ]);
    }

    /**
     * Join trip via share code
     */
    public function join(JoinTripRequest $request): JsonResponse
    {
        $user = $request->user();
        $shareCode = strtoupper($request->share_code);

        $trip = Trip::where('share_code', $shareCode)->first();

        if (!$trip) {
            return response()->json([
                'status' => 'error',
                'message' => 'Trip not found with this share code',
            ], 404);
        }

        // Check if already a member
        $existingMembership = TripMember::where('trip_id', $trip->id)
            ->where('user_id', $user->id)
            ->first();

        if ($existingMembership) {
            return response()->json([
                'status' => 'error',
                'message' => 'You have already joined this trip',
            ], 409);
        }

        // Check if user is the owner
        if ($trip->owner_id === $user->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'You are already the owner of this trip',
            ], 409);
        }

        // Add as editor by default
        $membership = TripMember::create([
            'trip_id' => $trip->id,
            'user_id' => $user->id,
            'role' => 'editor',
            'joined_at' => now(),
        ]);

        $trip->load('owner');
        $trip->load('members');

        return response()->json([
            'status' => 'success',
            'data' => [
                'trip' => $trip,
                'role' => $membership->role,
            ],
            'message' => 'Joined trip successfully',
        ]);
    }

    /**
     * List trip members
     */
    public function members(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $trip = Trip::with('members.user')->findOrFail($id);

        if (!$this->userHasAccess($user, $trip)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized access',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['members' => $trip->members->map(function ($m) {
                return [
                    'id' => $m->user->id,
                    'name' => $m->user->name,
                    'email' => $m->user->email,
                    'role' => $m->role,
                ];
            })],
        ]);
    }

    /**
     * Update member role
     */
    public function updateMemberRole(Request $request, int $id, int $userId): JsonResponse
    {
        $requestingUser = $request->user();
        $trip = Trip::findOrFail($id);

        // Only owner can update roles
        if ($trip->owner_id !== $requestingUser->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Only the owner can change member roles',
            ], 403);
        }

        // Cannot change owner's role
        if ($userId === $trip->owner_id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cannot change owner role',
            ], 422);
        }

        $membership = TripMember::where('trip_id', $id)
            ->where('user_id', $userId)
            ->firstOrFail();

        $request->validate([
            'role' => ['required', 'in:editor,viewer'],
        ]);

        $membership->update(['role' => $request->role]);

        return response()->json([
            'status' => 'success',
            'data' => ['member' => $membership->fresh('user')],
            'message' => 'Member role updated',
        ]);
    }

    /**
     * Remove member from trip
     */
    public function removeMember(Request $request, int $id, int $userId): JsonResponse
    {
        $requestingUser = $request->user();
        $trip = Trip::findOrFail($id);

        // Only owner can remove members
        if ($trip->owner_id !== $requestingUser->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Only the owner can remove members',
            ], 403);
        }

        // Cannot remove owner
        if ($userId === $trip->owner_id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Cannot remove trip owner',
            ], 422);
        }

        TripMember::where('trip_id', $id)
            ->where('user_id', $userId)
            ->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Member removed successfully',
        ]);
    }

    // Helper methods
    private function userHasAccess($user, $trip): bool
    {
        if ($trip->owner_id === $user->id) {
            return true;
        }

        return TripMember::where('trip_id', $trip->id)
            ->where('user_id', $user->id)
            ->exists();
    }

    private function getMembership($user, $trip): ?TripMember
    {
        if ($trip->owner_id === $user->id) {
            $member = new TripMember();
            $member->role = 'owner';
            return $member;
        }

        return TripMember::where('trip_id', $trip->id)
            ->where('user_id', $user->id)
            ->first();
    }
}
```

---

- [ ] **Step 2: Add routes**

Edit `backend/routes/api.php`:
```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TripController;
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
});
```

---

- [ ] **Step 3: Test backend**

Start server and test endpoints:
```powershell
cd backend && php artisan serve
```

---

## Part B: Frontend (Flutter)

### Task B1: Trip Data Layer

**Files:**
- Create: `frontend/lib/features/trips/data/models/trip_model.dart`
- Create: `frontend/lib/features/trips/data/models/trip_member_model.dart`
- Create: `frontend/lib/features/trips/data/datasources/trip_remote_datasource.dart`
- Create: `frontend/lib/features/trips/data/trip_repository.dart`

---

- [ ] **Step 1: Create TripMemberModel**

Create `frontend/lib/features/trips/data/models/trip_member_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_member_model.freezed.dart';
part 'trip_member_model.g.dart';

@freezed
class TripMemberModel with _$TripMemberModel {
  const TripMemberModel._();

  const factory TripMemberModel({
    required int id,
    required String name,
    String? email,
    required String role,
  }) = _TripMemberModel;

  factory TripMemberModel.fromJson(Map<String, dynamic> json) =>
      _$TripMemberModelFromJson(json);

  bool get isOwner => role == 'owner';
  bool get isEditor => role == 'owner' || role == 'editor';
}
```

---

- [ ] **Step 2: Create TripModel**

Create `frontend/lib/features/trips/data/models/trip_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'trip_member_model.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
class TripModel with _$TripModel {
  const TripModel._();

  const factory TripModel({
    required int id,
    required String title,
    String? destination,
    String? description,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'share_code') required String shareCode,
    required String status,
    required UserModel owner,
    @Default([]) List<TripMemberModel> members,
    @JsonKey(name: 'members_count') int? membersCount,
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);
}

// Import placeholder - will be replaced with actual UserModel
class UserModel {
  final int id;
  final String name;
  UserModel({required this.id, required this.name});
}
```

---

- [ ] **Step 3: Create TripRemoteDatasource**

Create `frontend/lib/features/trips/data/datasources/trip_remote_datasource.dart`:
```dart
import '../../../../core/api/api_client.dart';
import '../models/trip_model.dart';
import '../models/trip_member_model.dart';

class TripRemoteDatasource {
  final ApiClient _apiClient;

  TripRemoteDatasource(this._apiClient);

  Future<List<TripModel>> getTrips() async {
    final response = await _apiClient.get('/trips');
    final tripsData = response['data']['trips'] as List;
    return tripsData.map((e) => TripModel.fromJson(e)).toList();
  }

  Future<TripModel> getTrip(int id) async {
    final response = await _apiClient.get('/trips/$id');
    return TripModel.fromJson(response['data']['trip']);
  }

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiClient.post('/trips', data: {
      'title': title,
      'destination': destination,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
    });
    return TripModel.fromJson(response['data']['trip']);
  }

  Future<TripModel> updateTrip({
    required int id,
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (destination != null) data['destination'] = destination;
    if (description != null) data['description'] = description;
    if (startDate != null) data['start_date'] = startDate;
    if (endDate != null) data['end_date'] = endDate;
    if (status != null) data['status'] = status;

    final response = await _apiClient.post('/trips/$id', data: data);
    return TripModel.fromJson(response['data']['trip']);
  }

  Future<void> deleteTrip(int id) async {
    await _apiClient.post('/trips/$id', data: {'_method': 'DELETE'});
  }

  Future<({TripModel trip, String role})> joinTrip(String shareCode) async {
    final response = await _apiClient.post('/trips/join', data: {
      'share_code': shareCode,
    });
    return (
      trip: TripModel.fromJson(response['data']['trip']),
      role: response['data']['role'] as String,
    );
  }

  Future<List<TripMemberModel>> getMembers(int tripId) async {
    final response = await _apiClient.get('/trips/$tripId/members');
    final membersData = response['data']['members'] as List;
    return membersData.map((e) => TripMemberModel.fromJson(e)).toList();
  }

  Future<void> updateMemberRole(int tripId, int userId, String role) async {
    await _apiClient.put('/trips/$tripId/members/$userId/role', data: {
      'role': role,
    });
  }

  Future<void> removeMember(int tripId, int userId) async {
    await _apiClient.post('/trips/$tripId/members/$userId', data: {
      '_method': 'DELETE',
    });
  }
}
```

---

- [ ] **Step 4: Create TripRepository**

Create `frontend/lib/features/trips/data/trip_repository.dart`:
```dart
import '../datasources/trip_remote_datasource.dart';
import '../models/trip_model.dart';
import '../models/trip_member_model.dart';

class TripRepository {
  final TripRemoteDatasource _remoteDatasource;

  TripRepository(this._remoteDatasource);

  Future<List<TripModel>> getTrips() => _remoteDatasource.getTrips();
  Future<TripModel> getTrip(int id) => _remoteDatasource.getTrip(id);

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
  }) =>
      _remoteDatasource.createTrip(
        title: title,
        destination: destination,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );

  Future<TripModel> updateTrip({
    required int id,
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
  }) =>
      _remoteDatasource.updateTrip(
        id: id,
        title: title,
        destination: destination,
        description: description,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

  Future<void> deleteTrip(int id) => _remoteDatasource.deleteTrip(id);
  Future<({TripModel trip, String role})> joinTrip(String shareCode) =>
      _remoteDatasource.joinTrip(shareCode);
  Future<List<TripMemberModel>> getMembers(int tripId) =>
      _remoteDatasource.getMembers(tripId);
  Future<void> updateMemberRole(int tripId, int userId, String role) =>
      _remoteDatasource.updateMemberRole(tripId, userId, role);
  Future<void> removeMember(int tripId, int userId) =>
      _remoteDatasource.removeMember(tripId, userId);
}
```

---

### Task B2: Trip Providers

**Files:**
- Create: `frontend/lib/features/trips/domain/trip_providers.dart`

---

- [ ] **Step 1: Create TripProviders**

Create `frontend/lib/features/trips/domain/trip_providers.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/datasources/trip_remote_datasource.dart';
import '../data/trip_repository.dart';
import '../data/models/trip_model.dart';
import '../data/models/trip_member_model.dart';

part 'trip_providers.g.dart';

// Base providers
@riverpod
TripRemoteDatasource tripRemoteDatasource(TripRemoteDatasourceRef ref) {
  return TripRemoteDatasource(ref.watch(apiClientProvider));
}

@riverpod
TripRepository tripRepository(TripRepositoryRef ref) {
  return TripRepository(ref.watch(tripRemoteDatasourceProvider));
}

// Import from auth
@riverpod
ApiClient apiClient(ApiClientRef ref);

// Trip list state
sealed class TripsState {
  const TripsState();
}

class TripsLoading extends TripsState {
  const TripsLoading();
}

class TripsLoaded extends TripsState {
  final List<TripModel> trips;
  const TripsLoaded(this.trips);
}

class TripsError extends TripsState {
  final String message;
  const TripsError(this.message);
}

@riverpod
class TripsNotifier extends _$TripsNotifier {
  @override
  TripsState build() => const TripsLoading();

  Future<void> loadTrips() async {
    state = const TripsLoading();
    try {
      final trips = await ref.read(tripRepositoryProvider).getTrips();
      state = TripsLoaded(trips);
    } catch (e) {
      state = TripsError(e.toString());
    }
  }

  Future<TripModel> createTrip({
    required String title,
    String? destination,
    String? description,
    required String startDate,
    required String endDate,
  }) async {
    final trip = await ref.read(tripRepositoryProvider).createTrip(
          title: title,
          destination: destination,
          description: description,
          startDate: startDate,
          endDate: endDate,
        );
    await loadTrips();
    return trip;
  }

  Future<void> deleteTrip(int id) async {
    await ref.read(tripRepositoryProvider).deleteTrip(id);
    await loadTrips();
  }

  Future<({TripModel trip, String role})> joinTrip(String shareCode) async {
    final result = await ref.read(tripRepositoryProvider).joinTrip(shareCode);
    await loadTrips();
    return result;
  }
}

// Single trip detail state
@riverpod
class TripDetailNotifier extends _$TripDetailNotifier {
  @override
  TripModel? build() => null;

  Future<void> loadTrip(int id) async {
    state = await ref.read(tripRepositoryProvider).getTrip(id);
  }

  Future<void> updateStatus(String status) async {
    if (state == null) return;
    final updated = await ref.read(tripRepositoryProvider).updateTrip(
          id: state!.id,
          status: status,
        );
    state = updated;
  }

  Future<void> updateTrip({
    String? title,
    String? destination,
    String? description,
    String? startDate,
    String? endDate,
  }) async {
    if (state == null) return;
    final updated = await ref.read(tripRepositoryProvider).updateTrip(
          id: state!.id,
          title: title,
          destination: destination,
          description: description,
          startDate: startDate,
          endDate: endDate,
        );
    state = updated;
  }
}

// Members state
@riverpod
class MembersNotifier extends _$MembersNotifier {
  @override
  List<TripMemberModel> build() => [];

  Future<void> loadMembers(int tripId) async {
    state = await ref.read(tripRepositoryProvider).getMembers(tripId);
  }

  Future<void> updateRole(int userId, String role) async {
    final tripId = ref.read(tripDetailNotifierProvider)!.id;
    await ref.read(tripRepositoryProvider).updateMemberRole(tripId, userId, role);
    await loadMembers(tripId);
  }

  Future<void> removeMember(int userId) async {
    final tripId = ref.read(tripDetailNotifierProvider)!.id;
    await ref.read(tripRepositoryProvider).removeMember(tripId, userId);
    await loadMembers(tripId);
  }
}
```

---

### Task B3: Trip Widgets

**Files:**
- Create: `frontend/lib/features/trips/presentation/widgets/trip_card.dart`
- Create: `frontend/lib/features/trips/presentation/widgets/status_badge.dart`
- Create: `frontend/lib/features/trips/presentation/widgets/member_avatar.dart`

---

- [ ] **Step 1: Create StatusBadge**

Create `frontend/lib/features/trips/presentation/widgets/status_badge.dart`:
```dart
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'planned':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
```

---

- [ ] **Step 2: Create MemberAvatar**

Create `frontend/lib/features/trips/presentation/widgets/member_avatar.dart`:
```dart
import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;

  const MemberAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 3: Create TripCard**

Create `frontend/lib/features/trips/presentation/widgets/trip_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import 'status_badge.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.place,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  StatusBadge(status: trip.status),
                ],
              ),
              const SizedBox(height: 8),
              if (trip.destination != null)
                Row(
                  children: [
                    const SizedBox(width: 28),
                    Text(
                      trip.destination!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 28),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateRange(trip.startDate, trip.endDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const Spacer(),
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.membersCount ?? trip.members.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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

  String _formatDateRange(String? start, String? end) {
    if (start == null && end == null) return 'No dates set';
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    }
    return start ?? end ?? '';
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = int.tryParse(parts[1]) ?? 1;
    final day = parts[2];
    return '${months[month - 1]} $day';
  }
}
```

---

### Task B4: Trip Screens

**Files:**
- Create: `frontend/lib/features/trips/presentation/screens/trips_list_screen.dart`
- Create: `frontend/lib/features/trips/presentation/screens/trip_detail_screen.dart`
- Create: `frontend/lib/features/trips/presentation/screens/trip_form_screen.dart`
- Create: `frontend/lib/features/trips/presentation/screens/join_trip_screen.dart`
- Create: `frontend/lib/features/trips/presentation/screens/trip_members_screen.dart`

---

- [ ] **Step 1: Create TripsListScreen**

Create `frontend/lib/features/trips/presentation/screens/trips_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';
import '../widgets/trip_card.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  const TripsListScreen({super.key});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tripsNotifierProvider.notifier).loadTrips());
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            onPressed: () => context.push('/join'),
            tooltip: 'Join Trip',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tripsNotifierProvider.notifier).loadTrips(),
        child: tripsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (trips) => trips.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: trips.length,
                  itemBuilder: (context, index) => TripCard(
                    trip: trips[index],
                    onTap: () => context.push('/trips/${trips[index].id}'),
                  ),
                ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $message'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(tripsNotifierProvider.notifier).loadTrips(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trips/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.luggage_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No trips yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trip or join one!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
```

---

- [ ] **Step 2: Create TripDetailScreen**

Create `frontend/lib/features/trips/presentation/screens/trip_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';
import '../widgets/status_badge.dart';
import '../widgets/member_avatar.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId));
  }

  void _copyShareCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share code copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripDetailNotifierProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/trips/${trip.id}/members'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Trip'),
                    content: const Text('Are you sure you want to delete this trip?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(tripsNotifierProvider.notifier).deleteTrip(trip.id);
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Trip')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination
            if (trip.destination != null) ...[
              Row(
                children: [
                  const Icon(Icons.place, size: 20),
                  const SizedBox(width: 8),
                  Text(trip.destination!, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Dates
            if (trip.startDate != null || trip.endDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.startDate ?? '?'} - ${trip.endDate ?? '?'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Description
            if (trip.description != null) ...[
              Text(trip.description!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],

            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Status: '),
                    const Spacer(),
                    StatusBadge(status: trip.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Share Code
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Share Code: '),
                    Text(
                      trip.shareCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyShareCode(trip.shareCode),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Members Preview
            Text(
              'Members (${trip.members.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...trip.members.take(5).map((member) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: MemberAvatar(name: member.name),
                  title: Text(member.name),
                  trailing: Text(member.role.toUpperCase()),
                )),
            if (trip.members.length > 5)
              TextButton(
                onPressed: () => context.push('/trips/${trip.id}/members'),
                child: Text('View all ${trip.members.length} members'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/${trip.id}/edit'),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
    );
  }
}
```

---

- [ ] **Step 3: Create TripFormScreen**

Create `frontend/lib/features/trips/presentation/screens/trip_form_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';

class TripFormScreen extends ConsumerStatefulWidget {
  final int? tripId; // null for create, id for edit

  const TripFormScreen({super.key, this.tripId});

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  bool get isEdit => widget.tripId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      Future.microtask(() async {
        await ref.read(tripDetailNotifierProvider.notifier).loadTrip(widget.tripId!);
        final trip = ref.read(tripDetailNotifierProvider);
        if (trip != null) {
          _titleController.text = trip.title;
          _destinationController.text = trip.destination ?? '';
          _descriptionController.text = trip.description ?? '';
          if (trip.startDate != null) {
            _startDate = DateTime.tryParse(trip.startDate!);
          }
          if (trip.endDate != null) {
            _endDate = DateTime.tryParse(trip.endDate!);
          }
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(tripsNotifierProvider.notifier);
      
      if (isEdit) {
        await ref.read(tripDetailNotifierProvider.notifier).updateTrip(
              title: _titleController.text,
              destination: _destinationController.text.isEmpty ? null : _destinationController.text,
              description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
              startDate: _startDate!.toIso8601String().split('T')[0],
              endDate: _endDate!.toIso8601String().split('T')[0],
            );
      } else {
        await notifier.createTrip(
          title: _titleController.text,
          destination: _destinationController.text.isEmpty ? null : _destinationController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
        );
      }

      if (mounted) context.pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Trip' : 'Create Trip'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Trip Title *'),
              validator: (v) => v?.isEmpty ?? true ? 'Title required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date *'),
                    subtitle: Text(_startDate?.toIso8601String().split('T')[0] ?? 'Select'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date *'),
                    subtitle: Text(_endDate?.toIso8601String().split('T')[0] ?? 'Select'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEdit ? 'Save Changes' : 'Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 4: Create JoinTripScreen**

Create `frontend/lib/features/trips/presentation/screens/join_trip_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/trip_providers.dart';

class JoinTripScreen extends ConsumerStatefulWidget {
  const JoinTripScreen({super.key});

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-character code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(tripsNotifierProvider.notifier).joinTrip(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined as ${result.role}!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/trips/${result.trip.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Trip')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Trip Code',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-character code shared by the trip owner',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                hintText: 'XXXXXX',
                counterText: '',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _join,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Join Trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 5: Create TripMembersScreen**

Create `frontend/lib/features/trips/presentation/screens/trip_members_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/trip_providers.dart';
import '../widgets/member_avatar.dart';

class TripMembersScreen extends ConsumerStatefulWidget {
  final int tripId;

  const TripMembersScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripMembersScreen> createState() => _TripMembersScreenState();
}

class _TripMembersScreenState extends ConsumerState<TripMembersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(membersNotifierProvider.notifier).loadMembers(widget.tripId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersNotifierProvider);
    final trip = ref.watch(tripDetailNotifierProvider);
    final isOwner = trip?.owner.id == ref.read(userIdProvider); // TODO: Get current user ID

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: MemberAvatar(name: member.name),
            title: Text(member.name),
            subtitle: Text(member.email ?? ''),
            trailing: isOwner && !member.isOwner
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: member.role,
                        items: const [
                          DropdownMenuItem(value: 'editor', child: Text('Editor')),
                          DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                        ],
                        onChanged: (role) {
                          if (role != null) {
                            ref.read(membersNotifierProvider.notifier).updateRole(member.id, role);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Member'),
                              content: Text('Remove ${member.name} from this trip?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(membersNotifierProvider.notifier).removeMember(member.id);
                          }
                        },
                      ),
                    ],
                  )
                : Chip(label: Text(member.role.toUpperCase())),
          );
        },
      ),
    );
  }
}

// Placeholder - will be connected to auth state
int get userIdProvider => 1;
```

---

### Task B5: Router & Navigation

**Files:**
- Modify: `frontend/lib/core/router/app_router.dart`
- Modify: `frontend/lib/core/api/api_endpoints.dart`

---

- [ ] **Step 1: Update AppRouter**

Edit `frontend/lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/trips/presentation/screens/trips_list_screen.dart';
import '../../features/trips/presentation/screens/trip_detail_screen.dart';
import '../../features/trips/presentation/screens/trip_form_screen.dart';
import '../../features/trips/presentation/screens/join_trip_screen.dart';
import '../../features/trips/presentation/screens/trip_members_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Auth
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Trips
      GoRoute(
        path: '/trips',
        builder: (_, __) => const TripsListScreen(),
      ),
      GoRoute(
        path: '/trips/new',
        builder: (_, __) => const TripFormScreen(),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (_, state) => TripDetailScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/trips/:id/edit',
        builder: (_, state) => TripFormScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/trips/:id/members',
        builder: (_, state) => TripMembersScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/join',
        builder: (_, __) => const JoinTripScreen(),
      ),
    ],
  );
}
```

---

- [ ] **Step 2: Run code generation**

Run:
```bash
cd frontend && flutter pub run build_runner build --delete-conflicting-outputs
```

---

- [ ] **Step 3: Update Home placeholder in auth router**

Replace HomePlaceholder with redirect to trips:
```dart
GoRoute(
  path: '/home',
  redirect: (_, __) => '/trips',
),
```

---

### Task B6: Testing

**Files:**
- Create: `frontend/test/trips_test.dart`

---

- [ ] **Step 1: Create widget test**

Create `frontend/test/trips_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dntrip/features/trips/presentation/widgets/status_badge.dart';
import 'package:dntrip/features/trips/presentation/widgets/trip_card.dart';
import 'package:dntrip/features/trips/data/models/trip_model.dart';

void main() {
  group('StatusBadge Widget', () {
    testWidgets('displays planned status', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'planned')),
      ));
      expect(find.text('PLANNED'), findsOneWidget);
    });

    testWidgets('displays ongoing status', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'ongoing')),
      ));
      expect(find.text('ONGOING'), findsOneWidget);
    });

    testWidgets('displays completed status', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'completed')),
      ));
      expect(find.text('COMPLETED'), findsOneWidget);
    });
  });
}
```

---

- [ ] **Step 2: Run tests**

Run:
```bash
cd frontend && flutter test test/trips_test.dart
```

---

## Verification Checklist

### Backend
- [ ] Trip CRUD endpoints work
- [ ] Join via share code works
- [ ] Member management works
- [ ] Permission checks enforced

### Frontend
- [ ] Trip list displays correctly
- [ ] Create/Edit forms work
- [ ] Join trip flow works
- [ ] Member management UI works
- [ ] Navigation between screens works

---

*Implementation plan v1.0 - 2026-07-04*
