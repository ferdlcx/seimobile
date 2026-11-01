# AGENTS.md – S.E.U.I Centre

Aplikasi: **Sistem Informasi Mapping, Aktivitas, dan Kondite Sales (S.E.U.I Centre)**.
Monorepo: `frontend/` (Flutter) dan `backend/` (Laravel + MySQL). Dikerjakan terpisah, frontend lebih dulu.

## Wajib dibaca sebelum menulis kode
1. `docs/00-konteks-proyek.md` – bisnis, aktor, aturan bisnis
2. `docs/01-spesifikasi-layar.md` – semua layar per peran
3. `docs/02-kontrak-api.md` – endpoint dan format respons (acuan bersama FE dan BE)
4. `docs/03-model-data.md` – skema database
5. `docs/04-keputusan-dan-pertanyaan-terbuka.md` – asumsi yang sudah diputuskan
6. Desain visual: `docs/desain/ui-alur-bersama.png`. Sumber asli: `docs/sumber/Laporan_ANSI_SEUI.docx`

## Aturan kerja
- Bahasa UI, pesan error, dan komentar penting: **Bahasa Indonesia**.
- Jangan bertanya balik. Bila ambigu, ambil asumsi paling masuk akal lalu catat di `docs/04-keputusan-dan-pertanyaan-terbuka.md`.
- Kerjakan per tahap sesuai file di `prompts/`. Di akhir tiap tahap: jalankan analisis/test (`flutter analyze`, `php artisan test`), perbaiki, beri ringkasan singkat.
- Jangan mengubah isi `docs/` kecuali menambah asumsi di file 04.
- Jangan hardcode bobot nilai kondite, radius check-in, atau feature flag; taruh di konfigurasi.
- Cakupan sistem: mapping, jurnal kunjungan, kondite. Tagihan dan stok di luar cakupan.
