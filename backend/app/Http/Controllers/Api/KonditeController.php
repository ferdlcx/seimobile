<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DetailPenilaian;
use App\Models\KriteriaKondite;
use App\Models\Pengguna;
use App\Models\PenilaianKondite;
use App\Support\ApiResponse;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KonditeController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $salesId = (int) ($request->input('sales_id') ?? 2);
        $periode = (string) ($request->input('periode') ?? Carbon::now()->format('Y-m'));

        return ApiResponse::success($this->ambilAtauDefault($salesId, $periode));
    }

    public function save(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'sales_id' => ['required', 'integer', 'exists:pengguna,id'],
            'periode' => ['required', 'string', 'max:7'],
            'detail' => ['required', 'array', 'min:1'],
            'detail.*.id_kriteria' => ['required', 'integer', 'exists:kriteria_kondite,id_kriteria'],
            'detail.*.nilai' => ['required', 'in:B,C,K,SK'],
        ]);

        $bobot = config('seui.bobot_nilai', ['B' => 100, 'C' => 75, 'K' => 50, 'SK' => 25]);
        $total = 0;
        $count = count($validated['detail']);
        foreach ($validated['detail'] as $row) {
            $total += (int) ($bobot[$row['nilai']] ?? 0);
        }

        $nilaiAkhir = $count > 0 ? round($total / $count, 1) : 0.0;
        $label = $this->tentukanLabel($nilaiAkhir);

        $manajerId = $request->user()->id;

        DB::transaction(function () use ($validated, $manajerId, $nilaiAkhir, $label) {
            $penilaian = PenilaianKondite::updateOrCreate(
                [
                    'id_sales' => $validated['sales_id'],
                    'periode_bulan' => $validated['periode'],
                ],
                [
                    'id_manajer' => $manajerId,
                    'tgl_penilaian' => Carbon::now()->toDateString(),
                    'nilai_akhir' => $nilaiAkhir,
                    'label' => $label,
                ]
            );

            DetailPenilaian::where('id_kondite', $penilaian->id_kondite)->delete();

            foreach ($validated['detail'] as $row) {
                DetailPenilaian::create([
                    'id_kondite' => $penilaian->id_kondite,
                    'id_kriteria' => $row['id_kriteria'],
                    'nilai' => $row['nilai'],
                ]);
            }
        });

        return ApiResponse::success(
            $this->ambilAtauDefault((int) $validated['sales_id'], (string) $validated['periode'])
        );
    }

    public function saya(Request $request): JsonResponse
    {
        $salesId = $request->user()->role === 'manajer_sales' ? 2 : $request->user()->id;
        $periode = (string) ($request->input('periode') ?? Carbon::now()->format('Y-m'));

        return ApiResponse::success($this->ambilAtauDefault($salesId, $periode));
    }

    private function ambilAtauDefault(int $salesId, string $periode): array
    {
        $sales = Pengguna::find($salesId);
        $penilaian = PenilaianKondite::with('detail')
            ->where('id_sales', $salesId)
            ->where('periode_bulan', $periode)
            ->first();

        if ($penilaian) {
            $detailMap = [];
            foreach ($penilaian->detail as $d) {
                $detailMap[(string) $d->id_kriteria] = $d->nilai;
            }

            return [
                'id_sales' => $salesId,
                'sales_nama' => $sales?->nama ?? 'Budi Santoso',
                'periode_bulan' => $periode,
                'detail' => $detailMap,
                'nilai_akhir' => (float) $penilaian->nilai_akhir,
                'label' => $penilaian->label,
            ];
        }

        // Default 18 kriteria bila belum dinilai bulan berjalan
        $kriteriaList = KriteriaKondite::orderBy('urutan')->get();
        $bobot = config('seui.bobot_nilai', ['B' => 100, 'C' => 75, 'K' => 50, 'SK' => 25]);
        $detailMap = [];
        $total = 0;
        foreach ($kriteriaList as $k) {
            $huruf = ($k->urutan % 3 === 0) ? 'C' : 'B';
            $detailMap[(string) $k->id_kriteria] = $huruf;
            $total += (int) ($bobot[$huruf] ?? 100);
        }
        $nilaiAkhir = $kriteriaList->count() > 0 ? round($total / $kriteriaList->count(), 1) : 0.0;

        return [
            'id_sales' => $salesId,
            'sales_nama' => $sales?->nama ?? 'Budi Santoso',
            'periode_bulan' => $periode,
            'detail' => $detailMap,
            'nilai_akhir' => $nilaiAkhir,
            'label' => $this->tentukanLabel($nilaiAkhir),
        ];
    }

    private function tentukanLabel(float $nilaiAkhir): string
    {
        $thresholds = config('seui.label_nilai', [
            85 => 'BAIK',
            70 => 'CUKUP',
            50 => 'KURANG',
            0 => 'SANGAT KURANG',
        ]);
        krsort($thresholds);

        foreach ($thresholds as $min => $label) {
            if ($nilaiAkhir >= (float) $min) {
                return $label;
            }
        }

        return 'SANGAT KURANG';
    }
}
