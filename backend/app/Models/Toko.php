<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Toko extends Model
{
    use HasFactory;

    protected $table = 'toko';
    protected $primaryKey = 'no_jo';
    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'no_jo',
        'id_wilayah',
        'nama_toko',
        'alamat',
        'ket_toko',
        'latitude',
        'longitude',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'double',
            'longitude' => 'double',
        ];
    }

    public function wilayah(): BelongsTo
    {
        return $this->belongsTo(Wilayah::class, 'id_wilayah', 'id_wilayah');
    }

    public function mappingToko(): HasMany
    {
        return $this->hasMany(MappingToko::class, 'no_jo', 'no_jo');
    }

    public function jurnalKunjungan(): HasMany
    {
        return $this->hasMany(JurnalKunjungan::class, 'no_jo', 'no_jo');
    }

    public function pengajuanReschedule(): HasMany
    {
        return $this->hasMany(PengajuanReschedule::class, 'no_jo', 'no_jo');
    }
}
