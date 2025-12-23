<?php
// database/migrations/2025_01_01_000100_create_agenda_configs_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('agenda_configs', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->default('default')->unique();
            $table->json('data');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('agenda_configs');
    }
};
