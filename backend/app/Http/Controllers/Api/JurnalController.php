<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JurnalKunjungan;
use App\Models\MappingBulan;
use App\Models\MappingToko;
use App\Models\Toko;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class JurnalController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = JurnalKunjungan::query()->orderByDesc('tgl_kunjungan')->orderByDesc('id_kunjungan');

        if ($request->filled('sales_id')) {
            $query->where('id_sales', (int) $request->input('sales_id'));
        } elseif ($request->user()->role === 'sales') {
            $query->where('id_sales', $request->user()->id);
        }

        if ($request->filled('tanggal')) {
            $tgl = Carbon::parse($request->input('tanggal'))->toDateString();
            $query->whereDate('tgl_kunjungan', $tgl);
        }

        $items = $query->get();

        return ApiResponse::success($items, [
            'page' => 1,
            'per_page' => $items->count(),
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        return $this->simpanJurnal($request, 'final');
    }

    public function saveDraft(Request $request): JsonResponse
    {
        return $this->simpanJurnal($request, 'draft');
    }

    public function finalisasi(Request $request, int $id): JsonResponse
    {
        $jurnal = JurnalKunjungan::findOrFail($id);

        if ($jurnal->id_sales !== $request->user()->id && $request->user()->role !== 'manajer_sales') {
            return ApiResponse::error('Anda tidak diizinkan memfinalisasi jurnal ini.', 403);
        }

        if ($jurnal->status_order === 'ada_order' && empty($jurnal->foto_nota_po_path)) {
            return ApiResponse::error('Foto nota PO wajib diunggah untuk kunjungan Ada Order.', 422);
        }

        $maxRadius = (float) config('seui.radius_checkin_m', 50.0);
        if ((float) $jurnal->jarak_checkin_m > $maxRadius) {
            return ApiResponse::error("Lokasi Anda di luar radius check-in ({$maxRadius} m).", 422);
        }

        $jurnal->status = 'final';
        $jurnal->save();
        $this->tandaiMappingTerealisasi($jurnal);

        return ApiResponse::success($jurnal);
    }

    private function simpanJurnal(Request $request, string $status): JsonResponse
    {
        $maxFotoKb = (int) config('seui.max_foto_kb', 3072);

        $validated = $request->validate([
            'no_jo' => ['required', 'string', 'exists:toko,no_jo'],
            'status_order' => ['required', 'in:ada_order,tidak_ada_order,toko_tutup'],
            'ket_aktivitas' => ['nullable', 'string'],
            'lat' => ['required', 'numeric'],
            'lng' => ['required', 'numeric'],
            'foto_display' => ['nullable'],
            'foto_nota_po' => ['nullable'],
        ]);

        if ($request->hasFile('foto_display')) {
            $request->validate(['foto_display' => ['image', 'mimes:jpg,jpeg,png', "max:{$maxFotoKb}"]]);
        }
        if ($request->hasFile('foto_nota_po')) {
            $request->validate(['foto_nota_po' => ['image', 'mimes:jpg,jpeg,png', "max:{$maxFotoKb}"]]);
        }

        $toko = Toko::findOrFail($validated['no_jo']);
        $jarakM = $this->hitungHaversineMeter(
            (float) $validated['lat'],
            (float) $validated['lng'],
            (float) $toko->latitude,
            (float) $toko->longitude
        );

        $maxRadius = (float) config('seui.radius_checkin_m', 50.0);
        if ($status === 'final' && $jarakM > $maxRadius) {
            return ApiResponse::error(
                "Jarak check-in Anda ({$jarakM} m) melebihi batas maksimal {$maxRadius} m.",
                422
            );
        }

        $fotoDisplayPath = $request->hasFile('foto_display')
            ? $request->file('foto_display')->store('jurnal/display', 'public')
            : ($request->input('foto_display') ?: null);

        $fotoNotaPath = $request->hasFile('foto_nota_po')
            ? $request->file('foto_nota_po')->store('jurnal/nota', 'public')
            : ($request->input('foto_nota_po') ?: null);

        if ($status === 'final' && $validated['status_order'] === 'ada_order' && empty($fotoNotaPath)) {
            return ApiResponse::error('Foto nota PO wajib dilampirkan untuk status Ada Order.', 422);
        }

        $salesId = $request->user()->role === 'manajer_sales' ? 2 : $request->user()->id;
        $now = Carbon::now();

        $mapping = MappingToko::where('id_sales', $salesId)
            ->where('no_jo', $toko->no_jo)
            ->where('tahun', $now->year)
            ->first();

        $jurnal = JurnalKunjungan::create([
            'id_mapping' => $mapping?->id_mapping,
            'id_sales' => $salesId,
            'no_jo' => $toko->no_jo,
            'tgl_kunjungan' => $now->toDateString(),
            'status_order' => $validated['status_order'],
            'ket_aktivitas' => $validated['ket_aktivitas'] ?? '',
            'foto_display_path' => $fotoDisplayPath,
            'foto_nota_po_path' => $fotoNotaPath,
            'lat' => (float) $validated['lat'],
            'lng' => (float) $validated['lng'],
            'jarak_checkin_m' => round($jarakM, 2),
            'status' => $status,
        ]);

        if ($status === 'final') {
            $this->tandaiMappingTerealisasi($jurnal);
        }

        return ApiResponse::success($jurnal, null, 201);
    }

    private function tandaiMappingTerealisasi(JurnalKunjungan $jurnal): void
    {
        if (! $jurnal->id_mapping) {
            return;
        }
        $bulan = Carbon::parse($jurnal->tgl_kunjungan)->month;
        MappingBulan::where('id_mapping', $jurnal->id_mapping)
            ->where('bulan', $bulan)
            ->update(['terealisasi' => true]);
    }

    private function hitungHaversineMeter(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371000.0;
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2)
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }
}
