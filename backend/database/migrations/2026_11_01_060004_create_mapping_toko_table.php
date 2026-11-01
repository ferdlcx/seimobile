<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mapping_toko', function (Blueprint $table) {
            $table->id('id_mapping');
            $table->foreignId('id_admin')->constrained('pengguna', 'id')->cascadeOnDelete();
            $table->foreignId('id_sales')->constrained('pengguna', 'id')->cascadeOnDelete();
            $table->string('no_jo', 30);
            $table->foreign('no_jo')->references('no_jo')->on('toko')->cascadeOnDelete();
            $table->integer('tahun');
            $table->unique(['id_sales', 'no_jo', 'tahun']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mapping_toko');
    }
};
