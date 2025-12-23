<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_category_id')->constrained()->cascadeOnDelete();
            $table->string('name_ar');
            $table->string('name_en');
            $table->string('short_des_ar')->nullable();
            $table->string('short_des_en')->nullable();
            $table->text('des_ar')->nullable();
            $table->text('des_en')->nullable();
            $table->string('thumbnail_path')->nullable();
            $table->string('photo_path')->nullable();
            $table->string('website')->nullable();
            $table->string('location_link')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_items');
    }
};
