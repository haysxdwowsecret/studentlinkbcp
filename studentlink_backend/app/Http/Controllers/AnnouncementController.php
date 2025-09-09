<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAnnouncementRequest;
use App\Http\Requests\UpdateAnnouncementRequest;
use App\Models\Announcement;
use App\Models\AnnouncementBookmark;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnnouncementController extends Controller
{
    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    /**
     * Get announcements list
     */
    public function index(Request $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $query = Announcement::with(['author', 'targetDepartments']);

            // Filter by status (default to published for students)
            $status = $request->input('status', $user->role === 'student' ? 'published' : 'all');
            if ($status !== 'all') {
                $query->where('status', $status);
            }

            // Filter by type
            if ($request->filled('type')) {
                $query->where('type', $request->input('type'));
            }

            // Filter by priority
            if ($request->filled('priority')) {
                $query->where('priority', $request->input('priority'));
            }

            // Only show published announcements for students
            if ($user->role === 'student') {
                $query->where('status', 'published')
                    ->where('published_at', '<=', now())
                    ->where(function ($q) {
                        $q->whereNull('expires_at')
                            ->orWhere('expires_at', '>', now());
                    });
            }

            // Filter by target departments if applicable
            if ($user->role === 'student' && $user->department_id) {
                $query->where(function ($q) use ($user) {
                    $q->whereHas('targetDepartments', function ($dq) use ($user) {
                        $dq->where('department_id', $user->department_id);
                    })->orWhereDoesntHave('targetDepartments'); // Global announcements
                });
            }

            $announcements = $query
                ->orderBy('published_at', 'desc')
                ->paginate($request->input('per_page', 20));

            // Add bookmark status for each announcement
            $announcementIds = $announcements->pluck('id');
            $bookmarkedIds = AnnouncementBookmark::where('user_id', $user->id)
                ->whereIn('announcement_id', $announcementIds)
                ->pluck('announcement_id')
                ->toArray();

            $announcements->getCollection()->transform(function ($announcement) use ($bookmarkedIds) {
                $announcement->is_bookmarked = in_array($announcement->id, $bookmarkedIds);
                return $announcement;
            });

            return response()->json([
                'success' => true,
                'data' => $announcements->items(),
                'pagination' => [
                    'current_page' => $announcements->currentPage(),
                    'last_page' => $announcements->lastPage(),
                    'per_page' => $announcements->perPage(),
                    'total' => $announcements->total(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch announcements',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Create new announcement
     */
    public function store(StoreAnnouncementRequest $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $data = $request->validated();
            $data['author_id'] = $user->id;

            // Set published_at if status is published and not already set
            if ($data['status'] === 'published' && !isset($data['published_at'])) {
                $data['published_at'] = now();
            }

            $announcement = Announcement::create($data);

            // Attach target departments if specified
            if (isset($data['target_departments']) && is_array($data['target_departments'])) {
                $announcement->targetDepartments()->sync($data['target_departments']);
            }

            // Log the creation
            $this->auditLogService->log($user, 'create', $announcement, null, [
                'title' => $announcement->title,
                'type' => $announcement->type,
                'priority' => $announcement->priority,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Announcement created successfully',
                'data' => $announcement->load(['author', 'targetDepartments']),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create announcement',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get specific announcement
     */
    public function show(Announcement $announcement): JsonResponse
    {
        $user = auth()->user();

        try {
            // Check if user can view this announcement
            if ($user->role === 'student' && $announcement->status !== 'published') {
                return response()->json([
                    'success' => false,
                    'message' => 'Announcement not found',
                ], 404);
            }

            $announcement->load(['author', 'targetDepartments']);
            
            // Check if bookmarked
            $announcement->is_bookmarked = AnnouncementBookmark::where('user_id', $user->id)
                ->where('announcement_id', $announcement->id)
                ->exists();

            // Increment view count
            $announcement->increment('view_count');

            return response()->json([
                'success' => true,
                'data' => $announcement,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch announcement',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Update announcement
     */
    public function update(UpdateAnnouncementRequest $request, Announcement $announcement): JsonResponse
    {
        $user = auth()->user();

        try {
            $data = $request->validated();

            // Set published_at if status is being changed to published
            if ($data['status'] === 'published' && $announcement->status !== 'published' && !isset($data['published_at'])) {
                $data['published_at'] = now();
            }

            $oldData = $announcement->toArray();
            $announcement->update($data);

            // Update target departments if specified
            if (isset($data['target_departments']) && is_array($data['target_departments'])) {
                $announcement->targetDepartments()->sync($data['target_departments']);
            }

            // Log the update
            $this->auditLogService->log($user, 'update', $announcement, $oldData, [
                'title' => $announcement->title,
                'changes' => array_keys($data),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Announcement updated successfully',
                'data' => $announcement->load(['author', 'targetDepartments']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update announcement',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Delete announcement
     */
    public function destroy(Announcement $announcement): JsonResponse
    {
        $user = auth()->user();

        try {
            $announcementData = $announcement->toArray();
            $announcement->delete();

            // Log the deletion
            $this->auditLogService->log($user, 'delete', null, $announcementData, [
                'title' => $announcementData['title'],
                'id' => $announcementData['id'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Announcement deleted successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete announcement',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Bookmark announcement
     */
    public function bookmark(Announcement $announcement): JsonResponse
    {
        $user = auth()->user();

        try {
            $bookmark = AnnouncementBookmark::firstOrCreate([
                'user_id' => $user->id,
                'announcement_id' => $announcement->id,
            ]);

            if ($bookmark->wasRecentlyCreated) {
                $announcement->increment('bookmark_count');
            }

            return response()->json([
                'success' => true,
                'message' => 'Announcement bookmarked successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to bookmark announcement',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Remove bookmark
     */
    public function removeBookmark(Announcement $announcement): JsonResponse
    {
        $user = auth()->user();

        try {
            $deleted = AnnouncementBookmark::where('user_id', $user->id)
                ->where('announcement_id', $announcement->id)
                ->delete();

            if ($deleted) {
                $announcement->decrement('bookmark_count');
            }

            return response()->json([
                'success' => true,
                'message' => 'Bookmark removed successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to remove bookmark',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get user's bookmarked announcements
     */
    public function getBookmarks(Request $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $bookmarks = AnnouncementBookmark::where('user_id', $user->id)
                ->with(['announcement.author'])
                ->orderBy('created_at', 'desc')
                ->paginate($request->input('per_page', 20));

            $announcements = $bookmarks->getCollection()->map(function ($bookmark) {
                $announcement = $bookmark->announcement;
                $announcement->is_bookmarked = true;
                $announcement->bookmarked_at = $bookmark->created_at;
                return $announcement;
            });

            return response()->json([
                'success' => true,
                'data' => $announcements,
                'pagination' => [
                    'current_page' => $bookmarks->currentPage(),
                    'last_page' => $bookmarks->lastPage(),
                    'per_page' => $bookmarks->perPage(),
                    'total' => $bookmarks->total(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch bookmarked announcements',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }
}
