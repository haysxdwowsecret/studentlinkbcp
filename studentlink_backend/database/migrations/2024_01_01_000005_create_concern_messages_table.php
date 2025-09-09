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
        Schema::create('concern_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('concern_id')->constrained()->onDelete('cascade');
            $table->foreignId('author_id')->constrained('app_users')->onDelete('cascade');
            $table->text('message');
            $table->enum('type', ['message', 'status_change', 'assignment', 'system']);
            $table->json('attachments')->nullable();
            $table->json('metadata')->nullable(); // Status changes, assignments, etc.
            $table->boolean('is_internal')->default(false); // Internal staff communication
            $table->boolean('is_ai_generated')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
            
            // Indexes
            $table->index(['concern_id', 'type']);
            $table->index(['author_id', 'created_at']);
            $table->index(['is_internal', 'type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('concern_messages');
    }
};
