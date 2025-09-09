<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreFcmTokenRequest;
use App\Models\Notification;
use App\Models\FcmToken;
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
}
