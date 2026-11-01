<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengajuan_reschedule', function (Blueprint $table) {
            $table->id();
            $table->foreignId('id_sales')->constrained('pengguna', 'id')->cascadeOnDelete();
            $table->string('no_jo', 30);
            $table->foreign('no_jo')->references('no_jo')->on('toko')->cascadeOnDelete();
            $table->date('jadwal_lama');
            $table->date('jadwal_baru');
            $table->text('alasan');
            $table->enum('status', ['menunggu', 'disetujui', 'ditolak'])->default('menunggu');
            $table->foreignId('id_manajer')->nullable()->constrained('pengguna', 'id')->nullOnDelete();
            $table->timestamp('tgl_proses')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengajuan_reschedule');
    }
};
