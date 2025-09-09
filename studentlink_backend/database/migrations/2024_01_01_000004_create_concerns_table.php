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
        Schema::create('concerns', function (Blueprint $table) {
            $table->id();
            $table->string('reference_number', 20)->unique();
            $table->string('subject');
            $table->text('description');
            $table->enum('type', ['academic', 'administrative', 'technical', 'health', 'safety', 'other']);
            $table->enum('priority', ['low', 'medium', 'high', 'urgent']);
            $table->enum('status', ['pending', 'in_progress', 'resolved', 'closed', 'cancelled']);
            $table->boolean('is_anonymous')->default(false);
            
            // Relationships
            $table->foreignId('student_id')->constrained('app_users')->onDelete('cascade');
            $table->foreignId('department_id')->constrained()->onDelete('cascade');
            $table->foreignId('facility_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('assigned_to')->nullable()->constrained('app_users')->onDelete('set null');
            
            // Metadata
            $table->json('attachments')->nullable(); // File attachments
            $table->json('metadata')->nullable(); // Additional data
            $table->timestamp('due_date')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamp('closed_at')->nullable();
            $table->timestamps();
            
            // Indexes
            $table->index(['status', 'priority']);
            $table->index(['student_id', 'status']);
            $table->index(['department_id', 'status']);
            $table->index(['assigned_to', 'status']);
            $table->index(['type', 'status']);
            $table->index('reference_number');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('concerns');
    }
};
