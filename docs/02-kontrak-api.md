# 02 – Kontrak API (acuan bersama Frontend dan Backend)

Base URL: `/api/v1`. Auth: Bearer token (Laravel Sanctum). Semua bidang JSON `snake_case`. Nama method repository Flutter sejajar dengan endpoint di bawah.

## Format respons
Sukses: `{ "data": ..., "meta": { "page": 1, "per_page": 20, "total": 0 } }` (meta hanya untuk daftar).
Gagal: `{ "message": "Pesan Indonesia", "errors": { "field": ["..."] } }` dengan kode 401 / 403 / 404 / 422.

## Endpoint
| Method | Path | Role | Keterangan |
|---|---|---|---|
| POST | /auth/login | publik | body: username, password, role, mode (manajer/sales) → token + user |
| POST | /auth/logout | semua | |
| GET | /auth/me | semua | profil + role + mode |
| GET | /akun | admin | daftar akun |
| POST | /akun | admin | nama, username, password, role, aktif |
| PATCH | /akun/{id}/aktif | admin | `{ "aktif": true }` |
| GET | /wilayah | semua | |
| GET | /toko | semua | filter wilayah_id, q; ikut status kunjungan bulan ini |
| POST | /toko | admin | no_jo, nama_toko, id_wilayah, alamat, ket_toko, latitude, longitude |
| GET | /kriteria | semua | 18 kriteria |
| PUT | /kriteria/{id} | admin, manajer | ubah nama/aktif |
| GET | /mapping | admin, manajer | sales_id, tahun, wilayah_id → toko × bulan |
| PUT | /mapping | admin | simpan grid |
| GET | /mapping/hari-ini | sales | daftar toko + progres |
| GET | /jurnal | sales, manajer | tanggal, sales_id |
| POST | /jurnal | sales | multipart: no_jo, status_order, ket_aktivitas, lat, lng, foto_display, foto_nota_po |
| POST | /jurnal/draft | sales | simpan draft |
| POST | /jurnal/{id}/finalisasi | sales | draft → final |
| GET | /monitoring/harian | admin, manajer | peringatan, kartu ringkasan |
| GET | /monitoring/sales-progress | manajer | realisasi per sales |
| GET | /reschedule | sales, manajer | (feature flag) |
| POST | /reschedule | sales | no_jo, jadwal_baru, alasan |
| POST | /reschedule/{id}/setujui | manajer | |
| POST | /reschedule/{id}/tolak | manajer | |
| GET | /kondite | manajer | sales_id, periode |
| PUT | /kondite | manajer | sales_id, periode, detail: [{id_kriteria, nilai}] → nilai_akhir dihitung server |
| GET | /kondite/saya | sales | read-only |
| GET | /laporan/rekap | admin, manajer | periode, wilayah_id → baris wilayah/target/real/persen + total |

## Aturan khusus
- Manajer memakai endpoint Sales dengan header `X-Mode: sales`.
- Server menghitung ulang jarak check-in; klien hanya mengirim lat/lng.
- Foto: jpg/png, maksimal 3 MB, URL file bertanda tangan.
