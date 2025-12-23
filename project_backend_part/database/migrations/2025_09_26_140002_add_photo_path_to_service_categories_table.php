<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('service_categories', function (Blueprint $table) {
            if (!Schema::hasColumn('service_categories', 'photo_path')) {
                $table->string('photo_path')->nullable()->after('des_en');
            }
            if (!Schema::hasColumn('service_categories', 'sort_order')) {
                $table->integer('sort_order')->default(0)->after('photo_path');
            }
        });
    }

    public function down(): void
    {
        Schema::table('service_categories', function (Blueprint $table) {
            if (Schema::hasColumn('service_categories', 'photo_path')) {
                $table->dropColumn('photo_path');
            }
            if (Schema::hasColumn('service_categories', 'sort_order')) {
                $table->dropColumn('sort_order');
            }
        });
    }
};