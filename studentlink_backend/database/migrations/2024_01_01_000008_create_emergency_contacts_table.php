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
        Schema::create('emergency_contacts', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('type'); // medical, security, fire, police, guidance
            $table->string('phone');
            $table->string('email')->nullable();
            $table->string('location')->nullable();
            $table->text('description')->nullable();
            $table->json('operating_hours')->nullable();
            $table->enum('status', ['available', 'busy', 'unavailable'])->default('available');
            $table->boolean('is_active')->default(true);
            $table->integer('priority')->default(0); // Display order
            $table->timestamps();
            
            // Indexes
            $table->index(['type', 'is_active']);
            $table->index('priority');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('emergency_contacts');
    }
};
