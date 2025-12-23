<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InstructorControllerIgnoredLecture extends Model
{
    protected $table = 'instructor_controller_ignored_lectures';

    protected $fillable = [
        'lecture_id',
        'reason',
    ];
}

