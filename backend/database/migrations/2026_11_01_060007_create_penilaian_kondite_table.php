<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('penilaian_kondite', function (Blueprint $table) {
            $table->id('id_kondite');
            $table->foreignId('id_sales')->constrained('pengguna', 'id')->cascadeOnDelete();
            $table->foreignId('id_manajer')->constrained('pengguna', 'id')->cascadeOnDelete();
            $table->string('periode_bulan', 7); // e.g. 2026-10
            $table->date('tgl_penilaian');
            $table->decimal('nilai_akhir', 5, 1);
            $table->string('label', 20);
            $table->unique(['id_sales', 'periode_bulan']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penilaian_kondite');
    }
};
