<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Instructor;
use App\Models\Lecture;

class InstructorController extends Controller
{
    /**
     * Display a listing of instructors with their lectures.
     * Excludes ignored lectures for mobile app consumption.
     * Requires API key authentication via middleware.
     */
    public function index(Request $request)
    {
        $expectedKey = config('app.api_key');
        $providedKey = $request->query('token');
        if (!is_string($expectedKey) || !is_string($providedKey) || !hash_equals($expectedKey, (string) $providedKey)) {
            return response()->json(['error' => 'Invalid'], 401);
        }

        $ignoredIds = \App\Models\InstructorControllerIgnoredLecture::pluck('lecture_id');

        $lectures = Lecture::select('title', 'title_ar', 'instructor_ids', 'scheduled_at', 'moderator_id')
            ->with('moderator')
            ->when($ignoredIds->isNotEmpty(), function ($q) use ($ignoredIds) {
                $q->whereNotIn('id', $ignoredIds);
            })
            ->orderBy('scheduled_at')
            ->get();

        return response()->json($lectures);
    }
}
