<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LectureControllerIgnoredLecture extends Model
{
    protected $table = 'lecture_controller_ignored_lectures';

    protected $fillable = [
        'lecture_id',
        'reason',
    ];
}

