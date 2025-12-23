<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('instructor_controller_ignored_lectures', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('lecture_id')->unique();
            $table->string('reason')->nullable();
            $table->timestamps();
        });

        try {
            DB::table('instructor_controller_ignored_lectures')->insertOrIgnore(collect([64, 56, 60, 62])->map(fn ($id) => [
                'lecture_id' => $id,
                'reason' => 'migrated from controller constant',
                'created_at' => now(),
                'updated_at' => now(),
            ])->toArray());
        } catch (\Throwable $e) {
            // ignore seeding errors
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('instructor_controller_ignored_lectures');
    }
};

