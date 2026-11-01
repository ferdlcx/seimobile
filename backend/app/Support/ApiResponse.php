<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;

class ApiResponse
{
    public static function success(mixed $data = null, ?array $meta = null, int $code = 200): JsonResponse
    {
        $response = ['data' => $data];
        if ($meta !== null) {
            $response['meta'] = $meta;
        }

        return response()->json($response, $code);
    }

    public static function error(string $message, int $code = 400, ?array $errors = null): JsonResponse
    {
        $response = ['message' => $message];
        if ($errors !== null && !empty($errors)) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $code);
    }
}
