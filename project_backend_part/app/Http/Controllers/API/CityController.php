<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\City;
use Illuminate\Http\JsonResponse;

class CityController extends Controller
{
    /**
     * Display a listing of cities.
     */
    public function index(): JsonResponse
    {
        $cities = City::query()->orderBy('sort_order')->orderBy('name_en')->get();

        return response()->json($cities);
    }

    /**
     * Display the specified city.
     */
    public function show($id): JsonResponse
    {
        $city = City::findOrFail($id);
        return response()->json($city);
    }
}
