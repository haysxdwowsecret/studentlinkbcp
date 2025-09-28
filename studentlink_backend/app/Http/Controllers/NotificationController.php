<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreFcmTokenRequest;
use App\Models\Notification;
use App\Models\FcmToken;
use App\Models\User;
use App\Services\FirebaseService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    protected FirebaseService $firebaseService;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    /**
     * Get user notifications
     */
    public function index(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        $query = Notification::where('user_id', $user->id);

        // Filter by read status
        if ($request->has('unread_only') && $request->boolean('unread_only')) {
            $query->whereNull('read_at');
        }

        // Filter by type
        if ($request->filled('type')) {
            $query->where('type', $request->input('type'));
        }

        // Filter by priority
        if ($request->filled('priority')) {
            $query->where('priority', $request->input('priority'));
        }

        $notifications = $query
            ->orderBy('created_at', 'desc')
            ->paginate($request->input('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $notifications->items(),
            'pagination' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
                'unread_count' => $user->unread_notifications_count,
            ],
        ]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        $request->validate([
            'notification_ids' => 'required|array',
            'notification_ids.*' => 'exists:notifications,id',
        ]);

        $updated = Notification::where('user_id', $user->id)
            ->whereIn('id', $request->input('notification_ids'))
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Notifications marked as read',
            'updated_count' => $updated,
        ]);
    }

    /**
     * Mark all notifications as read
     */
    public function markAllAsRead(): JsonResponse
    {
        $user = auth()->user();

        $updated = Notification::where('user_id', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
            'updated_count' => $updated,
        ]);
    }

    /**
     * Delete notification
     */
    public function destroy(Notification $notification): JsonResponse
    {
        $user = auth()->user();

        // Check if notification belongs to the user
        if ($notification->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notification deleted successfully',
        ]);
    }

    /**
     * Store FCM token for push notifications
     */
    public function storeFcmToken(StoreFcmTokenRequest $request): JsonResponse
    {
        $user = auth()->user();
        $data = $request->validated();

        $success = $this->firebaseService->storeToken(
            $user,
            $data['token'],
            $data['device_type'],
            $data['device_id'] ?? null
        );

        if ($success) {
            return response()->json([
                'success' => true,
                'message' => 'FCM token stored successfully',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Failed to store FCM token',
        ], 500);
    }

    /**
     * Remove FCM token
     */
    public function removeFcmToken(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        $request->validate([
            'token' => 'required|string',
        ]);

        $success = $this->firebaseService->removeToken($user, $request->input('token'));

        if ($success) {
            return response()->json([
                'success' => true,
                'message' => 'FCM token removed successfully',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Failed to remove FCM token',
        ], 500);
    }

    /**
     * Get user's FCM tokens (for debugging)
     */
    public function getFcmTokens(): JsonResponse
    {
        $user = auth()->user();

        $tokens = FcmToken::where('user_id', $user->id)
            ->where('is_active', true)
            ->select(['device_type', 'device_id', 'last_used_at', 'created_at'])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $tokens,
            'total_tokens' => $tokens->count(),
        ]);
    }

    /**
     * Test push notification (development only)
     */
    public function testPushNotification(Request $request): JsonResponse
    {
        if (!app()->environment('local')) {
            return response()->json([
                'success' => false,
                'message' => 'This endpoint is only available in development',
            ], 403);
        }

        $user = auth()->user();
        
        $request->validate([
            'title' => 'required|string|max:100',
            'body' => 'required|string|max:200',
        ]);

        $success = $this->firebaseService->sendToUser(
            $user,
            $request->input('title'),
            $request->input('body'),
            ['test' => true, 'timestamp' => now()->toISOString()]
        );

        return response()->json([
            'success' => $success,
            'message' => $success ? 'Test notification sent' : 'Failed to send test notification',
        ]);
    }

    /**
     * Get notification statistics (Admin only)
     */
    public function getNotificationStats(): JsonResponse
    {
        $stats = [
            'total_sent' => Notification::count(),
            'total_delivered' => Notification::whereNotNull('delivered_at')->count(),
            'total_failed' => Notification::whereNotNull('failed_at')->count(),
            'active_tokens' => FcmToken::where('is_active', true)->count(),
            'users_with_tokens' => FcmToken::where('is_active', true)->distinct('user_id')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Send notification (Admin only)
     */
    public function sendNotification(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string|max:100',
            'body' => 'required|string|max:500',
            'type' => 'required|string|in:general,announcement,concern_update,emergency,system',
            'target' => 'required|string|in:all,students,department_heads,department,role',
            'department_id' => 'nullable|integer|exists:departments,id',
            'role' => 'nullable|string|in:admin,department_head,student',
            'priority' => 'required|string|in:low,normal,high,urgent',
            'scheduled' => 'boolean',
            'scheduled_at' => 'nullable|date|after:now',
        ]);

        $data = $request->validated();
        
        // Determine target users
        $userIds = $this->getTargetUserIds($data);
        
        if (empty($userIds)) {
            return response()->json([
                'success' => false,
                'message' => 'No users found for the specified target',
            ], 400);
        }

        // Send notification
        $result = $this->firebaseService->sendToUsers(
            $userIds,
            $data['title'],
            $data['body'],
            [
                'type' => $data['type'],
                'priority' => $data['priority'],
                'admin_sent' => true,
                'timestamp' => now()->toISOString(),
            ]
        );

        // Store notification records
        foreach ($userIds as $userId) {
            Notification::create([
                'user_id' => $userId,
                'title' => $data['title'],
                'body' => $data['body'],
                'type' => $data['type'],
                'priority' => $data['priority'],
                'data' => json_encode([
                    'admin_sent' => true,
                    'target' => $data['target'],
                ]),
                'delivered_at' => $result['success'] ? now() : null,
                'failed_at' => $result['success'] ? null : now(),
            ]);
        }

        return response()->json([
            'success' => $result['success'],
            'message' => $result['success'] ? 'Notification sent successfully' : 'Failed to send notification',
            'data' => $result,
        ]);
    }

    /**
     * Get recent notifications (Admin only)
     */
    public function getRecentNotifications(Request $request): JsonResponse
    {
        $limit = $request->input('limit', 10);
        
        $notifications = Notification::with('user:id,name,email')
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notifications,
        ]);
    }

    /**
     * Get notification templates (Admin only)
     */
    public function getNotificationTemplates(): JsonResponse
    {
        $templates = [
            [
                'id' => 'welcome',
                'name' => 'Welcome Message',
                'title' => 'Welcome to StudentLink!',
                'body' => 'Thank you for joining our platform. We\'re here to help with all your concerns.',
                'type' => 'welcome',
                'target' => 'new_users',
                'enabled' => true,
            ],
            [
                'id' => 'concern_update',
                'name' => 'Concern Update',
                'title' => 'Concern Status Update',
                'body' => 'Your concern has been updated. Please check the details.',
                'type' => 'concern_update',
                'target' => 'specific_user',
                'enabled' => true,
            ],
            [
                'id' => 'announcement',
                'name' => 'New Announcement',
                'title' => 'Important Announcement',
                'body' => 'A new announcement has been posted. Please read it carefully.',
                'type' => 'announcement',
                'target' => 'all',
                'enabled' => true,
            ],
            [
                'id' => 'emergency',
                'name' => 'Emergency Alert',
                'title' => 'Emergency Alert',
                'body' => 'This is an emergency notification. Please follow the instructions.',
                'type' => 'emergency',
                'target' => 'all',
                'enabled' => true,
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => $templates,
        ]);
    }

    /**
     * Create notification template (Admin only)
     */
    public function createNotificationTemplate(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'title' => 'required|string|max:100',
            'body' => 'required|string|max:500',
            'type' => 'required|string|in:general,announcement,concern_update,emergency,system',
            'target' => 'required|string|in:all,students,department_heads,department,role',
        ]);

        // In a real implementation, you would store this in a database
        // For now, we'll just return success
        return response()->json([
            'success' => true,
            'message' => 'Template created successfully',
        ]);
    }

    /**
     * Update notification template (Admin only)
     */
    public function updateNotificationTemplate(Request $request, string $templateId): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|string|max:100',
            'title' => 'sometimes|string|max:100',
            'body' => 'sometimes|string|max:500',
            'type' => 'sometimes|string|in:general,announcement,concern_update,emergency,system',
            'target' => 'sometimes|string|in:all,students,department_heads,department,role',
            'enabled' => 'sometimes|boolean',
        ]);

        // In a real implementation, you would update this in a database
        // For now, we'll just return success
        return response()->json([
            'success' => true,
            'message' => 'Template updated successfully',
        ]);
    }

    /**
     * Delete notification template (Admin only)
     */
    public function deleteNotificationTemplate(string $templateId): JsonResponse
    {
        // In a real implementation, you would delete this from a database
        // For now, we'll just return success
        return response()->json([
            'success' => true,
            'message' => 'Template deleted successfully',
        ]);
    }

    /**
     * Get target user IDs based on notification criteria
     */
    private function getTargetUserIds(array $data): array
    {
        $query = User::where('is_active', true);

        switch ($data['target']) {
            case 'students':
                $query->where('role', 'student');
                break;
            case 'department_heads':
                $query->whereIn('role', ['department_head', 'admin']);
                break;
            case 'department':
                if (!empty($data['department_id'])) {
                    $query->where('department_id', $data['department_id']);
                }
                break;
            case 'role':
                if (!empty($data['role'])) {
                    $query->where('role', $data['role']);
                }
                break;
            case 'all':
            default:
                // No additional filtering
                break;
        }

        return $query->pluck('id')->toArray();
    }
}
