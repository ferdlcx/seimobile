<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PengajuanReschedule;
use App\Models\Toko;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RescheduleController extends Controller
{
    private function ensureFeatureEnabled(): ?JsonResponse
    {
        if (! config('seui.enable_reschedule', true)) {
            return ApiResponse::error('Fitur pengajuan reschedule sedang dinonaktifkan.', 404);
        }

        return null;
    }

    public function index(Request $request): JsonResponse
    {
        if ($blocked = $this->ensureFeatureEnabled()) {
            return $blocked;
        }

        $query = PengajuanReschedule::with(['toko', 'sales'])->orderByDesc('id');
        if ($request->user()->role === 'sales') {
            $query->where('id_sales', $request->user()->id);
        }

        $items = $query->get()->map(fn (PengajuanReschedule $r) => $this->formatItem($r));

        return ApiResponse::success($items, [
            'page' => 1,
            'per_page' => $items->count(),
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        if ($blocked = $this->ensureFeatureEnabled()) {
            return $blocked;
        }

        $validated = $request->validate([
            'no_jo' => ['required', 'string', 'exists:toko,no_jo'],
            'jadwal_baru' => ['required', 'date'],
            'alasan' => ['required', 'string', 'min:5'],
        ]);

        $salesId = $request->user()->role === 'manajer_sales' ? 2 : $request->user()->id;

        $item = PengajuanReschedule::create([
            'id_sales' => $salesId,
            'no_jo' => $validated['no_jo'],
            'jadwal_lama' => Carbon::now()->toDateString(),
            'jadwal_baru' => Carbon::parse($validated['jadwal_baru'])->toDateString(),
            'alasan' => $validated['alasan'],
            'status' => 'menunggu',
        ]);
        $item->load(['toko', 'sales']);

        return ApiResponse::success($this->formatItem($item), null, 201);
    }

    public function setujui(Request $request, int $id): JsonResponse
    {
        return $this->prosesKeputusan($request, $id, 'disetujui');
    }

    public function tolak(Request $request, int $id): JsonResponse
    {
        return $this->prosesKeputusan($request, $id, 'ditolak');
    }

    private function prosesKeputusan(Request $request, int $id, string $status): JsonResponse
    {
        if ($blocked = $this->ensureFeatureEnabled()) {
            return $blocked;
        }

        $item = PengajuanReschedule::with(['toko', 'sales'])->findOrFail($id);
        if ($item->status !== 'menunggu') {
            return ApiResponse::error('Pengajuan reschedule ini sudah diproses sebelumnya.', 422);
        }

        $item->status = $status;
        $item->id_manajer = $request->user()->id;
        $item->tgl_proses = Carbon::now();
        $item->save();

        return ApiResponse::success($this->formatItem($item));
    }

    private function formatItem(PengajuanReschedule $r): array
    {
        return [
            'id' => $r->id,
            'no_jo' => $r->no_jo,
            'nama_toko' => $r->toko?->nama_toko ?? $r->no_jo,
            'jadwal_lama' => Carbon::parse($r->jadwal_lama)->toIso8601String(),
            'jadwal_baru' => Carbon::parse($r->jadwal_baru)->toIso8601String(),
            'alasan' => $r->alasan,
            'status' => $r->status,
            'sales_nama' => $r->sales?->nama ?? 'Budi Santoso',
            'id_sales' => $r->id_sales,
        ];
    }
}
