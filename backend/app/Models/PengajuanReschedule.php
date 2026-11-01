<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PengajuanReschedule extends Model
{
    use HasFactory;

    protected $table = 'pengajuan_reschedule';

    protected $fillable = [
        'id_sales',
        'no_jo',
        'jadwal_lama',
        'jadwal_baru',
        'alasan',
        'status',
        'id_manajer',
        'tgl_proses',
    ];

    protected function casts(): array
    {
        return [
            'jadwal_lama' => 'date',
            'jadwal_baru' => 'date',
            'tgl_proses' => 'datetime',
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

    public function toko(): BelongsTo
    {
        return $this->belongsTo(Toko::class, 'no_jo', 'no_jo');
    }
}
