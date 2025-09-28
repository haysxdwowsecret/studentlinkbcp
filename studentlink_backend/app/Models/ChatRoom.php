<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ChatRoom extends Model
{
    use HasFactory;

    protected $fillable = [
        'concern_id',
        'room_name',
        'status',
        'last_activity_at',
        'participants',
        'settings',
        'unread_count',
    ];

    protected $casts = [
        'participants' => 'array',
        'settings' => 'array',
        'last_activity_at' => 'datetime',
        'unread_count' => 'integer',
    ];

    // Relationships
    public function concern(): BelongsTo
    {
        return $this->belongsTo(Concern::class);
    }


    public function messages(): HasMany
    {
        return $this->hasMany(ConcernMessage::class);
    }

    public function latestMessage(): HasOne
    {
        return $this->hasOne(ConcernMessage::class)->latest();
    }

    // Helper methods
    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    public function isClosed(): bool
    {
        return $this->status === 'closed';
    }

    public function updateLastActivity(): void
    {
        $this->update(['last_activity_at' => now()]);
    }

    public function getUnreadCountForUser(int $userId): int
    {
        return $this->messages()
            ->where('author_id', '!=', $userId)
            ->whereNull('read_at')
            ->count();
    }

    public function markAsReadForUser(int $userId): void
    {
        $this->messages()
            ->where('author_id', '!=', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }

    public function addParticipant(int $userId, string $role = 'member'): void
    {
        $participants = $this->participants ?? [];
        $participants[$userId] = [
            'user_id' => $userId,
            'role' => $role,
            'joined_at' => now()->toISOString(),
        ];
        $this->update(['participants' => $participants]);
    }

    public function removeParticipant(int $userId): void
    {
        $participants = $this->participants ?? [];
        unset($participants[$userId]);
        $this->update(['participants' => $participants]);
    }

    public function getParticipantIds(): array
    {
        return array_keys($this->participants ?? []);
    }
}

