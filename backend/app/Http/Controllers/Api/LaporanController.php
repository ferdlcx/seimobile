<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JurnalKunjungan;
use App\Models\Wilayah;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LaporanController extends Controller
{
    public function rekap(Request $request): JsonResponse
    {
        $periode = (string) ($request->input('periode') ?? Carbon::now()->format('Y-m'));
        $wilayahId = $request->filled('wilayah_id') ? (int) $request->input('wilayah_id') : null;

        try {
            $dt = Carbon::createFromFormat('Y-m', $periode);
        } catch (\Throwable) {
            $dt = Carbon::now();
        }

        $wilayahQuery = Wilayah::with('toko')->orderBy('id_wilayah');
        if ($wilayahId !== null) {
            $wilayahQuery->where('id_wilayah', $wilayahId);
        }

        $baris = [];
        $totalTarget = 0;
        $totalReal = 0;

        foreach ($wilayahQuery->get() as $w) {
            $tokoIds = $w->toko->pluck('no_jo');
            $target = $tokoIds->count();
            $real = JurnalKunjungan::whereIn('no_jo', $tokoIds)
                ->where('status', 'final')
                ->whereYear('tgl_kunjungan', $dt->year)
                ->whereMonth('tgl_kunjungan', $dt->month)
                ->distinct('no_jo')
                ->count('no_jo');

            $persen = $target > 0 ? (int) round(($real / $target) * 100) : 0;
            $totalTarget += $target;
            $totalReal += $real;

            $baris[] = [
                'wilayah' => $w->nama_wilayah,
                'target' => $target,
                'real' => $real,
                'persen' => $persen,
            ];
        }

        $totalPersen = $totalTarget > 0 ? (int) round(($totalReal / $totalTarget) * 100) : 0;

        return ApiResponse::success([
            'periode_label' => $dt->translatedFormat('F Y'),
            'baris' => $baris,
            'total_target' => $totalTarget,
            'total_real' => $totalReal,
            'total_persen' => $totalPersen,
        ]);
    }
}
