<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MappingToko extends Model
{
    use HasFactory;

    protected $table = 'mapping_toko';
    protected $primaryKey = 'id_mapping';

    protected $fillable = [
        'id_admin',
        'id_sales',
        'no_jo',
        'tahun',
    ];

    protected function casts(): array
    {
        return [
            'tahun' => 'integer',
        ];
    }

    public function admin(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'id_admin', 'id');
    }

    public function sales(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'id_sales', 'id');
    }

    public function toko(): BelongsTo
    {
        return $this->belongsTo(Toko::class, 'no_jo', 'no_jo');
    }

    public function bulan(): HasMany
    {
        return $this->hasMany(MappingBulan::class, 'id_mapping', 'id_mapping')->orderBy('bulan');
    }

    public function jurnalKunjungan(): HasMany
    {
        return $this->hasMany(JurnalKunjungan::class, 'id_mapping', 'id_mapping');
    }
}
