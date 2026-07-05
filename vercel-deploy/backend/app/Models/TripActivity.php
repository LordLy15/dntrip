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
