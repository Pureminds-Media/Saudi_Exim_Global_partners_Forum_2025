<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\ServiceItem;
use App\Models\ServiceCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceItemController extends Controller
{
    /**
     * Display a listing of service items.
     */
    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'city_id' => ['sometimes', 'integer', 'exists:cities,id'],
            'service_category_id' => ['sometimes', 'integer', 'exists:service_categories,id'],
        ]);

        $items = ServiceItem::query()
            ->with(['cities', 'serviceCategory'])
            ->when(isset($filters['city_id']), function ($query) use ($filters) {
                $query->whereHas('cities', fn ($cityQuery) => $cityQuery->where('cities.id', $filters['city_id']));
            })
            ->when(isset($filters['service_category_id']), fn ($query) => $query->where('service_category_id', $filters['service_category_id']))
            ->orderBy('sort_order')
            ->orderBy('name_en')
            ->get();

        return response()->json($items);
    }

    /**
     * Display the specified service item.
     */
    public function show($id): JsonResponse
    {
        $serviceItem = ServiceItem::findOrFail($id);
        return response()->json($serviceItem);
    }

    /**
     * Get services by category ID with optional city filter.
     * Used by mobile app: GET /api/services/{categoryId}?city_id={cityId}
     */
    public function getServiceById(Request $request, $id): JsonResponse
    {
        $filters = $request->validate([
            'city_id' => ['sometimes', 'integer', 'exists:cities,id'],
        ]);

        $serviceCategory = ServiceCategory::findOrFail($id);

        $query = ServiceItem::query()
            ->with(['cities', 'serviceCategory'])
            ->where('service_category_id', $serviceCategory->id);

        if (isset($filters['city_id'])) {
            $query->whereHas('cities', fn ($cityQuery) => $cityQuery->where('cities.id', $filters['city_id']));
        }

        $serviceItems = $query->orderBy('sort_order')->orderBy('name_en')->get();

        return response()->json([
            'service_category' => $serviceCategory,
            'service_items' => $serviceItems,
        ]);
    }

    /**
     * Get all services data for mobile app catalog.
     * Returns cities, categories, and first category items.
     */
    public function getAllServicesData(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'city_id' => ['sometimes', 'integer', 'exists:cities,id'],
        ]);

        $cities = \App\Models\City::orderBy('sort_order')->orderBy('name_en')->get();
        $serviceCategories = \App\Models\ServiceCategory::orderBy('sort_order')->orderBy('name_en')->get();

        $firstServiceCategory = $serviceCategories->first();
        $firstCategoryItems = collect();

        if ($firstServiceCategory) {
            $query = ServiceItem::query()
                ->with(['cities', 'serviceCategory'])
                ->where('service_category_id', $firstServiceCategory->id);

            if (isset($filters['city_id'])) {
                $query->whereHas('cities', fn ($cityQuery) => $cityQuery->where('cities.id', $filters['city_id']));
            }

            $firstCategoryItems = $query->orderBy('sort_order')->orderBy('name_en')->get();
        }

        return response()->json([
            'cities' => $cities,
            'service_categories' => $serviceCategories,
            'first_category' => $firstServiceCategory,
            'first_category_items' => $firstCategoryItems,
        ]);
    }
}
