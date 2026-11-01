<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class KriteriaKondite extends Model
{
    use HasFactory;

    protected $table = 'kriteria_kondite';
    protected $primaryKey = 'id_kriteria';

    protected $fillable = [
        'urutan',
        'nama',
        'aktif',
    ];

    protected function casts(): array
    {
        return [
            'urutan' => 'integer',
            'aktif' => 'boolean',
        ];
    }

    public function detailPenilaian(): HasMany
    {
        return $this->hasMany(DetailPenilaian::class, 'id_kriteria', 'id_kriteria');
    }
}
