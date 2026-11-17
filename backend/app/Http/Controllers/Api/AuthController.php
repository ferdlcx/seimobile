<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengguna;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'username' => ['required', 'string'],
            'password' => ['required', 'string'],
            'role' => ['required', 'in:admin_tagihan,sales,manajer_sales'],
            'mode' => ['nullable', 'in:manajer,sales'],
        ]);

        $user = Pengguna::where('username', $validated['username'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return ApiResponse::error('Username atau password tidak sesuai.', 401);
        }

        if (! $user->aktif) {
            return ApiResponse::error('Akun ini sedang nonaktif. Hubungi Admin Tagihan.', 403);
        }

        if ($user->role !== $validated['role']) {
            return ApiResponse::error('Peran yang dipilih tidak sesuai dengan akun ini.', 403);
        }

        $mode = $user->role === 'manajer_sales'
            ? ($validated['mode'] ?? 'manajer')
            : $user->role;

        $token = $user->createToken('seui-mobile')->plainTextToken;

        return ApiResponse::success([
            'token' => $token,
            'user' => $this->formatUser($user),
            'mode' => $mode,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return ApiResponse::success(['message' => 'Berhasil keluar.']);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        $modeHeader = strtolower((string) $request->header('X-Mode'));
        $mode = $user->role === 'manajer_sales'
            ? ($modeHeader === 'sales' ? 'sales' : 'manajer')
            : $user->role;

        $data = $this->formatUser($user);
        $data['mode'] = $mode;

        return ApiResponse::success($data);
    }

    private function formatUser(Pengguna $user): array
    {
        return [
            'id' => $user->id,
            'nama' => $user->nama,
            'username' => $user->username,
            'role' => $user->role,
            'aktif' => (bool) $user->aktif,
            'tanda_tangan_path' => $user->tanda_tangan_path,
        ];
    }
}
