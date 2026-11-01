import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seui_centre/app.dart';
import 'package:seui_centre/core/config/app_config.dart';
import 'package:seui_centre/core/router/app_router.dart';
import 'package:seui_centre/core/utils/format.dart';
import 'package:seui_centre/core/utils/haversine.dart';
import 'package:seui_centre/core/utils/nilai_kondite.dart';
import 'package:seui_centre/features/auth/data/auth_repository.dart';
import 'package:seui_centre/features/auth/data/models/pengguna_model.dart';
import 'package:seui_centre/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('Tahap 1 - Utilitas & Logika Inti', () {
    test('Haversine menghitung jarak dalam meter dengan benar', () {
      expect(haversine(-7.4243, 109.2391, -7.4243, 109.2391), closeTo(0.0, 0.1));

      final d = haversine(-7.4243, 109.2391, -7.4244, 109.2391);
      expect(d, lessThan(50.0));
      expect(
        isWithinCheckinRadius(jarakM: d, radiusCheckinMeter: 50.0),
        isTrue,
      );
    });

    test('Nilai akhir kondite dan label dihitung sesuai konfigurasi', () {
      final config = AppConfig();
      final detail = <int, String>{
        for (int i = 1; i <= 10; i++) i: 'B',
        for (int i = 11; i <= 18; i++) i: 'C',
      };
      final nilai = NilaiKonditeUtils.hitungNilaiAkhir(detail, config.bobotNilai);
      expect(nilai, equals(88.9));
      expect(NilaiKonditeUtils.tentukanLabel(nilai), equals('BAIK'));
      expect(NilaiKonditeUtils.tentukanLabel(75.0), equals('CUKUP'));
      expect(NilaiKonditeUtils.tentukanLabel(55.0), equals('KURANG'));
      expect(NilaiKonditeUtils.tentukanLabel(40.0), equals('SANGAT KURANG'));
    });

    test('Kepatuhan mapping menghitung persentase dengan aman', () {
      expect(
        NilaiKonditeUtils.hitungKepatuhanPersen(terealisasi: 4, target: 6),
        equals(67),
      );
      expect(
        NilaiKonditeUtils.hitungKepatuhanPersen(terealisasi: 0, target: 0),
        equals(0),
      );
    });

    test('Format tanggal Bahasa Indonesia menghasilkan Jumat, 30 Okt 2026', () {
      final dt = DateTime(2026, 10, 30);
      expect(AppFormat.formatTanggalHari(dt), equals('Jumat, 30 Okt 2026'));
    });

    test('Route guard menolak akses ke rute peran lain', () {
      const salesSession = AuthSession(
        token: 'tok',
        user: Pengguna(
          id: 2,
          nama: 'Budi Santoso',
          username: 'budi.santoso',
          role: 'sales',
          aktif: true,
        ),
        mode: 'sales',
      );
      const salesAuth = AuthState(session: salesSession);

      expect(
        evaluateRouteGuard(location: '/admin/akun', auth: salesAuth),
        equals('/sales/mapping'),
      );
      expect(
        evaluateRouteGuard(location: '/sales/mapping', auth: salesAuth),
        isNull,
      );
    });
  });

  group('Tahap 2 - Alur Layar Penuh Auth', () {
    testWidgets('Splash berpindah ke Pilih Peran dan menampilkan 3 peran', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );

      // Splash tampil
      expect(find.text('Menyiapkan jadwal mapping...'), findsOneWidget);

      // Lewati durasi timer splash
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Pilih Peran tampil
      expect(find.text('Masuk ke S.E.U.I Centre'), findsOneWidget);
      expect(find.text('Admin Tagihan'), findsOneWidget);
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Manajer Sales'), findsOneWidget);
    });

    testWidgets('Alur login Sales: buka form, validasi error, login sukses ke Login Berhasil', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Tap kartu Sales
      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();

      // Form login Sales tampil dengan default budi.santoso
      expect(find.text('Masuk sebagai Sales'), findsOneWidget);
      expect(find.text('budi.santoso'), findsOneWidget);

      // Kosongkan username untuk tes validasi
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Username wajib diisi'), findsOneWidget);

      // Isi kembali budi.santoso dan login
      await tester.enterText(find.byType(TextFormField).first, 'budi.santoso');
      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Layar Login Berhasil tampil
      expect(find.text('Login berhasil'), findsOneWidget);
      expect(find.text('Langsung masuk ke Menu Mapping'), findsOneWidget);

      // Klik tombol untuk masuk ke mapping
      await tester.tap(find.text('Langsung masuk ke Menu Mapping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Berada di layar Mapping Sales
      expect(find.text('Mapping hari ini'), findsOneWidget);
    });

    testWidgets('Login akun nonaktif menampilkan pesan error', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();

      // Masukkan username akun nonaktif dewi.lestari
      await tester.enterText(find.byType(TextFormField).first, 'dewi.lestari');
      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(
        find.text('Akun ini sedang nonaktif. Hubungi Admin Tagihan.'),
        findsOneWidget,
      );
    });

    testWidgets('Login Manajer Sales memiliki pilihan Mode Masuk Manajer / Sales', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manajer Sales'));
      await tester.pumpAndSettle();

      expect(find.text('Masuk sebagai Manajer Sales'), findsOneWidget);
      expect(find.text('Mode masuk (akun rangkap Sales)'), findsOneWidget);

      // Default mode Manajer
      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Login berhasil'), findsOneWidget);
      expect(find.text('Langsung masuk ke Beranda'), findsOneWidget);

      await tester.tap(find.text('Langsung masuk ke Beranda'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Monitoring Sales'), findsOneWidget);
    });
  });

  group('Tahap 3 - Admin Tagihan (Akun, Data, Mapping, Laporan)', () {
    Future<void> loginAsAdmin(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Admin Tagihan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Langsung masuk ke Menu Akun'), findsOneWidget);
      await tester.tap(find.text('Langsung masuk ke Menu Akun'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
    }

    testWidgets('Admin Akun: tambah akun baru dan muncul label BARU', (tester) async {
      await loginAsAdmin(tester);

      expect(find.text('Akun & hak akses'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsOneWidget);

      // Klik "+ Tambah Akun"
      await tester.ensureVisible(find.text('+ Tambah Akun'));
      await tester.tap(find.text('+ Tambah Akun'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Akun Baru'), findsOneWidget);
      expect(find.text('Rudi Hartono'), findsOneWidget);

      // Simpan Akun
      await tester.ensureVisible(find.text('Simpan Akun'));
      await tester.tap(find.text('Simpan Akun'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Kembali ke layar akun dan ada banner sukses serta badge BARU
      expect(find.text('Akun berhasil ditambahkan. Notifikasi dikirim: akun baru sudah muncul dengan label BARU.'), findsOneWidget);
      expect(find.text('BARU'), findsOneWidget);
      expect(find.text('Rudi Hartono'), findsOneWidget);
    });

    testWidgets('Admin Data Master: lihat tab toko dan tambah toko baru', (tester) async {
      await loginAsAdmin(tester);

      // Pindah ke tab Data
      await tester.tap(find.text('Data'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Data master'), findsOneWidget);
      expect(find.text('Toko Makmur Jaya'), findsOneWidget);

      // Klik "+ Tambah Data Toko"
      await tester.ensureVisible(find.text('+ Tambah Data Toko'));
      await tester.tap(find.text('+ Tambah Data Toko'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Data Toko'), findsOneWidget);
      expect(find.text('Toko Maju Bersama'), findsOneWidget);

      // Simpan Toko
      await tester.ensureVisible(find.text('Simpan Data Toko'));
      await tester.tap(find.text('Simpan Data Toko'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Muncul di daftar toko
      expect(find.text('Data master'), findsOneWidget);
      expect(find.text('Toko Maju Bersama'), findsOneWidget);
    });

    testWidgets('Admin Mapping: lihat grid Excel dan simpan mapping', (tester) async {
      await loginAsAdmin(tester);

      // Pindah ke tab Mapping
      await tester.tap(find.text('Mapping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Susun mapping toko'), findsOneWidget);
      expect(find.text('TOKO'), findsOneWidget);
      expect(find.text('JAN'), findsOneWidget);

      // Klik Simpan Mapping
      await tester.ensureVisible(find.text('Simpan Mapping'));
      await tester.tap(find.text('Simpan Mapping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Mapping berhasil disimpan'), findsOneWidget);
      expect(find.text('Lihat laporan'), findsOneWidget);
    });

    testWidgets('Admin Laporan: monitoring harian dan cetak laporan rekap', (tester) async {
      await loginAsAdmin(tester);

      // Pindah ke tab Laporan
      await tester.tap(find.text('Laporan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Monitoring & laporan'), findsOneWidget);
      expect(find.text('PERINGATAN HARI INI'), findsOneWidget);
      expect(find.text('Cetak Laporan Rekap'), findsOneWidget);

      // Klik Cetak Laporan Rekap
      await tester.ensureVisible(find.text('Cetak Laporan Rekap'));
      await tester.tap(find.text('Cetak Laporan Rekap'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Hasil cetak laporan rekap'), findsOneWidget);
      expect(find.text('S.E.U.I CENTRE – LAPORAN REKAP'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('Cetak'), findsOneWidget);
      expect(find.text('Simpan PDF'), findsOneWidget);
    });
  });

  group('Tahap 4 - Sales (Mapping, Kunjungan, Reschedule, Kondite)', () {
    Future<void> loginAsSales(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Langsung masuk ke Menu Mapping'), findsOneWidget);
      await tester.tap(find.text('Langsung masuk ke Menu Mapping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
    }

    testWidgets('Sales Mapping: lihat progress rute dan klik Mulai Check-in', (tester) async {
      await loginAsSales(tester);

      expect(find.text('Mapping hari ini'), findsOneWidget);
      expect(find.text('PROGRESS RUTE HARI INI'), findsOneWidget);
      expect(find.text('Toko Makmur Jaya'), findsOneWidget);

      // Klik tombol Mulai Check-in
      await tester.ensureVisible(find.text('Mulai Check-in'));
      await tester.tap(find.text('Mulai Check-in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Berpindah ke layar Kunjungan
      expect(find.text('Progress Rute Kunjungan'), findsOneWidget);
    });

    testWidgets('Sales Kunjungan: list toko, detail toko & simulasi radius GPS', (tester) async {
      await loginAsSales(tester);

      // Pindah ke tab Kunjungan
      await tester.tap(find.text('Kunjungan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Progress Rute Kunjungan'), findsOneWidget);
      expect(find.text('Toko Makmur Jaya'), findsOneWidget);

      // Tap Toko Makmur Jaya untuk masuk ke Detail
      await tester.tap(find.text('Toko Makmur Jaya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Detail Toko & Check-in'), findsOneWidget);
      expect(find.text('DALAM RADIUS CHECK-IN'), findsOneWidget);

      // Tes tombol simulasi di luar radius (550 m)
      await tester.tap(find.text('Simulasi Jauh (550 m)'));
      await tester.pumpAndSettle();
      expect(find.text('DI LUAR RADIUS CHECK-IN'), findsOneWidget);

      // Kembalikan ke simulasi dekat (12 m)
      await tester.tap(find.text('Simulasi Dekat (12 m)'));
      await tester.pumpAndSettle();
      expect(find.text('DALAM RADIUS CHECK-IN'), findsOneWidget);
    });

    testWidgets('Sales Wizard Jurnal: isi jurnal kunjungan & simpan final', (tester) async {
      await loginAsSales(tester);

      await tester.tap(find.text('Kunjungan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Toko Makmur Jaya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Klik Check-in di Toko Ini
      await tester.ensureVisible(find.text('Check-in di Toko Ini'));
      await tester.tap(find.text('Check-in di Toko Ini'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Jurnal Kunjungan'), findsOneWidget);
      expect(find.text('HASIL KUNJUNGAN (1/3)'), findsOneWidget);

      // Klik Lanjut ke Catatan & Bukti
      await tester.ensureVisible(find.text('Lanjut ke Catatan & Bukti'));
      await tester.tap(find.text('Lanjut ke Catatan & Bukti'));
      await tester.pumpAndSettle();

      // Ambil foto nota PO (wajib jika Ada Order)
      await tester.ensureVisible(find.text('Wajib: Ambil / Unggah Foto Nota PO'));
      await tester.tap(find.text('Wajib: Ambil / Unggah Foto Nota PO'));
      await tester.pumpAndSettle();

      // Simpan Jurnal Kunjungan Final
      await tester.ensureVisible(find.text('Simpan Jurnal Kunjungan'));
      await tester.tap(find.text('Simpan Jurnal Kunjungan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Kembali ke daftar rute kunjungan
      expect(find.text('Progress Rute Kunjungan'), findsOneWidget);
    });

    testWidgets('Sales Reschedule: buat pengajuan reschedule baru', (tester) async {
      await loginAsSales(tester);

      // Pindah ke tab Reschedule
      await tester.tap(find.text('Reschedule'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Daftar Pengajuan Reschedule'), findsOneWidget);

      // Klik + Pengajuan Baru
      await tester.tap(find.text('+ Pengajuan Baru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Buat Pengajuan Reschedule'), findsOneWidget);

      // Masukkan alasan
      await tester.enterText(
        find.byType(TextFormField).last,
        'Pemilik toko sedang di luar kota hingga lusa.',
      );
      await tester.pumpAndSettle();

      // Klik Ajukan Reschedule
      await tester.ensureVisible(find.text('Ajukan Reschedule'));
      await tester.tap(find.text('Ajukan Reschedule'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Kembali ke daftar pengajuan
      expect(find.text('Daftar Pengajuan Reschedule'), findsOneWidget);
      expect(find.textContaining('Pemilik toko sedang di luar kota hingga lusa.'), findsOneWidget);
    });

    testWidgets('Sales Kondite Saya: tampilkan lembar 18 kriteria read-only', (tester) async {
      await loginAsSales(tester);

      // Pindah ke tab Kondite
      await tester.tap(find.text('Kondite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Lembar Kondite Sales'), findsOneWidget);
      expect(find.text('NILAI KONDITE BULAN INI'), findsOneWidget);
      expect(find.text('Rincian 18 Kriteria Penilaian'), findsOneWidget);

      final catatanFinder = find.text(
        'Tidak ada tombol ubah di layar ini. Form kondite dinilai berkala oleh Manajer Sales.',
      );
      await tester.scrollUntilVisible(catatanFinder, 300);
      expect(catatanFinder, findsOneWidget);
    });
  });

  group('Tahap 5 - Manajer Sales (Beranda, Approval, Kondite 18 Kriteria, Cetak PDF, Laporan)', () {
    Future<void> loginAsManajer(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: SeuiCentreApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manajer Sales'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Langsung masuk ke Beranda'), findsOneWidget);
      await tester.tap(find.text('Langsung masuk ke Beranda'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
    }

    testWidgets('Manajer Beranda: metrik ringkasan & beralih ke Mode Sales', (tester) async {
      await loginAsManajer(tester);

      expect(find.text('Monitoring Sales'), findsOneWidget);
      expect(find.text('Kunjungan'), findsOneWidget);
      expect(find.text('Order'), findsOneWidget);
      expect(find.text('Reschedule'), findsAtLeastNWidgets(1));
      expect(find.text('Mode Sales'), findsOneWidget);

      // Beralih ke Mode Sales tanpa login ulang
      await tester.tap(find.text('Mode Sales'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Sekarang berada di layar Mapping Sales
      expect(find.text('Mapping hari ini'), findsOneWidget);
    });

    testWidgets('Manajer Approval Reschedule: setujui pengajuan reschedule sales', (tester) async {
      await loginAsManajer(tester);

      // Pindah ke tab Reschedule di bottom nav
      await tester.tap(find.byIcon(Icons.approval_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Approval Reschedule Kunjungan'), findsOneWidget);
      expect(find.text('Menunggu Persetujuan'), findsOneWidget);

      // Bila ada tombol Setujui, lakukan persetujuan
      final setujuiFinder = find.widgetWithText(ElevatedButton, 'Setujui');
      if (setujuiFinder.evaluate().isNotEmpty) {
        await tester.tap(setujuiFinder.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();

        expect(find.text('Reschedule disetujui. Jadwal sales diperbarui.'), findsOneWidget);
      }
    });

    testWidgets('Manajer Penilaian Kondite: form 18 kriteria & hitung nilai akhir dinamis', (tester) async {
      await loginAsManajer(tester);

      // Pindah ke tab Kondite
      await tester.tap(find.text('Kondite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      expect(find.text('Penilaian Kondite Sales'), findsOneWidget);
      expect(find.text('Form Penilaian 18 Kriteria'), findsOneWidget);

      // Tombol Simpan Penilaian Kondite
      final simpanFinder = find.text('Simpan Penilaian Kondite');
      await tester.ensureVisible(simpanFinder);
      expect(simpanFinder, findsOneWidget);

      await tester.tap(simpanFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Penilaian kondite berhasil disimpan.'), findsOneWidget);
    });

    testWidgets('Manajer Cetak Lembar Kondite: lihat pratinjau dokumen & tanda tangan digital', (tester) async {
      await loginAsManajer(tester);

      await tester.tap(find.text('Kondite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Tombol Cetak Lembar Kondite (PDF)
      final cetakPdfFinder = find.text('Cetak Lembar Kondite (PDF)');
      await tester.ensureVisible(cetakPdfFinder);
      expect(cetakPdfFinder, findsOneWidget);

      await tester.tap(cetakPdfFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Lembar Cetak Kondite'), findsOneWidget);
      expect(find.text('PT. S.E.U.I CENTRE PURWOKERTO'), findsOneWidget);
      expect(find.text('LEMBAR PENILAIAN KONDITE SALES'), findsOneWidget);
      expect(find.text('✓ TTD DIGITAL VALID'), findsOneWidget);
      expect(find.text('( Maya Kusuma )'), findsOneWidget);
      expect(find.text('Cetak Dokumen'), findsOneWidget);
      expect(find.text('Simpan PDF'), findsOneWidget);
    });

    testWidgets('Manajer Laporan: lihat monitoring & rekap realisasi', (tester) async {
      await loginAsManajer(tester);

      // Pindah ke tab Laporan
      await tester.tap(find.text('Laporan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Monitoring & Laporan Sales'), findsOneWidget);
      expect(find.text('KEPATUHAN JADWAL MAPPING'), findsOneWidget);
      expect(find.text('Cetak Laporan Rekap'), findsOneWidget);

      // Klik Cetak Laporan Rekap
      await tester.ensureVisible(find.text('Cetak Laporan Rekap'));
      await tester.tap(find.text('Cetak Laporan Rekap'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Hasil cetak laporan rekap'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);
    });
  });
}
