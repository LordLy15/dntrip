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
        'plan_budget',
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

    public function suddenExpenses(): HasMany
    {
        return $this->hasMany(SuddenExpense::class);
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
        if ($planBudget == 0) return 'on_budget';
        if ($totalActual >= $lowerThreshold && $totalActual <= $upperThreshold) {
            return 'on_budget';
        }
        if ($totalActual < $lowerThreshold) {
            return 'underbudget';
        }
        return 'deficit';
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
