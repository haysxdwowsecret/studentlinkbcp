<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ai_chat_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('app_users')->onDelete('cascade');
            $table->string('session_id', 36)->unique(); // UUID
            $table->string('context')->nullable(); // concern, general, assistance
            $table->foreignId('related_concern_id')->nullable()->constrained('concerns')->onDelete('set null');
            $table->json('messages'); // Chat message history
            $table->json('metadata')->nullable(); // AI model used, tokens, etc.
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_activity_at');
            $table->timestamps();
            
            // Indexes
            $table->index(['user_id', 'is_active']);
            $table->index(['session_id', 'is_active']);
            $table->index('last_activity_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ai_chat_sessions');
    }
};
