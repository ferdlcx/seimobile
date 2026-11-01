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
      await tester.pumpAndSettle();

      // Berada di layar Mapping Sales
      expect(find.text('Placeholder Sales · Menu MAPPING'), findsOneWidget);
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
      await tester.pumpAndSettle();

      expect(find.text('Placeholder Manajer Sales · Menu BERANDA'), findsOneWidget);
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
}
