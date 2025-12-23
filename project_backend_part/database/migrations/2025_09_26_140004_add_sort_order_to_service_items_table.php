<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('service_items', function (Blueprint $table) {
            if (!Schema::hasColumn('service_items', 'sort_order')) {
                $table->integer('sort_order')->default(0)->after('location_link');
            }
        });
    }

    public function down(): void
    {
        Schema::table('service_items', function (Blueprint $table) {
            if (Schema::hasColumn('service_items', 'sort_order')) {
                $table->dropColumn('sort_order');
            }
        });
    }
};