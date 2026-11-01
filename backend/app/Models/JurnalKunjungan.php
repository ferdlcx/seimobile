<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class JurnalKunjungan extends Model
{
    use HasFactory;

    protected $table = 'jurnal_kunjungan';
    protected $primaryKey = 'id_kunjungan';

    protected $fillable = [
        'id_mapping',
        'id_sales',
        'no_jo',
        'tgl_kunjungan',
        'status_order',
        'ket_aktivitas',
        'foto_display_path',
        'foto_nota_po_path',
        'lat',
        'lng',
        'jarak_checkin_m',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'tgl_kunjungan' => 'date',
            'lat' => 'double',
            'lng' => 'double',
            'jarak_checkin_m' => 'double',
        ];
    }

    public function mappingToko(): BelongsTo
    {
        return $this->belongsTo(MappingToko::class, 'id_mapping', 'id_mapping');
    }

    public function sales(): BelongsTo
    {
        return $this->belongsTo(Pengguna::class, 'id_sales', 'id');
    }

    public function toko(): BelongsTo
    {
        return $this->belongsTo(Toko::class, 'no_jo', 'no_jo');
    }
}
