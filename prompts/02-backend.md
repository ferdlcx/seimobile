# Prompt 02 – Backend (Laravel + MySQL)

Kamu senior backend engineer. Baca `AGENTS.md` dan seluruh `docs/` (terutama `00-konteks-proyek.md`, `02-kontrak-api.md`, `03-model-data.md`). Bangun REST API di folder `backend/` (Laravel 11, MySQL 8, Sanctum) yang persis mengikuti kontrak API, supaya aplikasi Flutter cukup mengganti repository Mock dengan repository API.

Syarat utama:
- Migration, model, relasi, seeder sesuai `03-model-data.md` (akun demo, 4 wilayah, 6 toko, 18 kriteria, mapping 2026 contoh).
- Middleware/policy per role; Sales hanya melihat datanya sendiri; Manajer memakai fitur Sales lewat header `X-Mode: sales`.
- Server menghitung jarak check-in (Haversine) dan nilai akhir kondite (bobot dari config). Saat jurnal final disimpan, `mapping_bulan.terealisasi` otomatis diperbarui.
- Validasi FormRequest, rate limit login, upload foto (jpg/png, ≤ 3 MB) di storage privat dengan URL bertanda tangan.
- Feature flag `ENABLE_RESCHEDULE`.
- Format respons dan kode error sesuai kontrak. CORS dan `.env.example` lengkap.
- Dokumentasi OpenAPI (Scribe atau l5-swagger) dan koleksi Postman.
- Feature test: login per role, hak akses, auto-update mapping, validasi radius, perhitungan nilai akhir, alur approval reschedule.

Tahapan (jalankan `php artisan test` tiap akhir tahap):
1. Setup, migration, model, seeder
2. Auth + role middleware
3. Master, akun, mapping
4. Jurnal + upload + monitoring
5. Kondite + laporan rekap
6. Reschedule, test, dokumentasi

Hasil akhir: `backend/README.md` (composer install, migrate --seed, storage:link, cara menjalankan test).
