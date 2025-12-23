<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Lecture;
use App\Models\Instructor;

class LectureController extends Controller
{
    /**
     * Display a listing of Lectures.
     * Excludes ignored lectures for mobile app consumption.
     */
    public function index(Request $request)
    {
        $ignoredIds = \App\Models\LectureControllerIgnoredLecture::pluck('lecture_id');

        $query = Lecture::query()
                    ->when($ignoredIds->isNotEmpty(), function ($q) use ($ignoredIds) {
                        $q->whereNotIn('id', $ignoredIds);
                    })
                    ->with('moderator');

        $lectures = $query->get();
        $lectures->each(function ($lecture) {
            $lecture->instructors = Instructor::whereIn('id', $lecture->instructor_ids ?? [])->get();
        });

        return response()->json($lectures);
    }
}
