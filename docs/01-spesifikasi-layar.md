# 01 – Spesifikasi Layar

Acuan visual: `docs/desain/ui-alur-bersama.png`. Mobile portrait, header navy `#0F1B3D`. Warna peran: Admin = teal, Sales = oranye, Manajer = biru. Semua layar punya state loading, kosong, error (retry), dan sukses.

## Umum
| Layar | Isi |
|---|---|
| Splash | Logo "SEUI", "S.E.U.I Centre", progress bar, teks "Menyiapkan jadwal mapping..." |
| Pilih Peran | 3 kartu: Admin Tagihan, Sales, Manajer Sales |
| Login | Username, password, Masuk, "Ganti peran". Akun contoh terisi. Manajer: pilihan Mode masuk Manajer / Sales |
| Login berhasil | Tombol lanjut: Admin → Akun, Sales → Mapping, Manajer → Beranda |

## Admin Tagihan (nav: Akun, Data, Mapping, Laporan)
| Layar | Isi |
|---|---|
| Akun & hak akses | Daftar akun (nama, peran, aktif) dengan Switch; "+ Tambah Akun" |
| Tambah Akun | Nama lengkap, username, password (min 6), peran (Sales / Manajer Sales), status aktif; Batal / Simpan |
| Akun tersimpan | Banner sukses, akun baru berlabel BARU |
| Data master | Tab Sales / Toko / Wilayah / Kriteria; daftar toko (nama, JO, wilayah, badge Sudah/Belum); "+ Tambah Data Toko" |
| Tambah Toko | Nama toko, nomor JO, wilayah (chip), alamat |
| Susun mapping | Pilih sales, tahun, filter wilayah; grid toko × JAN–DES (toggle titik hijau), kolom toko sticky, scroll horizontal; Simpan Mapping |
| Mapping tersimpan | Banner "Sales melihatnya di menu Mapping"; tombol Lihat laporan |
| Monitoring & laporan | Filter wilayah, peringatan hari ini, kepatuhan tutup %, realisasi x/y, Cetak Laporan Rekap |
| Hasil laporan rekap | Tabel Wilayah / Target / Real / %, baris TOTAL, waktu cetak; Cetak, Simpan PDF |

## Sales (nav: Mapping, Kunjungan, Reschedule, Kondite)
| Layar | Isi |
|---|---|
| Mapping hari ini | Tanggal + nama sales, filter wilayah, progres rute (4/6), daftar toko + status, Mulai Check-in |
| Progress rute / Kunjungan | Progres + daftar toko, tap untuk detail |
| Detail toko | Lokasi GPS: jarak ke toko, status dalam radius; "Check-in di Toko Ini" (aktif bila dalam radius); "Ajukan Reschedule" |
| Hasil kunjungan (1/3) | Radio: Ada Order / Tidak Ada Order / Toko Tutup; Lanjut |
| Order & bukti / Jurnal (2–3/3) | Catatan jurnal, foto display, foto nota PO; "Simpan Jurnal Kunjungan", "Simpan Sebagai Draft" |
| Reschedule | Daftar pengajuan (Menunggu / Disetujui / Ditolak); "+ Buat Pengajuan Reschedule Baru" |
| Form reschedule | Toko, jadwal pengganti, alasan; Ajukan |
| Kondite saya | Read-only: nilai bulan ini + label (mis. 88.9 BAIK), 18 kriteria dengan badge B/C/K/SK |

## Manajer Sales (nav: Beranda, Reschedule, Kondite, Laporan)
| Layar | Isi |
|---|---|
| Beranda & monitoring | Kartu Kunjungan (14/22), Order (11), Reschedule (2); banner toko lama belum dikunjungi; realisasi per sales; kepatuhan mapping; tombol Mode Sales |
| Approval reschedule | Daftar menunggu: Setujui / Tolak; bagian "Sudah diproses" |
| Approval diproses | Banner "Reschedule disetujui. Jadwal sales diperbarui." |
| Nilai kondite | Chip pilih sales, kartu nilai akhir, 18 kriteria dengan segmented B/C/K/SK, "Cetak Lembar Kondite (PDF)" |
| Lembar cetak kondite | Tabel Kriteria / Nilai, NILAI AKHIR, tanda tangan digital Manajer; Cetak, Simpan PDF |
| Laporan & rekap | Seperti Admin; "Cetak Laporan Rekap" |
| Hasil rekap | Seperti hasil rekap Admin |

## 18 kriteria kondite
Yang terlihat di UI: (1) Kehadiran dan jam kunjungan, (2) Kesesuaian prosedur, (3) Respon toko, (4) Target dan efektivitas, (5) Kepatuhan mapping, (6) Ketepatan check-in. Kriteria 7–18 memakai placeholder sampai dicocokkan dengan form kondite perusahaan.
