<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jurnal_kunjungan', function (Blueprint $table) {
            $table->id('id_kunjungan');
            $table->foreignId('id_mapping')->nullable()->constrained('mapping_toko', 'id_mapping')->nullOnDelete();
            $table->foreignId('id_sales')->constrained('pengguna', 'id')->cascadeOnDelete();
            $table->string('no_jo', 30);
            $table->foreign('no_jo')->references('no_jo')->on('toko')->cascadeOnDelete();
            $table->date('tgl_kunjungan');
            $table->enum('status_order', ['ada_order', 'tidak_ada_order', 'toko_tutup']);
            $table->text('ket_aktivitas')->nullable();
            $table->string('foto_display_path')->nullable();
            $table->string('foto_nota_po_path')->nullable();
            $table->double('lat');
            $table->double('lng');
            $table->double('jarak_checkin_m');
            $table->enum('status', ['draft', 'final'])->default('final');
            $table->index(['id_sales', 'tgl_kunjungan']);
            $table->index(['no_jo', 'tgl_kunjungan']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jurnal_kunjungan');
    }
};
