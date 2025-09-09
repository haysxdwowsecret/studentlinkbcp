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
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('app_users')->onDelete('cascade');
            $table->string('type'); // concern_update, announcement, assignment, etc.
            $table->string('title');
            $table->text('message');
            $table->json('data')->nullable(); // Additional context data
            $table->string('related_type')->nullable(); // Model type (Concern, Announcement, etc.)
            $table->bigInteger('related_id')->nullable(); // Model ID
            $table->timestamp('read_at')->nullable();
            $table->enum('priority', ['low', 'medium', 'high', 'urgent'])->default('medium');
            $table->boolean('push_sent')->default(false);
            $table->boolean('email_sent')->default(false);
            $table->timestamps();
            
            // Indexes
            $table->index(['user_id', 'read_at']);
            $table->index(['type', 'created_at']);
            $table->index(['related_type', 'related_id']);
            $table->index('priority');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
