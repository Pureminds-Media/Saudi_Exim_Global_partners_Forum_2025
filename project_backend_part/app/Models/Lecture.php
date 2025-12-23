<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Facades\DB;

class Lecture extends Model
{
    use HasFactory;

    protected $fillable = [
        'instructor_ids',
        'moderator_id',
        'title',
        'description',
        'scheduled_at',
        'end_time',
        'location',
        'type',
        'title_ar',
        'description_ar',
    ];
    protected $casts = [
        'instructor_ids' => 'array',   // Cast JSON to array
        'scheduled_at' => 'datetime',  // Automatically casts to Carbon instance
        'end_time' => 'datetime',      // Automatically casts to Carbon instance
    ];
    protected $appends = ['instructors'];

    public function instructors()
    {
        return Instructor::whereIn('id', $this->instructor_ids ?? []);
    }

        // Add relationship for the moderator (if needed)
    public function moderator()
    {
        return $this->belongsTo(Instructor::class, 'moderator_id');
    }
        public function getInstructorsAttribute()
    {
        $ids = $this->instructor_ids ?? [];
        if (!is_array($ids) || empty($ids)) {
            return collect();
        }

        // Sanitize IDs and keep sequence from the column
        $ids = array_values(array_filter(array_map(function ($v) {
            return is_numeric($v) ? (int) $v : null;
        }, $ids), fn($v) => $v !== null));

        if (empty($ids)) {
            return collect();
        }

        // Prefer DB-level ordering (MySQL/MariaDB) using FIELD to preserve sequence
        try {
            return Instructor::whereIn('id', $ids)
                ->orderByRaw('FIELD(id, ' . implode(',', $ids) . ')')
                ->get();
        } catch (\Throwable $e) {
            // Fallback to collection-level ordering if FIELD is unsupported
            $instructors = Instructor::whereIn('id', $ids)->get();
            $order = array_flip($ids);
            return $instructors->sortBy(fn($i) => $order[$i->id] ?? PHP_INT_MAX)->values();
        }
    }
    
}
