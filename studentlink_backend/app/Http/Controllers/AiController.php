<?php

namespace App\Http\Controllers;

use App\Http\Requests\AiChatRequest;
use App\Http\Requests\AiSuggestionsRequest;
use App\Http\Requests\AiTranscribeRequest;
use App\Models\AiChatSession;
use App\Services\OpenAiService;
use App\Services\DialogflowService;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AiController extends Controller
{
    protected OpenAiService $openAiService;
    protected DialogflowService $dialogflowService;
    protected AuditLogService $auditLogService;

    public function __construct(
        OpenAiService $openAiService,
        DialogflowService $dialogflowService,
        AuditLogService $auditLogService
    ) {
        $this->openAiService = $openAiService;
        $this->dialogflowService = $dialogflowService;
        $this->auditLogService = $auditLogService;
    }

    /**
     * Chat with AI assistant
     */
    public function chat(AiChatRequest $request): JsonResponse
    {
        $user = auth()->user();
        $data = $request->validated();

        try {
            // Get or create chat session
            $session = $this->getOrCreateSession($data['session_id'] ?? null, $user, $data['context'] ?? 'general');

            // Add user message to session
            $messages = $session->messages;
            $messages[] = [
                'role' => 'user',
                'content' => $data['message'],
                'timestamp' => now()->toISOString(),
            ];

            // Get AI response
            $aiResponse = $this->openAiService->getChatCompletion($messages, [
                'context' => $data['context'] ?? 'general',
                'user_role' => $user->role,
                'department' => $user->department->name,
            ]);

            // Add AI response to session
            $messages[] = [
                'role' => 'assistant',
                'content' => $aiResponse['content'],
                'timestamp' => now()->toISOString(),
                'model' => $aiResponse['model'],
                'tokens_used' => $aiResponse['tokens_used'] ?? null,
            ];

            // Update session
            $session->update([
                'messages' => $messages,
                'last_activity_at' => now(),
                'metadata' => array_merge($session->metadata ?? [], [
                    'total_messages' => count($messages),
                    'total_tokens' => ($session->metadata['total_tokens'] ?? 0) + ($aiResponse['tokens_used'] ?? 0),
                ]),
            ]);

            // Log AI interaction
            $this->auditLogService->log($user, 'ai_chat', $session, null, [
                'message_length' => strlen($data['message']),
                'response_length' => strlen($aiResponse['content']),
                'tokens_used' => $aiResponse['tokens_used'] ?? null,
                'context' => $data['context'] ?? 'general',
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'session_id' => $session->session_id,
                    'message' => $aiResponse['content'],
                    'timestamp' => now()->toISOString(),
                    'metadata' => [
                        'model' => $aiResponse['model'],
                        'tokens_used' => $aiResponse['tokens_used'] ?? null,
                    ],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to process AI chat request',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get AI suggestions for message composition
     */
    public function getSuggestions(AiSuggestionsRequest $request): JsonResponse
    {
        $user = auth()->user();
        $data = $request->validated();

        try {
            $suggestions = $this->openAiService->getSuggestions(
                $data['context'],
                $data['type'],
                $data['existing_text'] ?? '',
                [
                    'user_role' => $user->role,
                    'department' => $user->department->name,
                    'tone' => $data['tone'] ?? 'professional',
                ]
            );

            // Log suggestion request
            $this->auditLogService->log($user, 'ai_suggestions', null, null, [
                'context' => $data['context'],
                'type' => $data['type'],
                'suggestions_count' => count($suggestions),
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'suggestions' => $suggestions,
                    'context' => $data['context'],
                    'type' => $data['type'],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate suggestions',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Transcribe audio to text
     */
    public function transcribeAudio(AiTranscribeRequest $request): JsonResponse
    {
        $user = auth()->user();

        try {
            $audioFile = $request->file('audio');
            
            // Validate audio file
            if (!$audioFile->isValid()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid audio file',
                ], 400);
            }

            // Transcribe audio using OpenAI Whisper
            $transcription = $this->openAiService->transcribeAudio($audioFile, [
                'language' => $request->input('language', 'en'),
                'response_format' => 'json',
            ]);

            // Log transcription request
            $this->auditLogService->log($user, 'ai_transcribe', null, null, [
                'file_size' => $audioFile->getSize(),
                'duration' => $transcription['duration'] ?? null,
                'language' => $request->input('language', 'en'),
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'text' => $transcription['text'],
                    'language' => $transcription['language'] ?? null,
                    'duration' => $transcription['duration'] ?? null,
                    'confidence' => $transcription['confidence'] ?? null,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to transcribe audio',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get user's AI chat sessions
     */
    public function getSessions(Request $request): JsonResponse
    {
        $user = auth()->user();

        $sessions = AiChatSession::where('user_id', $user->id)
            ->where('is_active', true)
            ->orderBy('last_activity_at', 'desc')
            ->paginate($request->input('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $sessions->items(),
            'pagination' => [
                'current_page' => $sessions->currentPage(),
                'last_page' => $sessions->lastPage(),
                'per_page' => $sessions->perPage(),
                'total' => $sessions->total(),
            ],
        ]);
    }

    /**
     * Create a new AI chat session
     */
    public function createSession(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        $request->validate([
            'context' => 'nullable|string|in:general,concern,assistance',
            'related_concern_id' => 'nullable|exists:concerns,id',
        ]);

        $session = AiChatSession::create([
            'user_id' => $user->id,
            'session_id' => Str::uuid(),
            'context' => $request->input('context', 'general'),
            'related_concern_id' => $request->input('related_concern_id'),
            'messages' => [],
            'metadata' => [
                'created_by_role' => $user->role,
                'department' => $user->department->name,
            ],
            'last_activity_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'session_id' => $session->session_id,
                'context' => $session->context,
                'created_at' => $session->created_at,
            ],
        ]);
    }

    /**
     * Get specific AI chat session
     */
    public function getSession(string $sessionId): JsonResponse
    {
        $user = auth()->user();

        $session = AiChatSession::where('session_id', $sessionId)
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'Session not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'session_id' => $session->session_id,
                'context' => $session->context,
                'messages' => $session->messages,
                'metadata' => $session->metadata,
                'last_activity_at' => $session->last_activity_at,
                'created_at' => $session->created_at,
            ],
        ]);
    }

    /**
     * Delete AI chat session
     */
    public function deleteSession(string $sessionId): JsonResponse
    {
        $user = auth()->user();

        $session = AiChatSession::where('session_id', $sessionId)
            ->where('user_id', $user->id)
            ->first();

        if (!$session) {
            return response()->json([
                'success' => false,
                'message' => 'Session not found',
            ], 404);
        }

        $session->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Session deleted successfully',
        ]);
    }

    /**
     * Get or create a chat session
     */
    private function getOrCreateSession(?string $sessionId, $user, string $context): AiChatSession
    {
        if ($sessionId) {
            $session = AiChatSession::where('session_id', $sessionId)
                ->where('user_id', $user->id)
                ->where('is_active', true)
                ->first();

            if ($session) {
                return $session;
            }
        }

        return AiChatSession::create([
            'user_id' => $user->id,
            'session_id' => Str::uuid(),
            'context' => $context,
            'messages' => [],
            'metadata' => [
                'created_by_role' => $user->role,
                'department' => $user->department->name,
            ],
            'last_activity_at' => now(),
        ]);
    }
}
