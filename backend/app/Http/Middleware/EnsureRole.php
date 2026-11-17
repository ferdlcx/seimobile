<?php

namespace App\Http\Middleware;

use App\Support\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    /**
     * Memeriksa hak akses berdasarkan peran pengguna dan header X-Mode (untuk Manajer Sales).
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();
        if (! $user) {
            return ApiResponse::error('Unauthenticated. Silakan login terlebih dahulu.', 401);
        }

        if (! $user->aktif) {
            return ApiResponse::error('Akun ini sedang nonaktif. Hubungi Admin Tagihan.', 403);
        }

        if (in_array($user->role, $roles, true)) {
            return $next($request);
        }

        // Aturan khusus: Manajer Sales dapat memakai endpoint Sales dengan header X-Mode: sales
        if (
            $user->role === 'manajer_sales'
            && in_array('sales', $roles, true)
            && strtolower((string) $request->header('X-Mode')) === 'sales'
        ) {
            return $next($request);
        }

        return ApiResponse::error('Akses ditolak. Peran Anda tidak diizinkan mengakses resource ini.', 403);
    }
}
