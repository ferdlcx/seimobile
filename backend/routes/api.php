<?php

use App\Http\Controllers\Api\AkunController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\JurnalController;
use App\Http\Controllers\Api\KonditeController;
use App\Http\Controllers\Api\LaporanController;
use App\Http\Controllers\Api\MappingController;
use App\Http\Controllers\Api\MasterController;
use App\Http\Controllers\Api\MonitoringController;
use App\Http\Controllers\Api\RescheduleController;
use Illuminate\Support\Facades\Route;

// Publik
Route::post('/auth/login', [AuthController::class, 'login']);

// Terautentikasi Sanctum (/api/v1/*)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Manajemen Akun (Admin Tagihan)
    Route::middleware('role:admin_tagihan')->group(function () {
        Route::get('/akun', [AkunController::class, 'index']);
        Route::post('/akun', [AkunController::class, 'store']);
        Route::patch('/akun/{id}/aktif', [AkunController::class, 'setAktif']);
    });

    // Master Data
    Route::get('/wilayah', [MasterController::class, 'wilayah']);
    Route::get('/toko', [MasterController::class, 'tokoIndex']);
    Route::post('/toko', [MasterController::class, 'tokoStore'])->middleware('role:admin_tagihan');
    Route::get('/kriteria', [MasterController::class, 'kriteriaIndex']);
    Route::put('/kriteria/{id}', [MasterController::class, 'kriteriaUpdate'])
        ->middleware('role:admin_tagihan,manajer_sales');

    // Mapping
    Route::get('/mapping', [MappingController::class, 'index'])
        ->middleware('role:admin_tagihan,manajer_sales');
    Route::put('/mapping', [MappingController::class, 'save'])
        ->middleware('role:admin_tagihan');
    Route::get('/mapping/hari-ini', [MappingController::class, 'hariIni'])
        ->middleware('role:sales');

    // Jurnal Kunjungan
    Route::get('/jurnal', [JurnalController::class, 'index'])
        ->middleware('role:sales,manajer_sales');
    Route::post('/jurnal', [JurnalController::class, 'store'])
        ->middleware('role:sales');
    Route::post('/jurnal/draft', [JurnalController::class, 'saveDraft'])
        ->middleware('role:sales');
    Route::post('/jurnal/{id}/finalisasi', [JurnalController::class, 'finalisasi'])
        ->middleware('role:sales');

    // Monitoring
    Route::get('/monitoring/harian', [MonitoringController::class, 'harian'])
        ->middleware('role:admin_tagihan,manajer_sales');
    Route::get('/monitoring/sales-progress', [MonitoringController::class, 'salesProgress'])
        ->middleware('role:manajer_sales');

    // Reschedule & Approval (dikontrol feature flag seui.enable_reschedule)
    Route::get('/reschedule', [RescheduleController::class, 'index'])
        ->middleware('role:sales,manajer_sales');
    Route::post('/reschedule', [RescheduleController::class, 'store'])
        ->middleware('role:sales');
    Route::post('/reschedule/{id}/setujui', [RescheduleController::class, 'setujui'])
        ->middleware('role:manajer_sales');
    Route::post('/reschedule/{id}/tolak', [RescheduleController::class, 'tolak'])
        ->middleware('role:manajer_sales');

    // Kondite
    Route::get('/kondite', [KonditeController::class, 'show'])
        ->middleware('role:manajer_sales');
    Route::put('/kondite', [KonditeController::class, 'save'])
        ->middleware('role:manajer_sales');
    Route::get('/kondite/saya', [KonditeController::class, 'saya'])
        ->middleware('role:sales');

    // Laporan Rekap
    Route::get('/laporan/rekap', [LaporanController::class, 'rekap'])
        ->middleware('role:admin_tagihan,manajer_sales');
});
