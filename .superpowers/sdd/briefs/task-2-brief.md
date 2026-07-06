# Task 2: Backend - Models

## Overview
Create Eloquent models for `ExpenseCategory` and `SuddenExpense`, and update the `Trip` model with new fields and budget calculation.

## Files to Create/Modify

### 1. Create: `backend/app/Models/ExpenseCategory.php`

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

### 2. Create: `backend/app/Models/SuddenExpense.php`

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

### 3. Modify: `backend/app/Models/Trip.php`

Add to `$fillable` array:
```php
'plan_budget',
```

Add new relation after `activities()`:
```php
public function suddenExpenses(): HasMany
{
    return $this->hasMany(SuddenExpense::class);
}
```

Replace `calculateBudget()` method with this enhanced version:
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
    if ($planBudget == 0) return 'on_budget';
    if ($totalActual >= $lowerThreshold && $totalActual <= $upperThreshold) {
        return 'on_budget';
    }
    if ($totalActual < $lowerThreshold) {
        return 'underbudget';
    }
    return 'deficit';
}
```

## Acceptance Criteria

- [ ] `ExpenseCategory` model created with default categories
- [ ] `SuddenExpense` model created with trip/category relations
- [ ] `Trip` model updated with `suddenExpenses` relation
- [ ] `Trip` model updated with extended `calculateBudget()` method
- [ ] Budget status calculated with 5% margin threshold

## Notes

- Depends on Task 1 migrations being completed
- The `suddenExpenses()` relation must be added to Trip model
