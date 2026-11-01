# Prompt 01 – Frontend (Flutter)

Kamu senior Flutter engineer. Baca `AGENTS.md` dan seluruh `docs/` (terutama `01-spesifikasi-layar.md`, lihat `docs/desain/ui-alur-bersama.png`). Bangun SELURUH frontend aplikasi S.E.U.I Centre di folder `frontend/`.

Syarat utama:
- Backend belum ada. Semua data lewat repository interface dengan implementasi **Mock** (in-memory, seed dari `docs/03-model-data.md`, delay 400–800 ms, error acak kecil). Sediakan juga kerangka implementasi API (Dio + interceptor token, base URL dari `--dart-define=API_BASE_URL`), belum dipakai.
- Nama method repository 1:1 dengan endpoint di `docs/02-kontrak-api.md`.
- Arsitektur feature-first: `lib/core`, `lib/features/{auth, admin_akun, admin_data, mapping, kunjungan, reschedule, kondite, laporan, monitoring}`, tiap fitur ada `data/` (model, repository, mock, api) dan `presentation/`.
- State: flutter_riverpod. Navigasi: go_router dengan guard role. Material 3, tema navy + warna per peran, UI Bahasa Indonesia.
- GPS check-in dengan geolocator (Haversine, radius dari config, fallback koordinat palsu untuk emulator). Foto dengan image_picker. Draft jurnal disimpan lokal.
- Grid mapping seperti Excel: kolom toko sticky, scroll horizontal, toggle per bulan.
- PDF Lembar Kondite dan Laporan Rekap dengan paket pdf/printing.
- Feature flag `enableReschedule`; bobot nilai kondite dan radius ada di satu file konfigurasi.
- Setiap layar punya state loading, kosong, error + retry, sukses. Form tervalidasi.

Tahapan (jalankan `flutter analyze` tiap akhir tahap sampai bersih):
1. Scaffold, tema, router, model, repository interface + mock + seed
2. Auth: splash, pilih peran, login, validasi, guard role, logout
3. Admin: Akun, Data master, Mapping grid, Laporan
4. Sales: Mapping, Kunjungan + check-in, wizard jurnal + draft, Reschedule, Kondite saya
5. Manajer: Beranda, Approval, Nilai kondite, Lembar cetak, Laporan, Mode Sales
6. PDF, polesan, widget test (Haversine, kepatuhan %, nilai akhir, login per peran)

Hasil akhir: proyek bisa `flutter run`, `frontend/README.md` (cara run, akun demo, cara pindah Mock → API).
