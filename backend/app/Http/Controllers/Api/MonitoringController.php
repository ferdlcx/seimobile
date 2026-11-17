<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\JurnalKunjungan;
use App\Models\MappingToko;
use App\Models\PengajuanReschedule;
use App\Models\Pengguna;
use App\Models\Toko;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MonitoringController extends Controller
{
    public function harian(Request $request): JsonResponse
    {
        $wilayahId = $request->filled('wilayah_id') ? (int) $request->input('wilayah_id') : null;
        $batasHari = (int) config('seui.hari_belum_dikunjungi', 30);
        $now = Carbon::now();

        $tokoQuery = Toko::query();
        if ($wilayahId !== null) {
            $tokoQuery->where('id_wilayah', $wilayahId);
        }
        $tokoList = $tokoQuery->get();

        $kunjungan = 0;
        $peringatan = [];

        foreach ($tokoList as $t) {
            $sudahBulanIni = JurnalKunjungan::where('no_jo', $t->no_jo)
                ->where('status', 'final')
                ->whereYear('tgl_kunjungan', $now->year)
                ->whereMonth('tgl_kunjungan', $now->month)
                ->exists();

            if ($sudahBulanIni) {
                $kunjungan++;
                continue;
            }

            $terakhir = JurnalKunjungan::where('no_jo', $t->no_jo)
                ->where('status', 'final')
                ->orderByDesc('tgl_kunjungan')
                ->first();

            if ($terakhir) {
                $hari = (int) Carbon::parse($terakhir->tgl_kunjungan)->diffInDays($now);
                if ($hari > $batasHari) {
                    $peringatan[] = "{$t->nama_toko} belum dikunjungi {$hari} hari.";
                }
            }
        }

        $targetKunjungan = $tokoList->count();
        $order = JurnalKunjungan::where('status', 'final')
            ->where('status_order', 'ada_order')
            ->whereYear('tgl_kunjungan', $now->year)
            ->whereMonth('tgl_kunjungan', $now->month)
            ->when($wilayahId !== null, function ($q) use ($tokoList) {
                $q->whereIn('no_jo', $tokoList->pluck('no_jo'));
            })
            ->count();

        $rescheduleMenunggu = PengajuanReschedule::where('status', 'menunggu')->count();

        $kepatuhan = $targetKunjungan > 0
            ? (int) round(($kunjungan / $targetKunjungan) * 100)
            : 0;

        return ApiResponse::success([
            'kunjungan' => $kunjungan,
            'target_kunjungan' => $targetKunjungan,
            'order' => $order,
            'reschedule_menunggu' => $rescheduleMenunggu,
            'peringatan' => $peringatan,
            'kepatuhan_mapping' => $kepatuhan,
            'progres_per_sales' => $this->hitungProgresSales($now),
        ]);
    }

    public function salesProgress(): JsonResponse
    {
        return ApiResponse::success($this->hitungProgresSales(Carbon::now()));
    }

    private function hitungProgresSales(Carbon $now): array
    {
        $salesUsers = Pengguna::where('role', 'sales')->where('aktif', true)->orderBy('id')->get();
        $result = [];

        foreach ($salesUsers as $sales) {
            $mappings = MappingToko::with('bulan')
                ->where('id_sales', $sales->id)
                ->where('tahun', $now->year)
                ->get();

            $target = 0;
            $realisasi = 0;

            foreach ($mappings as $m) {
                $cell = $m->bulan->firstWhere('bulan', $now->month);
                if ($cell && $cell->direncanakan) {
                    $target++;
                    if ($cell->terealisasi) {
                        $realisasi++;
                    }
                }
            }

            $result[] = [
                'sales_id' => $sales->id,
                'sales_nama' => $sales->nama,
                'realisasi' => $realisasi,
                'target' => $target,
            ];
        }

        return $result;
    }
}
