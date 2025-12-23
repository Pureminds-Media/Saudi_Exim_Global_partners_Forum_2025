<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Sponsor;
use Illuminate\Http\JsonResponse;

class SponsorController extends Controller
{
    /**
     * Display a listing of sponsors.
     * Sorted by type priority and name.
     */
    public function index(): JsonResponse
    {
        $sponsors = Sponsor::all()
            ->sortBy(function (Sponsor $sponsor) {
                $typeOrder = array_search($sponsor->type, Sponsor::TYPES, true);
                if ($typeOrder === false) {
                    $typeOrder = count(Sponsor::TYPES);
                }

                $name = (string) ($sponsor->name_en ?? $sponsor->name_ar ?? '');
                $normalizedName = function_exists('mb_strtolower') ? mb_strtolower($name) : strtolower($name);

                return sprintf('%02d-%s', $typeOrder, $normalizedName);
            })
            ->values();

        return response()->json($sponsors);
    }

    /**
     * Display the specified sponsor.
     */
    public function show(Sponsor $sponsor): JsonResponse
    {
        return response()->json($sponsor);
    }
}
