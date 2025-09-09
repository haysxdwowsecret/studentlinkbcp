<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreConcernRequest;
use App\Http\Requests\UpdateConcernRequest;
use App\Models\Concern;
use App\Models\ConcernMessage;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConcernController extends Controller
{
    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    /**
     * Get concerns list
     */
    public function index(Request $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $query = Concern::with(['student', 'department', 'facility', 'assignedTo']);

            // Filter by user role
            if ($user->role === 'student') {
                $query->where('student_id', $user->id);
            } elseif ($user->role === 'department_head') {
                $query->where('department_id', $user->department_id);
            }

            // Filter by status
            if ($request->filled('status')) {
                $query->where('status', $request->input('status'));
            }

            // Filter by department
            if ($request->filled('department_id')) {
                $query->where('department_id', $request->input('department_id'));
            }

            // Filter by priority
            if ($request->filled('priority')) {
                $query->where('priority', $request->input('priority'));
            }

            // Filter by type
            if ($request->filled('type')) {
                $query->where('type', $request->input('type'));
            }

            // Filter by assigned user
            if ($request->filled('assigned_to')) {
                $query->where('assigned_to', $request->input('assigned_to'));
            }

            // Search by subject or description
            if ($request->filled('search')) {
                $search = $request->input('search');
                $query->where(function ($q) use ($search) {
                    $q->where('subject', 'like', "%{$search}%")
                        ->orWhere('description', 'like', "%{$search}%")
                        ->orWhere('reference_number', 'like', "%{$search}%");
                });
            }

            $concerns = $query
                ->orderBy('created_at', 'desc')
                ->paginate($request->input('per_page', 20));

            return response()->json([
                'success' => true,
                'data' => $concerns->items(),
                'pagination' => [
                    'current_page' => $concerns->currentPage(),
                    'last_page' => $concerns->lastPage(),
                    'per_page' => $concerns->perPage(),
                    'total' => $concerns->total(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch concerns',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Create new concern
     */
    public function store(StoreConcernRequest $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $data = $request->validated();
            $data['student_id'] = $user->id;
            $data['reference_number'] = $this->generateReferenceNumber();
            $data['status'] = 'pending';

            $concern = Concern::create($data);

            // Log the creation
            $this->auditLogService->log($user, 'create', $concern, null, [
                'subject' => $concern->subject,
                'type' => $concern->type,
                'priority' => $concern->priority,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Concern submitted successfully',
                'data' => $concern->load(['student', 'department', 'facility']),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create concern',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get specific concern
     */
    public function show(Concern $concern): JsonResponse
    {
        $user = auth()->user();

        try {
            // Check if user can view this concern
            if ($user->role === 'student' && $concern->student_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Concern not found',
                ], 404);
            }

            $concern->load(['student', 'department', 'facility', 'assignedTo', 'messages.author']);

            return response()->json([
                'success' => true,
                'data' => $concern,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch concern',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Update concern
     */
    public function update(UpdateConcernRequest $request, Concern $concern): JsonResponse
    {
        $user = auth()->user();

        try {
            $data = $request->validated();
            $oldData = $concern->toArray();
            $concern->update($data);

            // Log the update
            $this->auditLogService->log($user, 'update', $concern, $oldData, [
                'subject' => $concern->subject,
                'changes' => array_keys($data),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Concern updated successfully',
                'data' => $concern->load(['student', 'department', 'facility', 'assignedTo']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update concern',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Delete concern
     */
    public function destroy(Concern $concern): JsonResponse
    {
        $user = auth()->user();

        try {
            // Only students can delete their own concerns, and only if pending
            if ($user->role === 'student' && ($concern->student_id !== $user->id || $concern->status !== 'pending')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete this concern',
                ], 403);
            }

            $concernData = $concern->toArray();
            $concern->delete();

            // Log the deletion
            $this->auditLogService->log($user, 'delete', null, $concernData, [
                'subject' => $concernData['subject'],
                'reference_number' => $concernData['reference_number'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Concern deleted successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete concern',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Add message to concern
     */
    public function addMessage(Request $request, Concern $concern): JsonResponse
    {
        $user = auth()->user();

        $request->validate([
            'message' => 'required|string|max:2000',
            'attachments' => 'nullable|array',
            'attachments.*' => 'string',
            'is_internal' => 'nullable|boolean',
        ]);

        try {
            $message = ConcernMessage::create([
                'concern_id' => $concern->id,
                'author_id' => $user->id,
                'message' => $request->input('message'),
                'type' => 'message',
                'attachments' => $request->input('attachments', []),
                'is_internal' => $request->boolean('is_internal', false),
            ]);

            // Update concern's last activity
            $concern->touch();

            // Log the message
            $this->auditLogService->log($user, 'concern_message', $concern, null, [
                'message_length' => strlen($request->input('message')),
                'has_attachments' => !empty($request->input('attachments')),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Message added successfully',
                'data' => $message->load('author'),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to add message',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get concern messages
     */
    public function getMessages(Concern $concern): JsonResponse
    {
        $user = auth()->user();

        try {
            // Check access
            if ($user->role === 'student' && $concern->student_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Access denied',
                ], 403);
            }

            $messages = $concern->messages()
                ->with('author')
                ->when($user->role === 'student', function ($query) {
                    $query->where('is_internal', false);
                })
                ->orderBy('created_at', 'asc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $messages,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch messages',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Update concern status
     */
    public function updateStatus(Request $request, Concern $concern): JsonResponse
    {
        $user = auth()->user();

        $request->validate([
            'status' => 'required|in:pending,in_progress,resolved,closed,cancelled',
            'note' => 'nullable|string|max:500',
        ]);

        try {
            $oldStatus = $concern->status;
            $newStatus = $request->input('status');

            $concern->update([
                'status' => $newStatus,
                'resolved_at' => $newStatus === 'resolved' ? now() : null,
                'closed_at' => $newStatus === 'closed' ? now() : null,
            ]);

            // Add status change message
            if ($request->filled('note')) {
                ConcernMessage::create([
                    'concern_id' => $concern->id,
                    'author_id' => $user->id,
                    'message' => $request->input('note'),
                    'type' => 'status_change',
                    'metadata' => [
                        'old_status' => $oldStatus,
                        'new_status' => $newStatus,
                    ],
                ]);
            }

            // Log the status change
            $this->auditLogService->log($user, 'status_change', $concern, null, [
                'old_status' => $oldStatus,
                'new_status' => $newStatus,
                'has_note' => $request->filled('note'),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Status updated successfully',
                'data' => $concern->fresh(['student', 'department', 'facility', 'assignedTo']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update status',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Assign concern to user
     */
    public function assign(Request $request, Concern $concern): JsonResponse
    {
        $user = auth()->user();

        $request->validate([
            'assigned_to' => 'required|exists:users,id',
        ]);

        try {
            $oldAssignee = $concern->assigned_to;
            $concern->update(['assigned_to' => $request->input('assigned_to')]);

            // Add assignment message
            ConcernMessage::create([
                'concern_id' => $concern->id,
                'author_id' => $user->id,
                'message' => 'Concern assigned to ' . $concern->assignedTo->name,
                'type' => 'assignment',
                'metadata' => [
                    'old_assignee' => $oldAssignee,
                    'new_assignee' => $request->input('assigned_to'),
                ],
            ]);

            // Log the assignment
            $this->auditLogService->log($user, 'assign', $concern, null, [
                'old_assignee' => $oldAssignee,
                'new_assignee' => $request->input('assigned_to'),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Concern assigned successfully',
                'data' => $concern->fresh(['student', 'department', 'facility', 'assignedTo']),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to assign concern',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get concern history
     */
    public function getHistory(Concern $concern): JsonResponse
    {
        try {
            $history = $concern->messages()
                ->with('author')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($message) {
                    return [
                        'id' => $message->id,
                        'type' => $message->type,
                        'message' => $message->message,
                        'author' => [
                            'id' => $message->author->id,
                            'name' => $message->author->name,
                            'role' => $message->author->role,
                        ],
                        'metadata' => $message->metadata,
                        'created_at' => $message->created_at,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $history,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch concern history',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Upload attachment for concern
     */
    public function uploadAttachment(Request $request, Concern $concern): JsonResponse
    {
        $request->validate([
            'file' => 'required|file|max:10240', // 10MB max
            'description' => 'nullable|string|max:255',
        ]);

        try {
            // TODO: Implement file upload to storage
            // For now, return a placeholder response
            return response()->json([
                'success' => false,
                'message' => 'File upload functionality not yet implemented',
            ], 501);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload attachment',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Generate unique reference number
     */
    private function generateReferenceNumber(): string
    {
        $prefix = 'CNR';
        $year = date('Y');
        $month = date('m');
        
        $lastConcern = Concern::whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->orderBy('id', 'desc')
            ->first();

        if ($lastConcern) {
            $lastNumber = (int) substr($lastConcern->reference_number, -4);
            $newNumber = str_pad($lastNumber + 1, 4, '0', STR_PAD_LEFT);
        } else {
            $newNumber = '0001';
        }

        return $prefix . $year . $month . $newNumber;
    }
}
