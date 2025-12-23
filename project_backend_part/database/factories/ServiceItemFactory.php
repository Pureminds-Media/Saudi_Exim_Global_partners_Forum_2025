<?php

namespace Database\Factories;

use App\Models\ServiceCategory;
use App\Models\ServiceItem;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ServiceItem>
 */
class ServiceItemFactory extends Factory
{
    protected $model = ServiceItem::class;

    public function definition(): array
    {
        return [
            'service_category_id' => ServiceCategory::factory(),
            'name_ar' => $this->faker->words(3, true),
            'name_en' => $this->faker->words(3, true),
            'short_des_ar' => $this->faker->optional()->sentence(),
            'short_des_en' => $this->faker->optional()->sentence(),
            'des_ar' => $this->faker->optional()->paragraph(),
            'des_en' => $this->faker->optional()->paragraph(),
            'thumbnail_path' => null,
            'photo_path' => null,
            'website' => $this->faker->optional()->url(),
            'location_link' => $this->faker->optional()->url(),
        ];
    }
}

