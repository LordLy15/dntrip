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

    public function days(): HasMany
    {
        return $this->hasMany(TripDay::class)->orderBy('day_number');
    }

    public function activities(): HasMany
    {
        return $this->hasMany(TripActivity::class);
    }

    /**
     * Auto-generate days when trip is created
     */
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

    /**
     * Budget calculations
     */
    public function calculateBudget(): array
    {
        $activities = $this->activities()->get();

        $totalEstimated = $activities->where('is_unplanned', false)->sum('estimated_cost');
        $totalActual = $activities->where('status', 'completed')->sum('actual_cost');
        $variance = $totalActual - $totalEstimated;

        return [
            'total_estimated' => (float) $totalEstimated,
            'total_actual' => (float) $totalActual,
            'variance' => (float) $variance,
            'is_overbudget' => $variance > 0,
        ];
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
            return;
        }

        if ($endDate && $today > $endDate) {
            $this->update(['status' => 'completed']);
        } elseif ($startDate && $today >= $startDate && $this->status === 'planned') {
            $this->update(['status' => 'ongoing']);
        }
    }
}
