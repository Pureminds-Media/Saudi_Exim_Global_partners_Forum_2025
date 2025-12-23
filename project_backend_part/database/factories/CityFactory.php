<?php

namespace Database\Factories;

use App\Models\City;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<City>
 */
class CityFactory extends Factory
{
    protected $model = City::class;

    public function definition(): array
    {
        return [
            'name_ar' => $this->faker->unique()->city(),
            'name_en' => $this->faker->unique()->city(),
            'des_ar' => $this->faker->optional()->sentence(),
            'des_en' => $this->faker->optional()->sentence(),
            'photo_path' => null,
        ];
    }
}

