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
        Schema::create('announcements', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('content');
            $table->text('excerpt')->nullable();
            $table->enum('type', ['general', 'academic', 'administrative', 'event', 'emergency']);
            $table->enum('priority', ['low', 'medium', 'high', 'urgent']);
            $table->enum('status', ['draft', 'published', 'archived']);
            
            // Author and targeting
            $table->foreignId('author_id')->constrained('app_users')->onDelete('cascade');
            $table->json('target_departments')->nullable(); // Array of department IDs
            $table->json('target_roles')->nullable(); // Array of user roles
            $table->json('target_courses')->nullable(); // Array of course codes
            
            // Scheduling
            $table->timestamp('published_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            
            // Media and attachments
            $table->string('featured_image')->nullable();
            $table->json('attachments')->nullable();
            
            // Engagement tracking
            $table->integer('view_count')->default(0);
            $table->integer('bookmark_count')->default(0);
            
            $table->timestamps();
            
            // Indexes
            $table->index(['status', 'published_at']);
            $table->index(['type', 'priority']);
            $table->index(['author_id', 'status']);
            $table->index('published_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('announcements');
    }
};
