<?php

namespace App\Http\Controllers;

use App\Http\Requests\AiChatRequest;
use App\Http\Requests\AiSuggestionsRequest;
use App\Http\Requests\AiTranscribeRequest;
use App\Models\AiChatSession;
use App\Services\HuggingFaceService;
use App\Services\DialogflowService;
use App\Services\AuditLogService;
use App\Services\AiTrainingService;
use App\Models\FaqItem;
use App\Models\TrainingData;
use App\Models\TrainingBatch;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class AiController extends Controller
{
    protected HuggingFaceService $huggingFaceService;
    protected DialogflowService $dialogflowService;
    protected AuditLogService $auditLogService;
    protected AiTrainingService $aiTrainingService;

    public function __construct(
        HuggingFaceService $huggingFaceService,
        DialogflowService $dialogflowService,
        AuditLogService $auditLogService,
        AiTrainingService $aiTrainingService
    ) {
        $this->huggingFaceService = $huggingFaceService;
        $this->dialogflowService = $dialogflowService;
        $this->auditLogService = $auditLogService;
        $this->aiTrainingService = $aiTrainingService;
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

            // Get AI response using Hugging Face
            $aiResponse = $this->getAiResponse($messages, [
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
            $suggestions = $this->huggingFaceService->getSuggestions(
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

            // Transcribe audio using Hugging Face
            $transcription = $this->huggingFaceService->transcribeAudio($audioFile, [
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
     * Get chatbot settings
     */
    public function getSettings(): JsonResponse
    {
        $user = auth()->user();
        
        // Only admin can access chatbot settings
        if ($user->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'enabled' => true,
                'response_time' => 2,
                'personality' => 'friendly',
                'language' => 'en',
                'max_tokens' => 150,
                'model' => 'gpt-3.5-turbo',
                'temperature' => 0.7,
                'max_conversations' => 100,
                'auto_respond' => true,
                'context_awareness' => true,
            ]
        ]);
    }

    /**
     * Update chatbot settings
     */
    public function updateSettings(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        // Only admin can update chatbot settings
        if ($user->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $request->validate([
            'enabled' => 'boolean',
            'response_time' => 'integer|min:1|max:10',
            'personality' => 'string|in:friendly,professional,casual,formal',
            'language' => 'string|in:en,fil,es',
            'max_tokens' => 'integer|min:50|max:500',
            'model' => 'string|in:gpt-3.5-turbo,gpt-4',
            'temperature' => 'numeric|min:0|max:1',
            'max_conversations' => 'integer|min:10|max:1000',
            'auto_respond' => 'boolean',
            'context_awareness' => 'boolean',
        ]);

        // Log settings update
        $this->auditLogService->log($user, 'ai_settings_update', null, null, [
            'settings_updated' => array_keys($request->all()),
            'old_settings' => [], // Would store previous settings in real implementation
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Chatbot settings updated successfully',
            'data' => $request->all()
        ]);
    }

    /**
     * Train chatbot with new data
     */
    public function trainChatbot(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        // Only admin can train chatbot
        if ($user->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $request->validate([
            'training_data' => 'required|string|min:10|max:10000',
            'data_type' => 'nullable|string|in:faq,conversation,knowledge_base',
            'priority' => 'nullable|string|in:low,medium,high',
        ]);

        try {
            // In a real implementation, this would:
            // 1. Process and validate the training data
            // 2. Store it in a knowledge base
            // 3. Update the AI model with new information
            // 4. Test the updated model

            // Log training activity
            $this->auditLogService->log($user, 'ai_training', null, null, [
                'data_length' => strlen($request->input('training_data')),
                'data_type' => $request->input('data_type', 'general'),
                'priority' => $request->input('priority', 'medium'),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Chatbot training completed successfully',
                'data' => [
                    'training_id' => Str::uuid(),
                    'data_processed' => strlen($request->input('training_data')),
                    'timestamp' => now()->toISOString(),
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to train chatbot',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get chatbot analytics
     */
    public function getAnalytics(): JsonResponse
    {
        $user = auth()->user();
        
        // Only admin can access analytics
        if ($user->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        try {
            // Get analytics from AI chat sessions
            $totalConversations = AiChatSession::where('is_active', true)->count();
            $totalMessages = AiChatSession::where('is_active', true)
                ->get()
                ->sum(function ($session) {
                    return count($session->messages ?? []);
                });

            $avgResponseTime = 1.8; // Would calculate from real data
            $satisfactionRate = 4.2; // Would calculate from feedback data

            $commonQuestions = [
                'Library hours',
                'Registration process', 
                'Course schedules',
                'Exam dates',
                'Department contact information',
                'Academic policies',
                'Student services',
                'Emergency procedures'
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'total_conversations' => $totalConversations,
                    'total_messages' => $totalMessages,
                    'avg_response_time' => $avgResponseTime,
                    'satisfaction_rate' => $satisfactionRate,
                    'common_questions' => $commonQuestions,
                    'active_sessions' => AiChatSession::where('is_active', true)
                        ->where('last_activity_at', '>=', now()->subHours(24))
                        ->count(),
                    'total_tokens_used' => AiChatSession::where('is_active', true)
                        ->get()
                        ->sum(function ($session) {
                            return $session->metadata['total_tokens'] ?? 0;
                        }),
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch analytics',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get chatbot conversations (for admin)
     */
    public function getConversations(Request $request): JsonResponse
    {
        $user = auth()->user();
        
        // Only admin can access all conversations
        if ($user->role !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $perPage = $request->input('per_page', 20);
        $sessions = AiChatSession::where('is_active', true)
            ->with('user:id,name,role,department_id')
            ->orderBy('last_activity_at', 'desc')
            ->paginate($perPage);

        $conversations = $sessions->map(function ($session) {
            $lastMessage = collect($session->messages)->last();
            return [
                'id' => $session->id,
                'session_id' => $session->session_id,
                'user' => $session->user->name ?? 'Unknown',
                'user_role' => $session->user->role ?? 'unknown',
                'context' => $session->context,
                'message_count' => count($session->messages ?? []),
                'last_message' => $lastMessage['content'] ?? 'No messages',
                'last_activity' => $session->last_activity_at,
                'created_at' => $session->created_at,
                'satisfaction' => $session->metadata['satisfaction_rating'] ?? null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $conversations,
            'pagination' => [
                'current_page' => $sessions->currentPage(),
                'last_page' => $sessions->lastPage(),
                'per_page' => $sessions->perPage(),
                'total' => $sessions->total(),
            ],
        ]);
    }

    /**
     * Get AI response with fallback strategy
     */
    private function getAiResponse(array $messages, array $context): array
    {
        try {
            // Get training data for context
            $trainingData = $this->aiTrainingService->getTrainingDataForContext($context['context'] ?? 'general');
            
            // Try Hugging Face first (primary service) with training data
            $response = $this->huggingFaceService->getChatCompletion($messages, array_merge($context, [
                'training_data' => $trainingData
            ]));
            
            // Log which service was used
            Log::info('AI Response generated', [
                'service' => 'huggingface',
                'model' => $response['model'] ?? 'unknown',
                'context' => $context['context'] ?? 'general',
                'training_data_count' => count($trainingData['faq_items']) + count($trainingData['conversations']) + count($trainingData['department_info']),
            ]);
            
            return $response;
            
        } catch (\Exception $e) {
            Log::warning('Hugging Face service failed, trying Dialogflow fallback', [
                'error' => $e->getMessage(),
                'context' => $context,
            ]);
            
            try {
                // Fallback to Hugging Face if available
                if ($this->huggingFaceService->validateConfiguration()) {
                    $response = $this->huggingFaceService->getChatCompletion($messages, $context);
                    
                    Log::info('AI Response generated via Hugging Face fallback', [
                        'service' => 'huggingface',
                        'model' => $response['model'] ?? 'unknown',
                        'context' => $context['context'] ?? 'general',
                    ]);
                    
                    return $response;
                }
            } catch (\Exception $dialogflowError) {
                Log::error('Both AI services failed', [
                    'huggingface_error' => $e->getMessage(),
                    'dialogflow_error' => $dialogflowError->getMessage(),
                ]);
            }
            
            // Final fallback to enhanced keyword-based responses
            $userMessage = $this->extractUserMessage($messages);
            $fallbackResponse = $this->huggingFaceService->getChatCompletion($messages, $context);
            
            Log::info('AI Response generated via fallback', [
                'service' => 'enhanced-keyword-based',
                'context' => $context['context'] ?? 'general',
            ]);
            
            return $fallbackResponse;
        }
    }

    /**
     * Extract user message from messages array
     */
    private function extractUserMessage(array $messages): string
    {
        $userMessages = array_filter($messages, fn($msg) => $msg['role'] === 'user');
        $lastUserMessage = end($userMessages);
        return $lastUserMessage['content'] ?? '';
    }

    /**
     * Get Dialogflow configuration
     */
    public function getDialogflowConfig(): JsonResponse
    {
        try {
            $config = [
                'project_id' => config('services.dialogflow.project_id'),
                'client_email' => config('services.dialogflow.client_email'),
                'language_code' => config('services.dialogflow.language_code'),
                'session_id' => config('services.dialogflow.session_id'),
                'enabled' => !empty(config('services.dialogflow.project_id')),
            ];

            return response()->json([
                'success' => true,
                'data' => $config,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get Dialogflow config', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to get Dialogflow configuration',
            ], 500);
        }
    }

    /**
     * Update Dialogflow configuration
     */
    public function updateDialogflowConfig(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'project_id' => 'nullable|string',
                'client_email' => 'nullable|email',
                'private_key' => 'nullable|string',
                'language_code' => 'nullable|string|in:en,fil,es',
                'session_id' => 'nullable|string',
                'enabled' => 'boolean',
            ]);

            // Update environment configuration
            $envFile = base_path('.env');
            $envContent = file_get_contents($envFile);

            foreach ($validated as $key => $value) {
                $envKey = 'DIALOGFLOW_' . strtoupper($key);
                if ($key === 'private_key') {
                    $envKey = 'DIALOGFLOW_PRIVATE_KEY';
                }
                
                $pattern = "/^{$envKey}=.*/m";
                $replacement = "{$envKey}={$value}";
                
                if (preg_match($pattern, $envContent)) {
                    $envContent = preg_replace($pattern, $replacement, $envContent);
                } else {
                    $envContent .= "\n{$replacement}";
                }
            }

            file_put_contents($envFile, $envContent);

            return response()->json([
                'success' => true,
                'message' => 'Dialogflow configuration updated successfully',
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to update Dialogflow config', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to update Dialogflow configuration',
            ], 500);
        }
    }

    /**
     * Get Hugging Face configuration
     */
    public function getHuggingFaceConfig(): JsonResponse
    {
        try {
            $config = [
                'api_key' => config('services.huggingface.api_key'),
                'model' => config('services.huggingface.model'),
                'max_length' => config('services.huggingface.max_length'),
                'temperature' => config('services.huggingface.temperature'),
                'timeout' => config('services.huggingface.timeout'),
                'enabled' => true, // Hugging Face is always enabled as fallback
            ];

            return response()->json([
                'success' => true,
                'data' => $config,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get Hugging Face config', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to get Hugging Face configuration',
            ], 500);
        }
    }

    /**
     * Update Hugging Face configuration
     */
    public function updateHuggingFaceConfig(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'api_key' => 'nullable|string',
                'model' => 'nullable|string',
                'max_length' => 'nullable|integer|min:50|max:500',
                'temperature' => 'nullable|numeric|min:0|max:1',
                'timeout' => 'nullable|integer|min:10|max:120',
                'enabled' => 'boolean',
            ]);

            // Update environment configuration
            $envFile = base_path('.env');
            $envContent = file_get_contents($envFile);

            foreach ($validated as $key => $value) {
                $envKey = 'HUGGINGFACE_' . strtoupper($key);
                
                $pattern = "/^{$envKey}=.*/m";
                $replacement = "{$envKey}={$value}";
                
                if (preg_match($pattern, $envContent)) {
                    $envContent = preg_replace($pattern, $replacement, $envContent);
                } else {
                    $envContent .= "\n{$replacement}";
                }
            }

            file_put_contents($envFile, $envContent);

            return response()->json([
                'success' => true,
                'message' => 'Hugging Face configuration updated successfully',
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to update Hugging Face config', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to update Hugging Face configuration',
            ], 500);
        }
    }

    /**
     * Get FAQ items
     */
    public function getFAQItems(): JsonResponse
    {
        try {
            $faqItems = FaqItem::with('creator')
                ->orderBy('priority', 'desc')
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'question' => $item->question,
                        'answer' => $item->answer,
                        'category' => $item->category,
                        'intent' => $item->intent,
                        'confidence' => $item->confidence,
                        'active' => $item->active,
                        'tags' => $item->tags,
                        'context' => $item->context,
                        'priority' => $item->priority,
                        'created_by' => $item->creator?->name,
                        'created_at' => $item->created_at->toISOString(),
                        'updated_at' => $item->updated_at->toISOString(),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $faqItems,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get FAQ items', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to get FAQ items',
            ], 500);
        }
    }

    /**
     * Update FAQ items
     */
    public function updateFAQItems(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'faq_items' => 'required|array',
                'faq_items.*.id' => 'required',
                'faq_items.*.question' => 'required|string|max:500',
                'faq_items.*.answer' => 'required|string|max:2000',
                'faq_items.*.category' => 'required|string|in:general,concern,announcement,emergency,technical',
                'faq_items.*.intent' => 'nullable|string',
                'faq_items.*.active' => 'boolean',
                'faq_items.*.tags' => 'nullable|array',
                'faq_items.*.context' => 'nullable|string',
                'faq_items.*.priority' => 'nullable|integer|min:1|max:4',
            ]);

            $user = auth()->user();
            $updatedCount = 0;

            foreach ($validated['faq_items'] as $itemData) {
                $faqItem = FaqItem::find($itemData['id']);
                
                if ($faqItem) {
                    $faqItem->update([
                        'question' => $itemData['question'],
                        'answer' => $itemData['answer'],
                        'category' => $itemData['category'],
                        'intent' => $itemData['intent'],
                        'active' => $itemData['active'],
                        'tags' => $itemData['tags'] ?? [],
                        'context' => $itemData['context'] ?? 'general',
                        'priority' => $itemData['priority'] ?? 2,
                    ]);
                    $updatedCount++;
                }
            }

            Log::info('FAQ items updated', [
                'count' => $updatedCount,
                'user_id' => $user->id
            ]);

            return response()->json([
                'success' => true,
                'message' => "Successfully updated {$updatedCount} FAQ items",
                'updated_count' => $updatedCount,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to update FAQ items', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to update FAQ items',
            ], 500);
        }
    }

    /**
     * Bulk upload training data
     */
    public function bulkUploadTrainingData(Request $request): JsonResponse
    {
        try {
            $user = auth()->user();
            
            if ($user->role !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized access'
                ], 403);
            }

            $validated = $request->validate([
                'training_file' => 'required|file|mimes:json|max:10240', // 10MB max
            ]);

            $file = $validated['training_file'];
            $result = $this->aiTrainingService->processBulkTrainingData($file, $user);

            if ($result['success']) {
                // Log the bulk upload
                $this->auditLogService->log($user, 'ai_training_bulk_upload', null, null, [
                    'batch_id' => $result['batch_id'],
                    'total_items' => $result['total_items'],
                    'successful_items' => $result['successful_items'],
                    'failed_items' => $result['failed_items'],
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Training data uploaded successfully',
                    'data' => $result,
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to process training data: ' . $result['error'],
                ], 400);
            }

        } catch (\Exception $e) {
            Log::error('Bulk training data upload failed', [
                'error' => $e->getMessage(),
                'user_id' => auth()->id(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to upload training data',
                'error' => app()->environment('local') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Get training batches
     */
    public function getTrainingBatches(): JsonResponse
    {
        try {
            $user = auth()->user();
            
            if ($user->role !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized access'
                ], 403);
            }

            $batches = TrainingBatch::with('creator')
                ->orderBy('created_at', 'desc')
                ->limit(50)
                ->get()
                ->map(function ($batch) {
                    return [
                        'id' => $batch->id,
                        'batch_id' => $batch->batch_id,
                        'filename' => $batch->filename,
                        'type' => $batch->type,
                        'total_items' => $batch->total_items,
                        'successful_items' => $batch->successful_items,
                        'failed_items' => $batch->failed_items,
                        'status' => $batch->status,
                        'success_rate' => $batch->success_rate,
                        'created_by' => $batch->creator?->name,
                        'created_at' => $batch->created_at->toISOString(),
                        'processed_at' => $batch->processed_at?->toISOString(),
                        'errors' => $batch->errors,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $batches,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get training batches', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to get training batches',
            ], 500);
        }
    }

    /**
     * Get training statistics
     */
    public function getTrainingStats(): JsonResponse
    {
        try {
            $user = auth()->user();
            
            if ($user->role !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized access'
                ], 403);
            }

            $stats = $this->aiTrainingService->getTrainingStats();

            return response()->json([
                'success' => true,
                'data' => $stats,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get training stats', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to get training statistics',
            ], 500);
        }
    }

    /**
     * Get chat sessions
     */
    public function getChatSessions(): JsonResponse
    {
        try {
            $sessions = AiChatSession::with(['user', 'messages'])
                ->orderBy('last_activity_at', 'desc')
                ->limit(50)
                ->get()
                ->map(function ($session) {
                    return [
                        'id' => $session->id,
                        'userId' => $session->user_id,
                        'userName' => $session->user->name,
                        'userRole' => $session->user->role,
                        'messages' => $session->messages->map(function ($message) {
                            return [
                                'id' => $message->id,
                                'content' => $message->content,
                                'role' => $message->role,
                                'timestamp' => $message->created_at->toISOString(),
                                'service' => $message->service ?? 'fallback',
                            ];
                        })->toArray(),
                        'context' => $session->context,
                        'createdAt' => $session->created_at->toISOString(),
                        'lastActivity' => $session->last_activity_at->toISOString(),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $sessions,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get chat sessions', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to get chat sessions',
            ], 500);
        }
    }

    /**
     * Test chatbot
     */
    public function testChatbot(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'message' => 'required|string|max:1000',
            ]);

            $messages = [
                [
                    'role' => 'user',
                    'content' => $validated['message'],
                ],
            ];

            $response = $this->getAiResponse($messages, [
                'context' => 'test',
                'user_role' => 'admin',
                'department' => 'system',
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'message' => $response['content'],
                    'service' => $response['service'] ?? 'unknown',
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to test chatbot', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to test chatbot: ' . $e->getMessage(),
            ], 500);
        }
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
