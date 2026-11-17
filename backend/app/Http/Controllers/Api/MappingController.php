<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MappingBulan;
use App\Models\MappingToko;
use App\Models\Toko;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MappingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $salesId = (int) ($request->input('sales_id') ?? 2);
        $tahun = (int) ($request->input('tahun') ?? Carbon::now()->year);
        $wilayahId = $request->filled('wilayah_id') ? (int) $request->input('wilayah_id') : null;

        $query = MappingToko::with(['toko.wilayah', 'bulan'])
            ->where('id_sales', $salesId)
            ->where('tahun', $tahun);

        if ($wilayahId !== null) {
            $query->whereHas('toko', fn ($q) => $q->where('id_wilayah', $wilayahId));
        }

        $items = $query->orderBy('id_mapping')->get()->map(function (MappingToko $m) {
            return $this->formatMapping($m);
        });

        return ApiResponse::success($items, [
            'page' => 1,
            'per_page' => $items->count(),
            'total' => $items->count(),
        ]);
    }

    public function save(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'items' => ['required', 'array'],
            'items.*.id_mapping' => ['nullable', 'integer'],
            'items.*.id_sales' => ['nullable', 'integer'],
            'items.*.tahun' => ['nullable', 'integer'],
            'items.*.bulan' => ['required', 'array', 'size:12'],
            'items.*.bulan.*' => ['boolean'],
        ]);

        $adminId = $request->user()->id;

        DB::transaction(function () use ($validated, $adminId) {
            foreach ($validated['items'] as $row) {
                $mapping = null;
                if (! empty($row['id_mapping'])) {
                    $mapping = MappingToko::find($row['id_mapping']);
                }
                if (! $mapping && ! empty($row['toko']['no_jo'])) {
                    $mapping = MappingToko::firstOrCreate(
                        [
                            'id_sales' => $row['id_sales'] ?? 2,
                            'no_jo' => $row['toko']['no_jo'],
                            'tahun' => $row['tahun'] ?? Carbon::now()->year,
                        ],
                        ['id_admin' => $adminId]
                    );
                }
                if (! $mapping) {
                    continue;
                }

                foreach ($row['bulan'] as $idx => $direncanakan) {
                    $bulanNum = $idx + 1;
                    $exists = MappingBulan::where('id_mapping', $mapping->id_mapping)
                        ->where('bulan', $bulanNum)
                        ->exists();

                    if ($exists) {
                        MappingBulan::where('id_mapping', $mapping->id_mapping)
                            ->where('bulan', $bulanNum)
                            ->update(['direncanakan' => (bool) $direncanakan]);
                    } else {
                        MappingBulan::create([
                            'id_mapping' => $mapping->id_mapping,
                            'bulan' => $bulanNum,
                            'direncanakan' => (bool) $direncanakan,
                            'terealisasi' => false,
                        ]);
                    }
                }
            }
        });

        return ApiResponse::success(['message' => 'Mapping berhasil disimpan.']);
    }

    public function hariIni(Request $request): JsonResponse
    {
        $salesId = $request->user()->role === 'manajer_sales'
            ? (int) ($request->input('sales_id') ?? 2)
            : $request->user()->id;

        $now = Carbon::now();
        $bulanIni = $now->month;
        $tahunIni = $now->year;
        $wilayahId = $request->filled('wilayah_id') ? (int) $request->input('wilayah_id') : null;

        $mappings = MappingToko::with(['toko.wilayah', 'bulan'])
            ->where('id_sales', $salesId)
            ->where('tahun', $tahunIni)
            ->when($wilayahId !== null, function ($q) use ($wilayahId) {
                $q->whereHas('toko', fn ($sub) => $sub->where('id_wilayah', $wilayahId));
            })
            ->get();

        $daftarToko = [];
        $sudah = 0;

        foreach ($mappings as $m) {
            $cell = $m->bulan->firstWhere('bulan', $bulanIni);
            if (! $cell || ! $cell->direncanakan) {
                continue;
            }
            if ($cell->terealisasi) {
                $sudah++;
            }
            $t = $m->toko;
            if (! $t) {
                continue;
            }
            $daftarToko[] = [
                'no_jo' => $t->no_jo,
                'nama_toko' => $t->nama_toko,
                'alamat' => $t->alamat,
                'ket_toko' => $t->ket_toko ?? '',
                'id_wilayah' => $t->id_wilayah,
                'wilayah' => $t->wilayah ? [
                    'id_wilayah' => $t->wilayah->id_wilayah,
                    'nama_wilayah' => $t->wilayah->nama_wilayah,
                ] : null,
                'latitude' => (float) $t->latitude,
                'longitude' => (float) $t->longitude,
                'sudah_dikunjungi_bulan_ini' => (bool) $cell->terealisasi,
            ];
        }

        return ApiResponse::success([
            'toko' => $daftarToko,
            'sudah_dikunjungi' => $sudah,
            'total_target' => count($daftarToko),
        ]);
    }

    private function formatMapping(MappingToko $m): array
    {
        $bulanMap = $m->bulan->keyBy('bulan');
        $rencana = [];
        $real = [];
        for ($i = 1; $i <= 12; $i++) {
            $row = $bulanMap->get($i);
            $rencana[] = $row ? (bool) $row->direncanakan : false;
            $real[] = $row ? (bool) $row->terealisasi : false;
        }

        $t = $m->toko;
        $realSekarang = $real[Carbon::now()->month - 1] ?? false;

        return [
            'id_mapping' => $m->id_mapping,
            'id_sales' => $m->id_sales,
            'tahun' => $m->tahun,
            'toko' => $t ? [
                'no_jo' => $t->no_jo,
                'nama_toko' => $t->nama_toko,
                'alamat' => $t->alamat,
                'ket_toko' => $t->ket_toko ?? '',
                'id_wilayah' => $t->id_wilayah,
                'wilayah' => $t->wilayah ? [
                    'id_wilayah' => $t->wilayah->id_wilayah,
                    'nama_wilayah' => $t->wilayah->nama_wilayah,
                ] : null,
                'latitude' => (float) $t->latitude,
                'longitude' => (float) $t->longitude,
                'sudah_dikunjungi_bulan_ini' => $realSekarang,
            ] : null,
            'bulan' => $rencana,
            'terealisasi' => $real,
        ];
    }
}
