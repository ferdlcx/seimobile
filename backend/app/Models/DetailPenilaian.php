<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DetailPenilaian extends Model
{
    use HasFactory;

    protected $table = 'detail_penilaian';
    public $timestamps = false;
    public $incrementing = false;

    protected $fillable = [
        'id_kondite',
        'id_kriteria',
        'nilai',
    ];

    public function penilaianKondite(): BelongsTo
    {
        return $this->belongsTo(PenilaianKondite::class, 'id_kondite', 'id_kondite');
    }

    public function kriteria(): BelongsTo
    {
        return $this->belongsTo(KriteriaKondite::class, 'id_kriteria', 'id_kriteria');
    }
}
