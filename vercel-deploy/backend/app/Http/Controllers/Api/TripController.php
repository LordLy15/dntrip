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
                    'avatar' => $m->user->avatar,
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
