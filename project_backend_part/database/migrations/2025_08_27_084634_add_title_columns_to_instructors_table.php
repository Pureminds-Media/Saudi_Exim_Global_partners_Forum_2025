<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('instructors', function (Blueprint $table) {
            // Add columns for Arabic and English titles
            $table->string('title_en')->nullable(); // English title
            $table->string('title_ar')->nullable(); // Arabic title
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('instructors', function (Blueprint $table) {
            // Drop the columns if rolling back the migration
            $table->dropColumn('title_en');
            $table->dropColumn('title_ar');
        });
    }
};
