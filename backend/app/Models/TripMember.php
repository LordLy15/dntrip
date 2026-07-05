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
