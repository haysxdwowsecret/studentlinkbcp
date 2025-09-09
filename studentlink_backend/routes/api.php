<?php

use App\Http\Controllers\{
    AuthController,
    ConcernController,
    AnnouncementController,
    UserController,
    DepartmentController,
    EmergencyController,
    NotificationController,
    AiController,
    AnalyticsController,
    SystemController
};
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes
Route::get('/test', function () {
    return response()->json(['status' => 'ok', 'message' => 'API is working']);
});
Route::get('/health', [SystemController::class, 'health']);
Route::get('/health/detailed', [SystemController::class, 'detailedHealth']);

// Authentication routes
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
    Route::middleware('auth:api')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
    });
});

// Protected routes
Route::middleware('auth:api')->group(function () {
    
    // Concerns Management
    Route::prefix('concerns')->group(function () {
        Route::get('/', [ConcernController::class, 'index']);
        Route::post('/', [ConcernController::class, 'store']);
        Route::get('/{concern}', [ConcernController::class, 'show']);
        Route::put('/{concern}', [ConcernController::class, 'update']);
        Route::delete('/{concern}', [ConcernController::class, 'destroy']);
        
        // Concern messages
        Route::post('/{concern}/messages', [ConcernController::class, 'addMessage']);
        Route::get('/{concern}/messages', [ConcernController::class, 'getMessages']);
        
        // Concern actions
        Route::patch('/{concern}/status', [ConcernController::class, 'updateStatus']);
        Route::post('/{concern}/assign', [ConcernController::class, 'assign']);
        Route::get('/{concern}/history', [ConcernController::class, 'getHistory']);
        
        // File uploads
        Route::post('/{concern}/attachments', [ConcernController::class, 'uploadAttachment']);
    });

    // Announcements Management
    Route::prefix('announcements')->group(function () {
        Route::get('/', [AnnouncementController::class, 'index']);
        Route::post('/', [AnnouncementController::class, 'store']);
        Route::get('/{announcement}', [AnnouncementController::class, 'show']);
        Route::put('/{announcement}', [AnnouncementController::class, 'update']);
        Route::delete('/{announcement}', [AnnouncementController::class, 'destroy']);
        
        // Announcement actions
        Route::post('/{announcement}/bookmark', [AnnouncementController::class, 'bookmark']);
        Route::delete('/{announcement}/bookmark', [AnnouncementController::class, 'removeBookmark']);
        Route::get('/user/bookmarks', [AnnouncementController::class, 'getBookmarks']);
    });

    // User Management (Admin/Department Head only)
    Route::prefix('users')->group(function () {
        Route::get('/', [UserController::class, 'index'])
            ->middleware('role:admin,department_head');
        Route::post('/', [UserController::class, 'store'])
            ->middleware('role:admin');
        Route::get('/{user}', [UserController::class, 'show']);
        Route::put('/{user}', [UserController::class, 'update']);
        Route::delete('/{user}', [UserController::class, 'destroy'])
            ->middleware('role:admin');
        
        // User profile
        Route::get('/profile/me', [UserController::class, 'profile']);
        Route::put('/profile/me', [UserController::class, 'updateProfile']);
        Route::post('/profile/avatar', [UserController::class, 'uploadAvatar']);
    });

    // Department Management
    Route::prefix('departments')->group(function () {
        Route::get('/', [DepartmentController::class, 'index']);
        Route::post('/', [DepartmentController::class, 'store'])
            ->middleware('role:admin');
        Route::get('/{department}', [DepartmentController::class, 'show']);
        Route::put('/{department}', [DepartmentController::class, 'update'])
            ->middleware('role:admin');
        Route::delete('/{department}', [DepartmentController::class, 'destroy'])
            ->middleware('role:admin');
        
        // Department statistics
        Route::get('/{department}/stats', [DepartmentController::class, 'getStats']);
        Route::get('/{department}/concerns', [DepartmentController::class, 'getConcerns']);
        Route::get('/{department}/users', [DepartmentController::class, 'getUsers']);
    });

    // Emergency Help
    Route::prefix('emergency')->group(function () {
        Route::get('/contacts', [EmergencyController::class, 'getContacts']);
        Route::get('/protocols', [EmergencyController::class, 'getProtocols']);
        
        // Admin only routes
        Route::middleware('role:admin')->group(function () {
            Route::post('/contacts', [EmergencyController::class, 'createContact']);
            Route::put('/contacts/{contact}', [EmergencyController::class, 'updateContact']);
            Route::delete('/contacts/{contact}', [EmergencyController::class, 'deleteContact']);
            
            Route::post('/protocols', [EmergencyController::class, 'createProtocol']);
            Route::put('/protocols/{protocol}', [EmergencyController::class, 'updateProtocol']);
            Route::delete('/protocols/{protocol}', [EmergencyController::class, 'deleteProtocol']);
        });
    });

    // Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::post('/mark-read', [NotificationController::class, 'markAsRead']);
        Route::post('/mark-all-read', [NotificationController::class, 'markAllAsRead']);
        Route::delete('/{notification}', [NotificationController::class, 'destroy']);
        
        // FCM token management
        Route::post('/fcm-token', [NotificationController::class, 'storeFcmToken']);
        Route::delete('/fcm-token', [NotificationController::class, 'removeFcmToken']);
    });

    // AI Features
    Route::prefix('ai')->group(function () {
        Route::post('/chat', [AiController::class, 'chat']);
        Route::post('/suggestions', [AiController::class, 'getSuggestions']);
        Route::post('/transcribe', [AiController::class, 'transcribeAudio']);
        
        // AI session management
        Route::get('/sessions', [AiController::class, 'getSessions']);
        Route::post('/sessions', [AiController::class, 'createSession']);
        Route::get('/sessions/{session}', [AiController::class, 'getSession']);
        Route::delete('/sessions/{session}', [AiController::class, 'deleteSession']);
    });

    // Analytics & Reports
    Route::prefix('analytics')->group(function () {
        Route::get('/dashboard', [AnalyticsController::class, 'getDashboardStats']);
        Route::get('/concerns', [AnalyticsController::class, 'getConcernStats']);
        Route::get('/departments', [AnalyticsController::class, 'getDepartmentStats']);
        Route::get('/users', [AnalyticsController::class, 'getUserStats']);
        
        // Detailed reports (Admin only)
        Route::middleware('role:admin,department_head')->group(function () {
            Route::get('/reports/concerns', [AnalyticsController::class, 'getConcernReport']);
            Route::get('/reports/departments', [AnalyticsController::class, 'getDepartmentReport']);
            Route::get('/reports/users', [AnalyticsController::class, 'getUserReport']);
            Route::get('/reports/export', [AnalyticsController::class, 'exportReport']);
        });
    });

    // System Management (Admin only)
    Route::prefix('system')->middleware('role:admin')->group(function () {
        Route::get('/settings', [SystemController::class, 'getSettings']);
        Route::put('/settings', [SystemController::class, 'updateSettings']);
        Route::get('/audit-logs', [SystemController::class, 'getAuditLogs']);
        Route::get('/system-info', [SystemController::class, 'getSystemInfo']);
    });
});
