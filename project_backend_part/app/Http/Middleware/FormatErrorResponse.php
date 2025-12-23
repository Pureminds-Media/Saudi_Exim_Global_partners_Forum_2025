<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;

class FormatErrorResponse
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Proceed with the request and get the response
        Log::info('FormatErrorResponse middleware triggered');
        $response = $next($request);

        // Check if the response is of type JSON and has an "error" key
        if ($response instanceof Response && $response->getStatusCode() >= 400) {
            $data = json_decode($response->getContent(), true);

            // Check if the "error" key exists and is an array
            if (isset($data['error']) && is_array($data['error'])) {
                // Convert the error data into a simple array of messages
                $messages = $this->convertErrorToMessages($data['error']);
                
                // Return the modified response with the new "error" structure
                return response()->json(['error' => $messages], $response->getStatusCode());
            }
        }

        return $response;
    }

    /**
     * Convert the error array into a simple array of messages.
     *
     * @param  array  $error
     * @return array
     */
    protected function convertErrorToMessages(array $error)
    {
        // Flatten the error messages into a single array
        $messages = [];
        foreach ($error as $fieldErrors) {
            // Merge each error message into the messages array
            $messages = array_merge($messages, (array) $fieldErrors);
        }

        return $messages;
    }
}
