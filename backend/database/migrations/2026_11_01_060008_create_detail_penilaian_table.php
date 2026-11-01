<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('detail_penilaian', function (Blueprint $table) {
            $table->foreignId('id_kondite')->constrained('penilaian_kondite', 'id_kondite')->cascadeOnDelete();
            $table->foreignId('id_kriteria')->constrained('kriteria_kondite', 'id_kriteria')->cascadeOnDelete();
            $table->enum('nilai', ['B', 'C', 'K', 'SK']);
            $table->primary(['id_kondite', 'id_kriteria']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('detail_penilaian');
    }
};
