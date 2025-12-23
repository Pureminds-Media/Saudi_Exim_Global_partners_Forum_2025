<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        // Drop the foreign key constraint first
        Schema::table('lectures', function (Blueprint $table) {
            $table->dropForeign(['instructor_id']); // Drop foreign key constraint
        });

        // Now drop the column
        Schema::table('lectures', function (Blueprint $table) {
            $table->dropColumn('instructor_id'); // Drop the instructor_id column
        });

        // Add the new column
        Schema::table('lectures', function (Blueprint $table) {
            $table->json('instructor_ids')->nullable(); // Add a new JSON column
        });
    }

    public function down()
    {
        // Revert the changes if needed
        Schema::table('lectures', function (Blueprint $table) {
            $table->dropColumn('instructor_ids');
            $table->integer('instructor_id')->unsigned()->nullable();
        });

        // Re-add the foreign key constraint (if needed)
        Schema::table('lectures', function (Blueprint $table) {
            $table->foreign('instructor_id')->references('id')->on('instructors')->onDelete('set null');
        });
    }

};

