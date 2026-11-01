<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Wilayah extends Model
{
    use HasFactory;

    protected $table = 'wilayah';
    protected $primaryKey = 'id_wilayah';

    protected $fillable = [
        'nama_wilayah',
    ];

    public function toko(): HasMany
    {
        return $this->hasMany(Toko::class, 'id_wilayah', 'id_wilayah');
    }
}
