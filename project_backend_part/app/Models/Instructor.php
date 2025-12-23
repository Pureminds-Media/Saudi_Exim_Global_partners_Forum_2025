<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Instructor extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'bio',
        'photo_path',
        'name_ar',
        'bio_ar',
        'title_en',
        'title_ar',
    ];

    public function lectures()
    {
        return Lecture::whereJsonContains('instructor_ids', $this->id);
    }
}
