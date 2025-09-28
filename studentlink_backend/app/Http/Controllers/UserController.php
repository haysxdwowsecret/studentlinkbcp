<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Models\User;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    protected AuditLogService $auditLogService;

    public function __construct(AuditLogService $auditLogService)
    {
        $this->auditLogService = $auditLogService;
    }

    /**
     * Get users list (Admin/Department Head only)
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = User::with('department');

            // Filter by role
            if ($request->filled('role')) {
                $query->where('role', $request->input('role'));
            }

            // Filter by department
            if ($request->filled('department_id')) {
                $query->where('department_id', $request->input('department_id'));
            }

            // Filter by active status
            if ($request->has('is_active')) {
                $query->where('is_active', $request->boolean('is_active'));
            }

            // Search by name or email
            if ($request->filled('search')) {
                $search = $request->input('search');
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('display_id', 'like', "%{$search}%");
                });
            }

            $users = $query
                ->orderBy('created_at', 'desc')
                ->paginate($request->input('per_page', 20));

            return response()->json([
                'success' => true,
                'data' => $users->items(),
                'pagination' => [
                    'current_page' => $users->currentPage(),
                    'last_page' => $users->lastPage(),
                    'per_page' => $users->perPage(),
                    'total' => $users->total(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch users',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Create new user (Admin only)
     */
    public function store(StoreUserRequest $request): JsonResponse
    {
        $authUser = auth()->user();

        try {
            $data = $request->validated();
            $data['password'] = Hash::make($data['password']);

            // Generate display_id for students
            if ($data['role'] === 'student') {
                $data['display_id'] = $this->generateStudentId();
            }

            $user = User::create($data);

            // Log the creation
            $this->auditLogService->log($authUser, 'create', $user, null, [
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User created successfully',
                'data' => $user->load('department'),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create user',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get specific user
     */
    public function show(User $user): JsonResponse
    {
        $authUser = auth()->user();

        try {
            // Check if user can view this profile
            if ($authUser->role === 'student' && $authUser->id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            $user->load('department');

            return response()->json([
                'success' => true,
                'data' => $user,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch user',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Update user
     */
    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $authUser = auth()->user();

        try {
            $data = $request->validated();

            // Hash password if provided
            if (isset($data['password'])) {
                $data['password'] = Hash::make($data['password']);
            }

            $oldData = $user->toArray();
            $user->update($data);

            // Log the update
            $this->auditLogService->log($authUser, 'update', $user, $oldData, [
                'name' => $user->name,
                'changes' => array_keys($data),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User updated successfully',
                'data' => $user->load('department'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update user',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Delete user (Admin only)
     */
    public function destroy(User $user): JsonResponse
    {
        $authUser = auth()->user();

        try {
            // Prevent self-deletion
            if ($authUser->id === $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete your own account',
                ], 400);
            }

            $userData = $user->toArray();
            $user->delete();

            // Log the deletion
            $this->auditLogService->log($authUser, 'delete', null, $userData, [
                'name' => $userData['name'],
                'email' => $userData['email'],
                'id' => $userData['id'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete user',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get current user profile
     */
    public function profile(): JsonResponse
    {
        $user = auth()->user();

        try {
            $user->load('department');

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'department' => $user->department->name,
                    'department_id' => $user->department_id,
                    'display_id' => $user->display_id,
                    'avatar' => $user->avatar,
                    'phone' => $user->phone,
                    'preferences' => $user->preferences,
                    'last_login_at' => $user->last_login_at,
                    'created_at' => $user->created_at,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch profile',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Update current user profile
     */
    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $data = $request->validated();

            // Hash password if provided
            if (isset($data['password'])) {
                $data['password'] = Hash::make($data['password']);
            }

            $oldData = $user->toArray();
            $user->update($data);

            // Log the profile update
            $this->auditLogService->log($user, 'profile_update', $user, $oldData, [
                'changes' => array_keys($data),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => $user->load('department'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update profile',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Upload user avatar
     */
    public function uploadAvatar(Request $request): JsonResponse
    {
        $user = auth()->user();

        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        try {
            $file = $request->file('avatar');
            $filename = 'avatars/' . $user->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            
            // Store the file
            $path = Storage::disk('public')->putFileAs('', $file, $filename);

            // Delete old avatar if exists
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }

            // Update user avatar
            $user->update(['avatar' => $path]);

            // Log the avatar upload
            $this->auditLogService->log($user, 'avatar_upload', $user, null, [
                'filename' => $filename,
                'size' => $file->getSize(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Avatar uploaded successfully',
                'data' => [
                    'avatar' => Storage::disk('public')->url($path),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload avatar',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Generate student ID
     */
    private function generateStudentId(): string
    {
        $year = date('Y');
        $lastStudent = User::where('role', 'student')
            ->where('display_id', 'like', $year . '-%')
            ->orderBy('display_id', 'desc')
            ->first();

        if ($lastStudent) {
            $lastNumber = (int) substr($lastStudent->display_id, -3);
            $newNumber = str_pad($lastNumber + 1, 3, '0', STR_PAD_LEFT);
        } else {
            $newNumber = '001';
        }

        return $year . '-' . $newNumber;
    }
}
