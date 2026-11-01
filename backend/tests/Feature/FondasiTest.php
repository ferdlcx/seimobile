<?php

namespace Tests\Feature;

use App\Models\KriteriaKondite;
use App\Models\MappingToko;
use App\Models\Pengguna;
use App\Models\Toko;
use App\Models\Wilayah;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FondasiTest extends TestCase
{
    use RefreshDatabase;

    public function test_seeder_populates_initial_data_correctly(): void
    {
        $this->seed();

        $this->assertDatabaseCount('pengguna', 4);
        $this->assertDatabaseCount('wilayah', 4);
        $this->assertDatabaseCount('toko', 6);
        $this->assertDatabaseCount('kriteria_kondite', 18);
        $this->assertDatabaseCount('mapping_toko', 6);
        $this->assertDatabaseCount('mapping_bulan', 72);

        $andi = Pengguna::where('username', 'andi.tagihan')->first();
        $this->assertNotNull($andi);
        $this->assertEquals('admin_tagihan', $andi->role);
        $this->assertTrue($andi->aktif);

        $dewi = Pengguna::where('username', 'dewi.lestari')->first();
        $this->assertNotNull($dewi);
        $this->assertFalse($dewi->aktif);

        $toko = Toko::where('no_jo', 'JO-0412')->first();
        $this->assertNotNull($toko);
        $this->assertEquals('Purwokerto Timur', $toko->wilayah->nama_wilayah);

        $mapping = MappingToko::where('no_jo', 'JO-0412')->first();
        $this->assertNotNull($mapping);
        $this->assertEquals(12, $mapping->bulan()->count());
    }

    public function test_seui_configuration_is_loaded(): void
    {
        $this->assertEquals(50.0, config('seui.radius_checkin_m'));
        $this->assertEquals(30, config('seui.hari_belum_dikunjungi'));
        $this->assertEquals(100, config('seui.bobot_nilai.B'));
        $this->assertEquals(75, config('seui.bobot_nilai.C'));
        $this->assertEquals(50, config('seui.bobot_nilai.K'));
        $this->assertEquals(25, config('seui.bobot_nilai.SK'));
        $this->assertEquals('BAIK', config('seui.label_nilai.85'));
        $this->assertTrue(config('seui.enable_reschedule'));
        $this->assertEquals(3072, config('seui.max_foto_kb'));
    }

    public function test_api_404_returns_standard_json_response(): void
    {
        $response = $this->getJson('/api/v1/endpoint-tidak-ada');

        $response->assertStatus(404)
            ->assertJsonStructure(['message']);
    }
}
