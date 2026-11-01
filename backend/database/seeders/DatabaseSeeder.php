<?php

namespace Database\Seeders;

use App\Models\KriteriaKondite;
use App\Models\MappingBulan;
use App\Models\MappingToko;
use App\Models\Pengguna;
use App\Models\Toko;
use App\Models\Wilayah;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Akun Pengguna
        $andi = Pengguna::create([
            'nama' => 'Andi Pratama',
            'username' => 'andi.tagihan',
            'password' => Hash::make('password123'),
            'role' => 'admin_tagihan',
            'aktif' => true,
        ]);

        $budi = Pengguna::create([
            'nama' => 'Budi Santoso',
            'username' => 'budi.santoso',
            'password' => Hash::make('password123'),
            'role' => 'sales',
            'aktif' => true,
        ]);

        $maya = Pengguna::create([
            'nama' => 'Maya Kusuma',
            'username' => 'maya.kusuma',
            'password' => Hash::make('password123'),
            'role' => 'manajer_sales',
            'aktif' => true,
        ]);

        $dewi = Pengguna::create([
            'nama' => 'Dewi Lestari',
            'username' => 'dewi.lestari',
            'password' => Hash::make('password123'),
            'role' => 'sales',
            'aktif' => false,
        ]);

        // 2. Wilayah
        $timur = Wilayah::create(['nama_wilayah' => 'Purwokerto Timur']);
        $barat = Wilayah::create(['nama_wilayah' => 'Purwokerto Barat']);
        $selatan = Wilayah::create(['nama_wilayah' => 'Purwokerto Selatan']);
        $sokaraja = Wilayah::create(['nama_wilayah' => 'Sokaraja']);

        // 3. Toko
        $tokoData = [
            [
                'no_jo' => 'JO-0412',
                'id_wilayah' => $timur->id_wilayah,
                'nama_toko' => 'Toko Makmur Jaya',
                'alamat' => 'Jl. Jenderal Sudirman No. 45, Purwokerto Timur',
                'ket_toko' => 'Pelanggan rutin suku cadang motor',
                'latitude' => -7.4243,
                'longitude' => 109.2391,
                'sudah_dikunjungi_okt' => true,
            ],
            [
                'no_jo' => 'JO-0388',
                'id_wilayah' => $timur->id_wilayah,
                'nama_toko' => 'Toko Sumber Rejeki',
                'alamat' => 'Jl. Gatot Subroto No. 12, Purwokerto Timur',
                'ket_toko' => 'Fokus oli dan kampas rem',
                'latitude' => -7.4215,
                'longitude' => 109.2410,
                'sudah_dikunjungi_okt' => true,
            ],
            [
                'no_jo' => 'JO-0501',
                'id_wilayah' => $sokaraja->id_wilayah,
                'nama_toko' => 'Toko Bintang Terang',
                'alamat' => 'Jl. Contoh No. 18, Sokaraja',
                'ket_toko' => 'Toko besar area Sokaraja',
                'latitude' => -7.4562,
                'longitude' => 109.2865,
                'sudah_dikunjungi_okt' => false,
            ],
            [
                'no_jo' => 'JO-0375',
                'id_wilayah' => $barat->id_wilayah,
                'nama_toko' => 'Toko Berkah Abadi',
                'alamat' => 'Jl. Kober No. 88, Purwokerto Barat',
                'ket_toko' => 'Rutin order awal/akhir bulan',
                'latitude' => -7.4180,
                'longitude' => 109.2150,
                'sudah_dikunjungi_okt' => false,
            ],
            [
                'no_jo' => 'JO-0420',
                'id_wilayah' => $barat->id_wilayah,
                'nama_toko' => 'Toko Sentosa Abadi',
                'alamat' => 'Jl. KS Tubun No. 21, Purwokerto Barat',
                'ket_toko' => 'Sparepart umum',
                'latitude' => -7.4201,
                'longitude' => 109.2122,
                'sudah_dikunjungi_okt' => true,
            ],
            [
                'no_jo' => 'JO-0433',
                'id_wilayah' => $selatan->id_wilayah,
                'nama_toko' => 'Toko Harapan Jaya',
                'alamat' => 'Jl. DI Panjaitan No. 60, Purwokerto Selatan',
                'ket_toko' => 'Langganan ban dan rantai',
                'latitude' => -7.4410,
                'longitude' => 109.2380,
                'sudah_dikunjungi_okt' => true,
            ],
        ];

        foreach ($tokoData as $t) {
            $sudahOkt = $t['sudah_dikunjungi_okt'];
            unset($t['sudah_dikunjungi_okt']);
            $toko = Toko::create($t);

            // 4. Mapping 2026 contoh untuk Budi
            $mapping = MappingToko::create([
                'id_admin' => $andi->id,
                'id_sales' => $budi->id,
                'no_jo' => $toko->no_jo,
                'tahun' => 2026,
            ]);

            // Bulan 1–12
            for ($b = 1; $b <= 12; $b++) {
                $terealisasi = false;
                if ($b < 10) {
                    $terealisasi = true; // Jan-Sep terealisasi
                } elseif ($b === 10) {
                    $terealisasi = $sudahOkt; // Okt: 4 dari 6 sudah, 2 belum
                }
                MappingBulan::create([
                    'id_mapping' => $mapping->id_mapping,
                    'bulan' => $b,
                    'direncanakan' => true,
                    'terealisasi' => $terealisasi,
                ]);
            }
        }

        // 5. 18 Kriteria Kondite
        $kriteriaNama = [
            1 => 'Kehadiran dan jam kunjungan',
            2 => 'Kesesuaian prosedur',
            3 => 'Respon toko',
            4 => 'Target dan efektivitas',
            5 => 'Kepatuhan mapping',
            6 => 'Ketepatan check-in',
            7 => 'Kriteria 7',
            8 => 'Kriteria 8',
            9 => 'Kriteria 9',
            10 => 'Kriteria 10',
            11 => 'Kriteria 11',
            12 => 'Kriteria 12',
            13 => 'Kriteria 13',
            14 => 'Kriteria 14',
            15 => 'Kriteria 15',
            16 => 'Kriteria 16',
            17 => 'Kriteria 17',
            18 => 'Kriteria 18',
        ];

        foreach ($kriteriaNama as $urutan => $nama) {
            KriteriaKondite::create([
                'urutan' => $urutan,
                'nama' => $nama,
                'aktif' => true,
            ]);
        }
    }
}
