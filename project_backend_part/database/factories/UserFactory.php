<?php

namespace Database\Factories;

use App\Services\EmailCanonicalizer;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    protected $model = \App\Models\User::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        $email = EmailCanonicalizer::canonicalize($this->faker->unique()->safeEmail);
        if ($email === null) {
            $email = $this->faker->unique()->userName() . '@example.com';
        }

        return [
            'name' => $this->faker->name,
            'email' => $email,
            'phone' => $this->faker->unique()->phoneNumber,
            'gender' => $this->faker->randomElement(['male', 'female']),
            'nationality' => $this->faker->country,
            'identity_number' => $this->faker->unique()->randomNumber(9), // Unique ID
            'position' => $this->faker->jobTitle,
            'organization' => $this->faker->company,
            'email_verified_at' => now(),  // Set to the current timestamp
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
