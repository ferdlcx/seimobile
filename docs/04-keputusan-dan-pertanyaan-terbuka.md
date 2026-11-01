# 04 – Keputusan dan Pertanyaan Terbuka

## Keputusan
- Stack FE: Flutter, flutter_riverpod, go_router, dio, geolocator, image_picker, pdf + printing, intl (id_ID), flutter_secure_storage, json_serializable.
- Stack BE: Laravel 11, MySQL 8, Sanctum. (Bisa diganti; kontrak API tetap.)
- FE dibangun lebih dulu dengan repository Mock (in-memory), nanti diganti repository API.
- PDF Lembar Kondite dan Laporan Rekap dibuat di aplikasi (paket pdf/printing).
- Reschedule/approval di balik feature flag `enableReschedule` (FE) / `ENABLE_RESCHEDULE` (BE).

## Pertanyaan terbuka (cocokkan dengan perusahaan/dosen)
1. Rumus nilai akhir kondite dan bobot B/C/K/SK sebenarnya (contoh di UI: 88.9 = BAIK). Batas label BAIK/dst.
2. Daftar lengkap 18 kriteria (hanya 6 terlihat di desain).
3. Apakah reschedule/approval tetap dipakai (revisi 28 Okt menyederhanakan alur)?
4. Apakah akun tetap tiga tabel sesuai PDM laporan, atau boleh digabung `pengguna`?
5. Radius check-in yang disepakati (default 50 m).
6. Aturan "belum dikunjungi" (default lebih dari 30 hari).

## Asumsi tambahan (tambahkan di bawah oleh AI coding tool)
- Rumus nilai akhir kondite: rata-rata bobot dari 18 kriteria dengan bobot konfigurabel di `AppConfig` (`B=100, C=75, K=50, SK=25`), dibulatkan 1 angka desimal (contoh: 10 kriteria `B` dan 8 kriteria `C` = `1600 / 18 = 88.9`).
- Batas label nilai akhir kondite: `>= 85.0` = `BAIK`, `>= 70.0` = `CUKUP`, `>= 50.0` = `KURANG`, dan `< 50.0` = `SANGAT KURANG`.
- Tanggal acuan ("hari ini") di lingkungan Mock diset ke `Jumat, 30 Okt 2026` sesuai desain UI agar progres awal Budi Santoso (`4 / 6` toko) dan peringatan toko belum dikunjungi konsisten di seluruh peran.
- Simulasi lokasi GPS (`useSimulatedGps = true` di `AppConfig`) diaktifkan secara default untuk memudahkan pengujian check-in di dalam radius 50 meter pada emulator/perangkat uji, dengan tetap mendukung pembacaan GPS perangkat melalui `geolocator`.
- Backend Laravel menggunakan model `App\Models\Pengguna` (tabel `pengguna`) yang terintegrasi dengan Laravel Sanctum, dengan `App\Models\User` sebagai alias/subclass agar kompatibel dengan sistem default.
- Format respon standar `{ data: ..., meta?: ... }` dan penanganan exception JSON Bahasa Indonesia dikonfigurasi secara global pada `bootstrap/app.php` dan `App\Support\ApiResponse`.
- Parameter bisnis sistem (`radius_checkin_m`, `hari_belum_dikunjungi`, `bobot_nilai`, `label_nilai`, `enable_reschedule`, `max_foto_kb`) dipusatkan di `config/seui.php`.
- Pembuatan dan pencetakan dokumen PDF resmi (Lembar Kondite Sales dan Laporan Rekap Kunjungan Toko per Wilayah) menggunakan generator berbasis `pdf` dan `printing` (`PdfGenerator`), menghasilkan layout format A4 dengan Kop Resmi PT. S.E.U.I CENTRE Purwokerto dan tanda tangan digital valid.
