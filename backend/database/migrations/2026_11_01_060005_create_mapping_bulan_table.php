<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mapping_bulan', function (Blueprint $table) {
            $table->foreignId('id_mapping')->constrained('mapping_toko', 'id_mapping')->cascadeOnDelete();
            $table->unsignedTinyInteger('bulan');
            $table->boolean('direncanakan')->default(false);
            $table->boolean('terealisasi')->default(false);
            $table->primary(['id_mapping', 'bulan']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mapping_bulan');
    }
};
