<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MappingBulan extends Model
{
    use HasFactory;

    protected $table = 'mapping_bulan';
    public $timestamps = false;
    public $incrementing = false;

    protected $fillable = [
        'id_mapping',
        'bulan',
        'direncanakan',
        'terealisasi',
    ];

    protected function casts(): array
    {
        return [
            'bulan' => 'integer',
            'direncanakan' => 'boolean',
            'terealisasi' => 'boolean',
        ];
    }

    public function mappingToko(): BelongsTo
    {
        return $this->belongsTo(MappingToko::class, 'id_mapping', 'id_mapping');
    }
}
