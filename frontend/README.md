# S.E.U.I Centre – Frontend Mobile (Flutter)

Aplikasi Mobile **"Sistem Informasi Mapping, Aktivitas, dan Kondite Sales (S.E.U.I Centre)"** untuk perusahaan distribusi suku cadang motor di Purwokerto (STIKOM Yos Sudarso / PT. Seifuku Eikoo Uma Indonesia).

---

## 1. Arsitektur & Teknologi

- **Framework**: Flutter 3.x (Dart 3.x null-safety), Material 3 Design System.
- **State Management**: `flutter_riverpod` (Notifier & StateNotifier pattern).
- **Routing**: `go_router` dengan `RouterNotifier` reaktif dan guard autentikasi per peran (`RoleGuard`).
- **Formatting & Locale**: `intl` dengan format Bahasa Indonesia (`Jumat, 30 Okt 2026`).
- **Dokumen PDF & Cetak**: `pdf` dan `printing` (`PdfGenerator`).
- **GPS & Sensor**: `geolocator` (Haversine formula kalkulasi jarak meter).
- **Penyimpanan Lokal & Network**: `shared_preferences`, `flutter_secure_storage`, `dio`.
- **Repository Pattern**: Seluruh modul UI berkomunikasi lewat antarmuka repository. Repository Mock (`mock_database.dart`) mengelola state data in-memory realistis, siap diganti dengan repository API (`api_*_repository.dart`) hanya dengan mengubah 1 flag:
  ```dart
  // lib/core/providers/repository_providers.dart
  const bool useMock = true; // Ganti ke false untuk terhubung ke REST API Laravel
  ```

---

## 2. Aktor & Akun Demo

Aplikasi memiliki 3 peran aktor dengan kredensial demo siap pakai (telah terisi otomatis di layar login):

| Peran | Username | Password | Mode / Keterangan |
|---|---|---|---|
| **Admin Tagihan** | `andi.tagihan` | `password123` | Akses menu Akun, Data Master, Mapping Toko, dan Laporan Rekap |
| **Sales** | `budi.santoso` | `password123` | Akses Mapping Hari Ini, Kunjungan & GPS Check-in, Reschedule, dan Kondite Saya |
| **Manajer Sales** | `maya.kusuma` | `password123` | Merangkap Sales. Tersedia pilihan **Mode Masuk: Manajer \| Sales** saat login, serta tombol cepat **Mode Sales** di Beranda |
| *Akun Nonaktif* | `dewi.lestari` | `password123` | Sales nonaktif untuk pengujian validasi login akun diblokir |

---

## 3. Fitur Utama Per Peran

### A. Admin Tagihan (Aksen Teal `#0E7C66`)
1. **Akun & Hak Akses**: Daftar akun pengguna, Switch aktif/nonaktif akun dengan dialog konfirmasi, Tambah Akun Baru dengan label **BARU**.
2. **Data Master**: 4 tab terpadu (Sales, Toko, Wilayah, Kriteria), pencarian toko, dan tambah data toko baru.
3. **Susun Mapping Toko**: Grid matriks bergaya spreadsheet (kolom toko sticky di kiri, scroll horizontal 12 bulan JAN–DES, toggle titik hijau, dan penyimpanan mapping ke database).
4. **Monitoring & Laporan Rekap**: Kartu peringatan toko >30 hari belum dikunjungi, kartu kepatuhan jadwal mapping, tabel laporan rekap per wilayah (Target, Real, %, TOTAL), dan ekspor cetak PDF.

### B. Sales (Aksen Oranye `#C2570C`)
1. **Mapping Hari Ini**: Tanggal dinamis, filter wilayah, kartu progres rute (mis. `4 / 6`), daftar toko dan status kunjungan bulanan.
2. **Progress Rute & Kunjungan**: Filter toko (Semua, Belum Dikunjungi, Selesai), tap kartu toko menuju layar detail.
3. **Detail Toko & Validasi GPS Check-in**:
   - Penghitungan jarak akurat dengan formula Haversine.
   - Status visual: **DALAM RADIUS CHECK-IN (12 m)** hijau vs **DI LUAR RADIUS CHECK-IN** merah/oranye.
   - Batas radius konfigurabel (Maksimal 50 meter).
   - Tombol "Check-in di Toko Ini" aktif bila berada dalam radius.
   - Tombol simulasi GPS dekat (12 m) dan jauh (550 m) untuk kemudahan demo.
4. **Wizard Jurnal Kunjungan (3 Langkah)**:
   - Langkah 1: Radio Hasil Kunjungan (*Ada Order*, *Tidak Ada Order*, *Toko Tutup*).
   - Langkah 2: Catatan aktivitas kunjungan toko.
   - Langkah 3: Bukti foto display toko & foto nota PO (**Wajib diunggah** bila memilih *Ada Order*).
   - Aksi: Simpan Jurnal Kunjungan (Final) & Simpan Sebagai Draft di perangkat.
5. **Pengajuan Reschedule**: Formulir perubahan jadwal (pilih toko, tanggal pengganti via DatePicker, alasan), serta pemantauan status pengajuan (*Menunggu*, *Disetujui*, *Ditolak*).
6. **Lembar Kondite Saya (Read-only)**: Kartu skor bulan ini (mis. `88.9 BAIK`), rincian 18 kriteria penilaian dengan lencana kotak nilai `[B]`, `[C]`, `[K]`, `[SK]`, tanpa tombol ubah sesuai spek bisnis.

### C. Manajer Sales (Aksen Biru `#1D4ED8`)
1. **Beranda & Monitoring**: 3 kartu ringkasan (Kunjungan, Order, Reschedule), banner peringatan toko lama, persentase kepatuhan mapping, progres realisasi per sales, dan tombol **Mode Sales** untuk beralih mode kerja sales tanpa login ulang.
2. **Approval Reschedule**: Daftar pengajuan yang menunggu dengan aksi satu-klik **Setujui** (hijau) atau **Tolak** (merah), serta riwayat pengajuan yang sudah diproses.
3. **Penilaian Kondite 18 Kriteria**: ChoiceChip pilihan sales, kartu nilai akhir real-time (otomatis menghitung rata-rata bobot 18 kriteria), segmented button pemilihan nilai B/C/K/SK per kriteria, dan tombol Simpan Penilaian.
4. **Lembar Cetak Kondite Resmi (PDF)**: Pratinjau dokumen resmi A4 berkop surat *PT. S.E.U.I CENTRE PURWOKERTO*, tabel 18 kriteria, nilai akhir, predikat evaluasi, dan stempel tanda tangan digital valid Manajer Sales (*Maya Kusuma*).
5. **Laporan & Rekap**: Monitoring kepatuhan dan pencetakan Laporan Rekap Wilayah.

---

## 4. Konfigurasi Sistem (`lib/core/config/app_config.dart`)

Parameter bisnis aplikasi dipusatkan pada konfigurasi:
- `radiusCheckinMeter`: `50.0` (jarak toleransi maksimal check-in).
- `batasHariBelumDikunjungi`: `30` (ambang peringatan toko belum dikunjungi).
- `bobotNilai`: `{'B': 100, 'C': 75, 'K': 50, 'SK': 25}`.
- `labelNilai`: `>= 85.0: BAIK`, `>= 70.0: CUKUP`, `>= 50.0: KURANG`, `< 50.0: SANGAT KURANG`.
- `enableReschedule`: Feature flag modul reschedule (default: `true`).
- `useSimulatedGps`: `true` untuk mempermudah pengujian radius di emulator.
- `apiBaseUrl`: URL endpoint backend Laravel (default: `http://10.0.2.2:8000/api/v1` untuk Android Emulator atau `http://localhost:8000/api/v1` untuk Web/Desktop).

---

## 5. Cara Menjalankan & Pengujian

### Prasyarat
- Flutter SDK 3.x stable
- Android Emulator / Physical Device / Chrome

### Menjalankan Aplikasi
```bash
cd frontend
flutter pub get
flutter run
```

### Menjalankan Analisis Kode
```bash
flutter analyze
# Hasil: No issues found!
```

### Menjalankan Seluruh Rangkaian Pengujian
```bash
flutter test
# Hasil: All 23 tests passed!
```

Rangkaian 23 tes otomatis mencakup:
- **Tahap 1**: Kalkulasi Haversine GPS, utilitas nilai kondite, persentase kepatuhan mapping, format tanggal `id_ID`, dan guard rute.
- **Tahap 2**: Alur Splash -> Pilih Peran -> Login validasi error & sukses -> Layar Login Berhasil -> Mode Masuk Manajer/Sales.
- **Tahap 3**: Admin Tambah Akun berlabel BARU, Data Master Toko, Susun Grid Excel Mapping, dan Laporan Rekap Wilayah.
- **Tahap 4**: Sales Mapping Hari Ini, Progres Kunjungan, Validasi Radius GPS Detail Toko, Wizard Jurnal & Foto PO, Pengajuan Reschedule, dan Kondite Saya read-only.
- **Tahap 5**: Manajer Beranda metrik ringkasan, beralih Mode Sales, Approval Reschedule Setujui/Tolak, Form Penilaian 18 Kriteria, Lembar Cetak Dokumen Kondite PDF dengan tanda tangan digital, dan Laporan Rekap.
