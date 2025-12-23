<?php

use App\Http\Controllers\API\InstructorController;
use App\Http\Controllers\API\LectureController;
use App\Http\Controllers\API\ServiceCategoryController;
use App\Http\Controllers\API\ServiceItemController;
use App\Http\Controllers\API\SponsorController;
use App\Http\Controllers\API\CityController;
use App\Http\Controllers\API\AgendaConfigController;
use App\Http\Middleware\ApiKeyMiddleware;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Mobile API Routes
|--------------------------------------------------------------------------
|
| These routes are specifically for the SaudiExim mobile application.
|
*/

// Agenda Configuration
Route::get('/agenda-config/{slug}/keys', [AgendaConfigController::class, 'index']);
Route::get('/agenda-config/keys', fn() => app(AgendaConfigController::class)->index('default'));
Route::get('/agenda-config/{slug}/keys/{key}', [AgendaConfigController::class, 'showKey'])
    ->where('key', '.*');

// Lectures - Public endpoint for agenda sessions
Route::get('/lectures', [LectureController::class, 'index']);

// Instructors - Requires API key authentication
Route::get('/instructors', [InstructorController::class, 'index'])->middleware(ApiKeyMiddleware::class);

// Sponsors - Public endpoint
Route::get('/sponsors', [SponsorController::class, 'index']);
Route::get('/sponsors/{sponsor}', [SponsorController::class, 'show']);

// Services - Full catalog snapshot and per-category endpoints
Route::get('/services-data/all', [ServiceItemController::class, 'getAllServicesData']);
Route::get('/services/{id}', [ServiceItemController::class, 'getServiceById']);

// Service categories and items (read-only for mobile)
Route::apiResource('cities', CityController::class)->only(['index', 'show']);
Route::apiResource('service-categories', ServiceCategoryController::class)->only(['index', 'show']);
Route::apiResource('service-items', ServiceItemController::class)->only(['index', 'show']);
