<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Pengguna extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'pengguna';

    protected $fillable = [
        'nama',
        'username',
        'password',
        'role',
        'aktif',
        'tanda_tangan_path',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'aktif' => 'boolean',
            'password' => 'hashed',
        ];
    }

    public function jurnalKunjungan(): HasMany
    {
        return $this->hasMany(JurnalKunjungan::class, 'id_sales');
    }

    public function mappingToko(): HasMany
    {
        return $this->hasMany(MappingToko::class, 'id_sales');
    }

    public function penilaianKonditeSales(): HasMany
    {
        return $this->hasMany(PenilaianKondite::class, 'id_sales');
    }

    public function penilaianKonditeManajer(): HasMany
    {
        return $this->hasMany(PenilaianKondite::class, 'id_manajer');
    }

    public function pengajuanReschedule(): HasMany
    {
        return $this->hasMany(PengajuanReschedule::class, 'id_sales');
    }
}
