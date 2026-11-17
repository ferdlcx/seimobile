<?php

namespace Tests\Feature;

use App\Models\Pengguna;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiContractTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_login_dan_cek_akun_nonaktif(): void
    {
        $nonaktif = $this->postJson('/api/v1/auth/login', [
            'username' => 'dewi.lestari',
            'password' => 'password123',
            'role' => 'sales',
        ]);
        $nonaktif->assertStatus(403);

        $sales = $this->postJson('/api/v1/auth/login', [
            'username' => 'budi.santoso',
            'password' => 'password123',
            'role' => 'sales',
        ]);
        $sales->assertOk()
            ->assertJsonPath('data.user.username', 'budi.santoso')
            ->assertJsonPath('data.mode', 'sales');
    }

    public function test_admin_kelola_akun_dan_mapping(): void
    {
        $admin = Pengguna::where('username', 'andi.tagihan')->firstOrFail();

        $resAkun = $this->actingAs($admin)->postJson('/api/v1/akun', [
            'nama' => 'Rudi Hartono',
            'username' => 'rudi.hartono',
            'password' => 'password123',
            'role' => 'sales',
            'aktif' => true,
        ]);
        $resAkun->assertCreated()
            ->assertJsonPath('data.is_baru', true);

        $resMapping = $this->actingAs($admin)->getJson('/api/v1/mapping?sales_id=2&tahun=2026');
        $resMapping->assertOk()
            ->assertJsonCount(6, 'data')
            ->assertJsonStructure([
                'data' => [
                    ['id_mapping', 'id_sales', 'tahun', 'toko', 'bulan', 'terealisasi'],
                ],
            ]);
    }

    public function test_sales_jurnal_validasi_radius_dan_manajer_mode_rangkap(): void
    {
        $sales = Pengguna::where('username', 'budi.santoso')->firstOrFail();

        // Di luar radius check-in 50 m ditolak
        $gagalRadius = $this->actingAs($sales)->postJson('/api/v1/jurnal', [
            'no_jo' => 'JO-0501',
            'status_order' => 'tidak_ada_order',
            'ket_aktivitas' => 'Tes luar radius',
            'lat' => -7.4000,
            'lng' => 109.2000,
        ]);
        $gagalRadius->assertStatus(422);

        // Ada order tanpa nota PO ditolak
        $gagalNota = $this->actingAs($sales)->postJson('/api/v1/jurnal', [
            'no_jo' => 'JO-0501',
            'status_order' => 'ada_order',
            'ket_aktivitas' => 'Order tanpa foto nota',
            'lat' => -7.4562,
            'lng' => 109.2865,
        ]);
        $gagalNota->assertStatus(422);

        // Manajer mengakses endpoint Sales menggunakan header X-Mode: sales
        $manajer = Pengguna::where('username', 'maya.kusuma')->firstOrFail();
        $this->actingAs($manajer)
            ->getJson('/api/v1/mapping/hari-ini')
            ->assertStatus(403);

        $this->actingAs($manajer)
            ->withHeader('X-Mode', 'sales')
            ->getJson('/api/v1/mapping/hari-ini')
            ->assertOk()
            ->assertJsonStructure(['data' => ['toko', 'sudah_dikunjungi', 'total_target']]);
    }

    public function test_manajer_kondite_menghitung_nilai_akhir_di_server(): void
    {
        $manajer = Pengguna::where('username', 'maya.kusuma')->firstOrFail();
        $sales = Pengguna::where('username', 'budi.santoso')->firstOrFail();

        $detail = [];
        for ($i = 1; $i <= 18; $i++) {
            $detail[] = [
                'id_kriteria' => $i,
                'nilai' => $i <= 10 ? 'B' : 'C',
            ];
        }

        $res = $this->actingAs($manajer)->putJson('/api/v1/kondite', [
            'sales_id' => $sales->id,
            'periode' => '2026-10',
            'detail' => $detail,
        ]);

        $res->assertOk()
            ->assertJsonPath('data.nilai_akhir', 88.9)
            ->assertJsonPath('data.label', 'BAIK');
    }
}
