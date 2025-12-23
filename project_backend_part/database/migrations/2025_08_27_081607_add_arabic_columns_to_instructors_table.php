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
            $table->string('name_ar')->nullable();   // Arabic name
            $table->text('bio_ar')->nullable();      // Arabic bio
            $table->foreignId('country_id')->nullable()->constrained()->onDelete('set null');
        });
    }

    public function down()
    {
        Schema::table('instructors', function (Blueprint $table) {
            $table->dropColumn(['name_ar', 'bio_ar']);
            $table->dropForeign(['country_id']);
        });
    }
};
