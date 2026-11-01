<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PenilaianKondite extends Model
{
    use HasFactory;

    protected $table = 'penilaian_kondite';
    protected $primaryKey = 'id_kondite';

    protected $fillable = [
        'id_sales',
        'id_manajer',
        'periode_bulan',
        'tgl_penilaian',
        'nilai_akhir',
        'label',
    ];

    protected function casts(): array
    {
        return [
            'tgl_penilaian' => 'date',
            'nilai_akhir' => 'float',
        ];
    }

    public function sales(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'id_sales', 'id');
    }

    public function manajer(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'id_manajer', 'id');
    }

    public function detail(): HasMany
    {
        return $this->hasMany(DetailPenilaian::class, 'id_kondite', 'id_kondite');
    }
}
