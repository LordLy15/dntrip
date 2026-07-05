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
