<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ApiKeyMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        // Prefer configured key; fall back to env if config cache was built without API_KEY
        $key = config('app.api_key') ?: env('API_KEY');
        // Accept token from query (?token=...), body (api_key or API_Key), or header (X-API-Key)
        $provided = $request->query('token')
            ?? $request->input('api_key')
            ?? $request->input('API_Key')
            ?? $request->header('X-API-Key');
        if (!is_string($key) || !is_string($provided) || !hash_equals($key, (string) $provided)) {
            return response()->json(['message' => 'Invalid or missing API key'], 401);
        }
        return $next($request);
    }
}
