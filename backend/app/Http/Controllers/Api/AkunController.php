<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengguna;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AkunController extends Controller
{
    public function index(): JsonResponse
    {
        $users = Pengguna::orderBy('id')->get()->map(fn (Pengguna $u) => $this->formatUser($u));

        return ApiResponse::success($users, [
            'page' => 1,
            'per_page' => $users->count(),
            'total' => $users->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:100', 'unique:pengguna,username'],
            'password' => ['required', 'string', 'min:6'],
            'role' => ['required', 'in:admin_tagihan,sales,manajer_sales'],
            'aktif' => ['nullable', 'boolean'],
        ]);

        $user = Pengguna::create([
            'nama' => $validated['nama'],
            'username' => $validated['username'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'aktif' => $validated['aktif'] ?? true,
        ]);

        return ApiResponse::success($this->formatUser($user, true), null, 201);
    }

    public function setAktif(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'aktif' => ['required', 'boolean'],
        ]);

        $user = Pengguna::findOrFail($id);
        $user->aktif = $validated['aktif'];
        $user->save();

        return ApiResponse::success($this->formatUser($user));
    }

    private function formatUser(Pengguna $u, bool $isBaru = false): array
    {
        return [
            'id' => $u->id,
            'nama' => $u->nama,
            'username' => $u->username,
            'role' => $u->role,
            'aktif' => (bool) $u->aktif,
            'is_baru' => $isBaru,
            'tanda_tangan_path' => $u->tanda_tangan_path,
        ];
    }
}
