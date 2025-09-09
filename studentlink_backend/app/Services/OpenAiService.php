<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OpenAiService
{
    protected string $apiKey;
    protected string $baseUrl;
    protected string $model;

    public function __construct()
    {
        $this->apiKey = config('services.openai.api_key');
        $this->baseUrl = config('services.openai.base_url', 'https://api.openai.com/v1');
        $this->model = config('services.openai.model', 'gpt-3.5-turbo');
    }

    /**
     * Get chat completion from OpenAI
     */
    public function getChatCompletion(array $messages, array $context = []): array
    {
        $systemPrompt = $this->buildSystemPrompt($context);
        
        $payload = [
            'model' => $this->model,
            'messages' => [
                ['role' => 'system', 'content' => $systemPrompt],
                ...$messages
            ],
            'max_tokens' => 1000,
            'temperature' => 0.7,
            'top_p' => 0.9,
            'frequency_penalty' => 0.3,
            'presence_penalty' => 0.3,
        ];

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'Content-Type' => 'application/json',
        ])->post($this->baseUrl . '/chat/completions', $payload);

        if (!$response->successful()) {
            Log::error('OpenAI API Error', [
                'status' => $response->status(),
                'response' => $response->body(),
            ]);
            throw new \Exception('Failed to get AI response');
        }

        $data = $response->json();

        return [
            'content' => $data['choices'][0]['message']['content'] ?? '',
            'model' => $data['model'] ?? $this->model,
            'tokens_used' => $data['usage']['total_tokens'] ?? null,
            'finish_reason' => $data['choices'][0]['finish_reason'] ?? null,
        ];
    }

    /**
     * Get AI suggestions for message composition
     */
    public function getSuggestions(string $context, string $type, string $existingText = '', array $options = []): array
    {
        $prompts = $this->buildSuggestionPrompts($context, $type, $existingText, $options);
        $suggestions = [];

        foreach ($prompts as $prompt) {
            try {
                $response = $this->getChatCompletion([
                    ['role' => 'user', 'content' => $prompt]
                ], $options);
                
                $suggestions[] = trim($response['content']);
            } catch (\Exception $e) {
                Log::error('Failed to generate suggestion', [
                    'prompt' => $prompt,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return array_filter($suggestions);
    }

    /**
     * Transcribe audio using OpenAI Whisper
     */
    public function transcribeAudio(UploadedFile $audioFile, array $options = []): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
        ])->attach(
            'file', 
            file_get_contents($audioFile->path()), 
            $audioFile->getClientOriginalName()
        )->post($this->baseUrl . '/audio/transcriptions', [
            'model' => 'whisper-1',
            'language' => $options['language'] ?? 'en',
            'response_format' => $options['response_format'] ?? 'json',
            'temperature' => 0,
        ]);

        if (!$response->successful()) {
            Log::error('OpenAI Whisper API Error', [
                'status' => $response->status(),
                'response' => $response->body(),
            ]);
            throw new \Exception('Failed to transcribe audio');
        }

        return $response->json();
    }

    /**
     * Build system prompt based on context
     */
    private function buildSystemPrompt(array $context): string
    {
        $basePrompt = "You are StudentLink Assistant, an AI helper for Bestlink College of the Philippines student support system. ";
        
        $roleContext = match($context['user_role'] ?? 'student') {
            'student' => "You're helping a student with their concerns and questions. Be empathetic, helpful, and guide them to appropriate resources.",
            'faculty' => "You're assisting a faculty member. Provide professional guidance and help them manage student concerns effectively.",
            'staff' => "You're helping a staff member. Focus on efficient concern resolution and administrative assistance.",
            'department_head' => "You're assisting a department head. Provide strategic insights and management guidance.",
            'admin' => "You're helping an administrator. Provide system-level insights and comprehensive support.",
            default => "Provide helpful and professional assistance."
        };

        $contextPrompt = match($context['context'] ?? 'general') {
            'concern' => "Focus on helping with student concern management, resolution strategies, and communication.",
            'assistance' => "Provide general assistance and guidance on using the StudentLink system.",
            default => "Provide general support and information about the StudentLink system."
        };

        return $basePrompt . $roleContext . " " . $contextPrompt . 
               " Always be professional, concise, and helpful. If you don't know something, suggest appropriate next steps or contacts.";
    }

    /**
     * Build suggestion prompts based on type and context
     */
    private function buildSuggestionPrompts(string $context, string $type, string $existingText, array $options): array
    {
        $tone = $options['tone'] ?? 'professional';
        $userRole = $options['user_role'] ?? 'student';

        $baseInstructions = "Generate helpful, {$tone} suggestions for ";

        return match($type) {
            'concern_reply' => [
                "{$baseInstructions} replying to a student concern. Existing text: '{$existingText}'. Provide 3 different response approaches.",
                "Create empathetic responses for a {$userRole} addressing a student concern. Keep responses professional and solution-focused.",
                "Suggest follow-up questions and next steps for resolving this concern efficiently."
            ],
            'announcement' => [
                "{$baseInstructions} creating an announcement for {$context}. Make it clear, engaging, and informative.",
                "Generate announcement templates that are appropriate for the college environment.",
                "Create compelling subject lines and content structures for this announcement."
            ],
            'message_completion' => [
                "{$baseInstructions} completing this message: '{$existingText}'. Maintain the same tone and intent.",
                "Provide natural completions that flow well with the existing text.",
                "Suggest professional endings and call-to-action phrases."
            ],
            default => [
                "{$baseInstructions} general communication in the StudentLink system. Be helpful and appropriate.",
                "Generate professional templates for common StudentLink interactions.",
                "Provide guidance on effective communication in an educational setting."
            ]
        };
    }

    /**
     * Validate API configuration
     */
    public function validateConfiguration(): bool
    {
        if (empty($this->apiKey)) {
            return false;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/models');

            return $response->successful();
        } catch (\Exception $e) {
            Log::error('OpenAI configuration validation failed', [
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Get available models
     */
    public function getAvailableModels(): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->get($this->baseUrl . '/models');

            if ($response->successful()) {
                return $response->json()['data'] ?? [];
            }
        } catch (\Exception $e) {
            Log::error('Failed to fetch OpenAI models', [
                'error' => $e->getMessage(),
            ]);
        }

        return [];
    }
}
