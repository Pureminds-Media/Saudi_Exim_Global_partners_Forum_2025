<?php

return [
    'per_ip' => env('RATE_LIMIT_PER_IP', 240),
    'per_route' => env('RATE_LIMIT_PER_ROUTE', 120),
    'decay_seconds' => env('RATE_LIMIT_DECAY_SECONDS', 60),
    'burst' => [
        'max_attempts' => env('RATE_LIMIT_BURST_ATTEMPTS', 30),
        'decay_seconds' => env('RATE_LIMIT_BURST_DECAY_SECONDS', 1),
    ],
    'exempt_paths' => [
        'up',
    ],
];
