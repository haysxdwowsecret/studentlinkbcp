<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

class AuditLogService
{
    /**
     * Log an action to the audit log.
     */
    public function log(
        ?User $user,
        string $action,
        ?Model $model = null,
        ?array $changes = null,
        ?array $metadata = null
    ): AuditLog {
        $request = request();
        
        $data = [
            'user_id' => $user?->id,
            'action' => $action,
            'ip_address' => $request?->ip(),
            'user_agent' => $request?->userAgent(),
            'metadata' => $metadata,
        ];

        if ($model) {
            $data['model_type'] = get_class($model);
            $data['model_id'] = $model->getKey();
        }

        if ($changes) {
            $data['old_values'] = $changes['old'] ?? null;
            $data['new_values'] = $changes['new'] ?? null;
        }

        return AuditLog::create($data);
    }

    /**
     * Log a model creation.
     */
    public function logCreate(User $user, Model $model, ?array $metadata = null): AuditLog
    {
        return $this->log($user, 'create', $model, [
            'new' => $model->getAttributes()
        ], $metadata);
    }

    /**
     * Log a model update.
     */
    public function logUpdate(User $user, Model $model, array $oldValues, ?array $metadata = null): AuditLog
    {
        return $this->log($user, 'update', $model, [
            'old' => $oldValues,
            'new' => $model->getAttributes()
        ], $metadata);
    }

    /**
     * Log a model deletion.
     */
    public function logDelete(User $user, Model $model, ?array $metadata = null): AuditLog
    {
        return $this->log($user, 'delete', $model, [
            'old' => $model->getAttributes()
        ], $metadata);
    }

    /**
     * Log a login action.
     */
    public function logLogin(User $user, ?array $metadata = null): AuditLog
    {
        return $this->log($user, 'login', null, null, $metadata);
    }

    /**
     * Log a logout action.
     */
    public function logLogout(User $user, ?array $metadata = null): AuditLog
    {
        return $this->log($user, 'logout', null, null, $metadata);
    }

    /**
     * Log a concern status change.
     */
    public function logConcernStatusChange(
        User $user,
        Model $concern,
        string $oldStatus,
        string $newStatus,
        ?array $metadata = null
    ): AuditLog {
        return $this->log($user, 'status_change', $concern, [
            'old' => ['status' => $oldStatus],
            'new' => ['status' => $newStatus]
        ], array_merge($metadata ?? [], [
            'action_type' => 'concern_status_change',
            'old_status' => $oldStatus,
            'new_status' => $newStatus
        ]));
    }

    /**
     * Log a concern assignment.
     */
    public function logConcernAssignment(
        User $user,
        Model $concern,
        ?int $oldAssigneeId,
        ?int $newAssigneeId,
        ?array $metadata = null
    ): AuditLog {
        return $this->log($user, 'assignment', $concern, [
            'old' => ['assigned_to' => $oldAssigneeId],
            'new' => ['assigned_to' => $newAssigneeId]
        ], array_merge($metadata ?? [], [
            'action_type' => 'concern_assignment',
            'old_assignee_id' => $oldAssigneeId,
            'new_assignee_id' => $newAssigneeId
        ]));
    }

    /**
     * Get audit logs for a specific model.
     */
    public function getLogsForModel(Model $model)
    {
        return AuditLog::where('model_type', get_class($model))
            ->where('model_id', $model->getKey())
            ->with('user')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Get audit logs for a specific user.
     */
    public function getLogsForUser(User $user, int $limit = 50)
    {
        return AuditLog::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }

    /**
     * Get recent system audit logs.
     */
    public function getRecentLogs(int $limit = 100)
    {
        return AuditLog::with('user')
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }
}
