<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JurnalKunjungan;
use App\Models\KriteriaKondite;
use App\Models\Toko;
use App\Models\Wilayah;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MasterController extends Controller
{
    public function wilayah(): JsonResponse
    {
        $list = Wilayah::orderBy('id_wilayah')->get();

        return ApiResponse::success($list, [
            'page' => 1,
            'per_page' => $list->count(),
            'total' => $list->count(),
        ]);
    }

    public function tokoIndex(Request $request): JsonResponse
    {
        $query = Toko::with('wilayah');

        if ($request->filled('wilayah_id')) {
            $query->where('id_wilayah', (int) $request->input('wilayah_id'));
        }

        if ($request->filled('q')) {
            $q = $request->input('q');
            $query->where(function ($sub) use ($q) {
                $sub->where('nama_toko', 'like', "%{$q}%")
                    ->orWhere('no_jo', 'like', "%{$q}%");
            });
        }

        $now = Carbon::now();
        $list = $query->orderBy('no_jo')->get()->map(function (Toko $t) use ($now) {
            return $this->formatToko($t, $now);
        });

        return ApiResponse::success($list, [
            'page' => 1,
            'per_page' => $list->count(),
            'total' => $list->count(),
        ]);
    }

    public function tokoStore(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'no_jo' => ['required', 'string', 'max:30', 'unique:toko,no_jo'],
            'nama_toko' => ['required', 'string', 'max:255'],
            'id_wilayah' => ['required', 'integer', 'exists:wilayah,id_wilayah'],
            'alamat' => ['required', 'string'],
            'ket_toko' => ['nullable', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
        ]);

        $toko = Toko::create([
            'no_jo' => $validated['no_jo'],
            'nama_toko' => $validated['nama_toko'],
            'id_wilayah' => $validated['id_wilayah'],
            'alamat' => $validated['alamat'],
            'ket_toko' => $validated['ket_toko'] ?? '',
            'latitude' => $validated['latitude'] ?? -7.4250,
            'longitude' => $validated['longitude'] ?? 109.2350,
        ]);
        $toko->load('wilayah');

        return ApiResponse::success($this->formatToko($toko, Carbon::now()), null, 201);
    }

    public function kriteriaIndex(): JsonResponse
    {
        $list = KriteriaKondite::orderBy('urutan')->get();

        return ApiResponse::success($list, [
            'page' => 1,
            'per_page' => $list->count(),
            'total' => $list->count(),
        ]);
    }

    public function kriteriaUpdate(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'nama' => ['required', 'string', 'max:255'],
            'aktif' => ['nullable', 'boolean'],
        ]);

        $kriteria = KriteriaKondite::findOrFail($id);
        $kriteria->nama = $validated['nama'];
        if (array_key_exists('aktif', $validated)) {
            $kriteria->aktif = (bool) $validated['aktif'];
        }
        $kriteria->save();

        return ApiResponse::success($kriteria);
    }

    private function formatToko(Toko $toko, Carbon $now): array
    {
        $sudahBulanIni = JurnalKunjungan::where('no_jo', $toko->no_jo)
            ->where('status', 'final')
            ->whereYear('tgl_kunjungan', $now->year)
            ->whereMonth('tgl_kunjungan', $now->month)
            ->exists();

        $terakhir = JurnalKunjungan::where('no_jo', $toko->no_jo)
            ->where('status', 'final')
            ->orderByDesc('tgl_kunjungan')
            ->first();

        $hariSejak = $terakhir
            ? (int) Carbon::parse($terakhir->tgl_kunjungan)->diffInDays($now)
            : 0;

        return [
            'no_jo' => $toko->no_jo,
            'nama_toko' => $toko->nama_toko,
            'alamat' => $toko->alamat,
            'ket_toko' => $toko->ket_toko ?? '',
            'id_wilayah' => $toko->id_wilayah,
            'wilayah' => $toko->wilayah ? [
                'id_wilayah' => $toko->wilayah->id_wilayah,
                'nama_wilayah' => $toko->wilayah->nama_wilayah,
            ] : null,
            'latitude' => (float) $toko->latitude,
            'longitude' => (float) $toko->longitude,
            'sudah_dikunjungi_bulan_ini' => $sudahBulanIni,
            'hari_sejak_kunjungan_terakhir' => $hariSejak,
        ];
    }
}
