<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('toko', function (Blueprint $table) {
            $table->string('no_jo', 30)->primary();
            $table->foreignId('id_wilayah')->constrained('wilayah', 'id_wilayah')->cascadeOnDelete();
            $table->string('nama_toko');
            $table->text('alamat');
            $table->text('ket_toko')->nullable();
            $table->double('latitude');
            $table->double('longitude');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('toko');
    }
};
