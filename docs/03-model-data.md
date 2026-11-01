# 03 – Model Data

Mengacu pada CDM/PDM di laporan. Perbedaan: tiga entitas akun (Admin_Tagihan, Sales, Manajer_Sales) digabung menjadi tabel `pengguna` dengan kolom `role`.

| Tabel | Kolom utama |
|---|---|
| wilayah | id_wilayah PK, nama_wilayah |
| toko | no_jo PK VARCHAR(30), id_wilayah FK, nama_toko, alamat TEXT, ket_toko, latitude, longitude |
| pengguna | id PK, nama, username UNIQUE, password (hash), role ENUM(admin_tagihan, sales, manajer_sales), aktif BOOL, tanda_tangan_path NULL |
| mapping_toko | id_mapping PK, id_admin FK, id_sales FK, no_jo FK, tahun YEAR |
| mapping_bulan | id_mapping FK, bulan TINYINT 1–12, direncanakan BOOL, terealisasi BOOL |
| jurnal_kunjungan | id_kunjungan PK, id_mapping FK NULL, id_sales FK, no_jo FK, tgl_kunjungan DATE, status_order ENUM(ada_order, tidak_ada_order, toko_tutup), ket_aktivitas TEXT, foto_display_path, foto_nota_po_path, lat, lng, jarak_checkin_m, status ENUM(draft, final) |
| kriteria_kondite | id_kriteria PK, urutan, nama, aktif |
| penilaian_kondite | id_kondite PK, id_sales FK, id_manajer FK, periode_bulan, tgl_penilaian DATE, nilai_akhir DECIMAL(5,1), label |
| detail_penilaian | id_kondite FK, id_kriteria FK, nilai ENUM(B, C, K, SK) |
| pengajuan_reschedule | id PK, id_sales FK, no_jo FK, jadwal_lama, jadwal_baru, alasan, status ENUM(menunggu, disetujui, ditolak), id_manajer FK NULL, tgl_proses |

Relasi: wilayah 1–N toko; toko 1–N mapping_toko; mapping_toko 1–N mapping_bulan dan jurnal_kunjungan; pengguna(sales) 1–N jurnal dan penilaian; pengguna(manajer) 1–N penilaian; penilaian_kondite 1–N detail_penilaian.
Index: (id_sales, tgl_kunjungan), (no_jo, tgl_kunjungan).

## Data seed demo
- Akun: `andi.tagihan` (admin_tagihan), `budi.santoso` (sales), `maya.kusuma` (manajer_sales), `dewi.lestari` (sales, nonaktif). Password demo `password123` (hanya seeder).
- Toko: Makmur Jaya JO-0412 (Timur), Sumber Rejeki JO-0388 (Timur), Bintang Terang JO-0501 (Sokaraja), Berkah Abadi JO-0375 (Barat), Sentosa Abadi JO-0420 (Barat), Harapan Jaya JO-0433 (Selatan). Koordinat sekitar Purwokerto.
