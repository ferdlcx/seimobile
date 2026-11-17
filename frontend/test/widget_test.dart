import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

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

      expect(find.text('Beranda & monitoring'), findsOneWidget);
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

      // Isi form tambah akun (Nama, Username, Password)
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Rudi Hartono');
      await tester.enterText(fields.at(1), 'rudi.hartono');
      await tester.enterText(fields.at(2), 'password123');
      await tester.pumpAndSettle();

      // Simpan Akun
      await tester.ensureVisible(find.text('Simpan Akun'));
      await tester.tap(find.text('Simpan Akun'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Kembali ke layar akun dan ada judul & banner sukses serta badge BARU
      expect(find.text('Akun berhasil ditambahkan'), findsOneWidget);
      expect(
        find.text('Notifikasi dikirim: akun baru sudah muncul dengan label BARU.'),
        findsOneWidget,
      );
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

      // Isi form tambah toko (Nama Toko, No JO, Alamat)
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Toko Maju Bersama');
      await tester.enterText(fields.at(1), 'JO-0610');
      await tester.enterText(fields.at(2), 'Jl. Merdeka No. 10, Purwokerto');
      await tester.pumpAndSettle();

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

    testWidgets('Admin Mapping: lihat grid GitHub 12 bulan dan simpan mapping', (tester) async {
      await loginAsAdmin(tester);

      // Pindah ke tab Mapping
      await tester.tap(find.text('Mapping'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Susun mapping toko'), findsOneWidget);
      expect(find.text('TOKO'), findsOneWidget);
      expect(find.text('JAN'), findsOneWidget);
      expect(find.text('DES'), findsOneWidget);

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
      expect(find.text('S.E.U.I CENTRE · LAPORAN REKAP'), findsOneWidget);
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
      expect(find.text('Progress rute hari ini'), findsOneWidget);
    });

    testWidgets('Sales Kunjungan: list toko, detail toko & simulasi radius GPS', (tester) async {
      await loginAsSales(tester);

      // Pindah ke tab Kunjungan
      await tester.tap(find.text('Kunjungan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Progress rute hari ini'), findsOneWidget);
      expect(find.text('Toko Makmur Jaya'), findsOneWidget);

      // Tap Toko Makmur Jaya untuk masuk ke Detail
      await tester.tap(find.text('Toko Makmur Jaya'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('LOKASI GPS'), findsOneWidget);
      expect(
        find.text('Anda berada di dalam radius check-in.'),
        findsOneWidget,
      );

      // Toggle simulasi ke luar radius melalui ikon lokasi
      await tester.tap(find.byKey(const Key('gps_sim_toggle')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Di luar radius check-in'), findsOneWidget);

      // Kembalikan ke simulasi dekat
      await tester.tap(find.byKey(const Key('gps_sim_toggle')));
      await tester.pumpAndSettle();
      expect(
        find.text('Anda berada di dalam radius check-in.'),
        findsOneWidget,
      );
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

      expect(find.text('HASIL KUNJUNGAN 1/3'), findsOneWidget);

      // Klik Lanjut ke Order & Bukti
      await tester.ensureVisible(find.text('Lanjut'));
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('ORDER & BUKTI 3/3'), findsOneWidget);

      // Ambil foto nota PO (wajib jika Ada Order)
      await tester.ensureVisible(find.text('Foto nota PO'));
      await tester.tap(find.text('Foto nota PO'));
      await tester.pumpAndSettle();

      // Simpan Jurnal Kunjungan Final
      await tester.ensureVisible(find.text('Simpan Jurnal Kunjungan'));
      await tester.tap(find.text('Simpan Jurnal Kunjungan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Kembali ke daftar rute kunjungan
      expect(find.text('Progress rute hari ini'), findsOneWidget);
    });

    testWidgets('Sales Reschedule: buat pengajuan reschedule baru', (tester) async {
      await loginAsSales(tester);

      // Pindah ke tab Reschedule
      await tester.tap(find.text('Reschedule'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(
        find.text('Jadwal berubah, toko tidak bisa dikunjungi sesuai mapping.'),
        findsOneWidget,
      );

      // Klik "+ Buat Pengajuan Reschedule Baru"
      await tester.tap(find.text('+ Buat Pengajuan Reschedule Baru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Pengajuan Reschedule Baru'), findsOneWidget);

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

      // Kembali ke daftar pengajuan (2 menunggu awal + 1 baru = 3 Menunggu)
      expect(
        find.text('Jadwal berubah, toko tidak bisa dikunjungi sesuai mapping.'),
        findsOneWidget,
      );
      expect(find.text('Menunggu'), findsNWidgets(3));
    });

    testWidgets('Sales Kondite Saya: tampilkan lembar 18 kriteria read-only', (tester) async {
      await loginAsSales(tester);

      // Pindah ke tab Kondite
      await tester.tap(find.text('Kondite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Kondite saya'), findsOneWidget);
      expect(find.text('NILAI BULAN INI · OKT 2026'), findsOneWidget);
      expect(find.text('18 KRITERIA (6 TERATAS)'), findsOneWidget);

      final catatanFinder = find.text('Tidak ada tombol ubah di layar ini.');
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

      expect(find.text('Beranda & monitoring'), findsOneWidget);
      expect(find.text('Kunjungan'), findsOneWidget);
      expect(find.text('Order'), findsOneWidget);
      expect(find.text('Reschedule'), findsAtLeastNWidgets(1));
      expect(find.text('REALISASI PER SALES'), findsOneWidget);
      expect(find.text('Kepatuhan mapping'), findsOneWidget);
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
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Approval reschedule'), findsOneWidget);
      expect(find.text('SUDAH DIPROSES'), findsOneWidget);

      // Setujui pengajuan menunggu pertama
      final setujuiFinder = find.widgetWithText(ElevatedButton, 'Setujui');
      if (setujuiFinder.evaluate().isNotEmpty) {
        await tester.tap(setujuiFinder.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();

        expect(
          find.text('Reschedule disetujui. Jadwal sales diperbarui.'),
          findsOneWidget,
        );
      }
    });

    testWidgets('Manajer Penilaian Kondite & Cetak Lembar Kondite', (tester) async {
      await loginAsManajer(tester);

      // Pindah ke tab Kondite
      await tester.tap(find.text('Kondite'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      expect(find.text('Nilai kondite'), findsOneWidget);
      expect(find.text('NILAI AKHIR'), findsOneWidget);
      expect(find.text('88.9'), findsOneWidget);
      expect(find.text('Andi Pratama'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);

      // Tombol Cetak Lembar Kondite (PDF)
      final cetakPdfFinder = find.text('Cetak Lembar Kondite (PDF)');
      await tester.ensureVisible(cetakPdfFinder);
      expect(cetakPdfFinder, findsOneWidget);

      await tester.tap(cetakPdfFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Hasil cetak lembar kondite'), findsOneWidget);
      expect(find.text('S.E.U.I CENTRE · LEMBAR KONDITE'), findsOneWidget);
      expect(find.text('Tanda tangan digital Manajer Sales'), findsOneWidget);
      expect(find.text('Cetak'), findsOneWidget);
      expect(find.text('Simpan PDF'), findsOneWidget);
    });

    testWidgets('Manajer Laporan: lihat monitoring & rekap realisasi', (tester) async {
      await loginAsManajer(tester);

      // Pindah ke tab Laporan
      await tester.tap(find.text('Laporan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Laporan & rekap'), findsOneWidget);
      expect(find.text('PERINGATAN HARI INI'), findsOneWidget);
      expect(find.text('Kepatuhan tutup'), findsOneWidget);
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
