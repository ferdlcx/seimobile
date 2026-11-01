# 00 – Konteks Proyek

Sumber: Laporan Analisis dan Perancangan Sistem, studi kasus Seifuku Eikoo Uma Indonesia (S.E.U.I Centre), Purwokerto. Kelompok 4, STIKOM Yos Sudarso.

## Latar belakang
- Sales suku cadang mengunjungi toko pelanggan, take order, dan menagih. Jadwal fleksibel, **tidak ada fixed route**, tetapi toko rutin harus dikunjungi **maksimal sebulan sekali**.
- Masalah saat ini: jadwal sulit dipantau, pencatatan manual lalu baru diinput malam/esok pagi (tidak real-time), pelaporan bergantung kedisiplinan sales, penilaian kondite tidak objektif.
- Sistem hanya mencakup: **mapping**, **jurnal kunjungan**, **kondite**. Tagihan dan stok gudang tidak termasuk.

## Aktor (berdasarkan ROLE, bukan orang)
| Role | Tugas di sistem |
|---|---|
| Admin Tagihan | Kelola akun, data master (sales, toko, wilayah, kriteria), susun mapping tahunan, lihat monitoring dan laporan rekap |
| Sales | Lihat mapping, check-in dan input jurnal kunjungan, ajukan reschedule (opsional), lihat kondite sendiri (read-only) |
| Manajer Sales | Monitoring harian, approval reschedule (opsional), input nilai kondite 18 kriteria, cetak lembar kondite, laporan rekap |

Manajer Sales merangkap Sales lapangan (mis. Syamsul Huda). Saat login ada **mode masuk: Manajer atau Sales**. Satu akun, dua tampilan.

## Identitas data
- Toko diidentifikasi **No JO** (contoh `JO-0412`), bukan nama, karena nama toko banyak yang kembar.
- Wilayah: Purwokerto Timur, Purwokerto Barat, Purwokerto Selatan, Sokaraja.

## Aturan bisnis
1. Mapping tahunan per sales: matriks toko × bulan (JAN–DES). Disusun Admin Tagihan.
2. Saat jurnal kunjungan disimpan, status bulan terkait di mapping otomatis menjadi **terealisasi**.
3. Check-in hanya valid bila jarak GPS ke toko ≤ radius (default **50 m**, konfigurabel). Server menghitung ulang jarak (Haversine).
4. Hasil kunjungan: `ada_order`, `tidak_ada_order`, `toko_tutup`. Foto nota PO wajib bila `ada_order`.
5. Peringatan: toko mapping belum dikunjungi lebih dari 30 hari, atau sales belum input hari ini.
6. Kepatuhan mapping (%) = toko terealisasi / target toko pada periode.
7. Kondite: 18 kriteria, nilai B/C/K/SK per kriteria, nilai akhir dihitung dengan bobot konfigurabel (default B=100, C=75, K=50, SK=25). Sales hanya melihat.
8. Reschedule/approval berada di balik feature flag `enableReschedule` (default aktif). Revisi sistem 28 Okt 2026 menyederhanakan alur tanpa reschedule, jadi harus mudah dimatikan.

## Alur ringkas (sistem usulan)
Admin input master dan mapping → Sales melihat mapping, kunjungi toko, input jurnal langsung → ceklis bulan ter-update otomatis → sistem membuat rekap bulanan → Manajer menilai kondite → lembar kondite dicetak dan disahkan.
