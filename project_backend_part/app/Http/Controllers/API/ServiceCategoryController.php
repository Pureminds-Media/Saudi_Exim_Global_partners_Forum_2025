<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\ServiceCategory;
use Illuminate\Support\Facades\Schema;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceCategoryController extends Controller
{
    /**
     * Display a listing of service categories.
     */
    public function index(Request $request): JsonResponse
    {
        $query = ServiceCategory::query();
        if (Schema::hasColumn('service_categories', 'sort_order')) {
            $query->orderBy('sort_order');
        }
        $query->orderBy('name_en');

        $perPage = (int) $request->query('per_page', 0);
        if ($perPage > 0) {
            return response()->json($query->paginate($perPage));
        }

        return response()->json($query->get());
    }

    /**
     * Display the specified service category with its items.
     */
    public function show($id): JsonResponse
    {
        $serviceCategory = ServiceCategory::findOrFail($id);
        $serviceCategory->load('serviceItems');

        return response()->json($serviceCategory);
    }
}
