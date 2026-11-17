import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:seui_centre/core/config/app_config.dart';
import 'package:seui_centre/core/database/seui_sqlite_database.dart';
import 'package:seui_centre/features/admin_akun/data/sqlite_akun_repository.dart';
import 'package:seui_centre/features/admin_data/data/sqlite_master_repository.dart';
import 'package:seui_centre/features/auth/data/sqlite_auth_repository.dart';
import 'package:seui_centre/features/kondite/data/sqlite_kondite_repository.dart';
import 'package:seui_centre/features/kunjungan/data/models/jurnal_kunjungan_model.dart';
import 'package:seui_centre/features/kunjungan/data/sqlite_jurnal_repository.dart';
import 'package:seui_centre/features/laporan/data/sqlite_laporan_repository.dart';
import 'package:seui_centre/features/mapping/data/sqlite_mapping_repository.dart';
import 'package:seui_centre/features/monitoring/data/sqlite_monitoring_repository.dart';
import 'package:seui_centre/features/reschedule/data/sqlite_reschedule_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('Database SQLite persisten menyimpan & membaca seluruh modul lintas sesi', () async {
    final tempDir = await Directory.systemTemp.createTemp('seui_sqlite_test_');
    final dbFilePath = p.join(tempDir.path, 'seui_test.db');

    try {
      // Sesi 1: Buat data baru dan mutasi di seluruh modul
      final db1 = SeuiSqliteDatabase(
        getConfig: () => AppConfig(),
        factoryOverride: databaseFactoryFfiNoIsolate,
        dbPathOverride: dbFilePath,
      );

      final auth1 = SqliteAuthRepository(db1);
      final akun1 = SqliteAkunRepository(db1);
      final master1 = SqliteMasterRepository(db1);
      final mapping1 = SqliteMappingRepository(db1);
      final jurnal1 = SqliteJurnalRepository(db1);
      final resched1 = SqliteRescheduleRepository(db1);
      final kondite1 = SqliteKonditeRepository(db1);
      final monitoring1 = SqliteMonitoringRepository(db1);
      final laporan1 = SqliteLaporanRepository(db1);

      // Login Manajer & simpan tanda tangan digital ke SQLite
      final manajerSession = await auth1.login(
        username: 'maya.kusuma',
        password: 'password123',
        role: 'manajer_sales',
      );
      expect(manajerSession.mode, equals('manajer'));
      await auth1.simpanTandaTangan('ttd-maya-valid');
      await auth1.logout();

      // Verifikasi seed awal (4/6 toko dikunjungi)
      final hariIniAwal = await mapping1.hariIni();
      expect(hariIniAwal.totalTarget, equals(6));
      expect(hariIniAwal.sudahDikunjungi, equals(4));

      // Admin buat akun baru dengan password kustom
      final akunBaru = await akun1.create(
        nama: 'Rudi Hartono',
        username: 'rudi.sales',
        password: 'rahasia999',
        role: 'sales',
        aktif: true,
      );
      expect(akunBaru.isBaru, isTrue);

      // Tambah toko baru JO-0999
      final tokoBaru = await master1.tokoCreate(
        noJo: 'JO-0999',
        nama: 'Toko Sinar Baru',
        wilayahId: 1,
        alamat: 'Jl. Pahlawan No. 9',
      );
      expect(tokoBaru.noJo, equals('JO-0999'));

      // Simpan jurnal final untuk toko JO-0501
      await jurnal1.create(
        noJo: 'JO-0501',
        hasil: HasilKunjungan.adaOrder,
        catatan: 'Order baru via SQLite',
        fotoDisplay: 'disp.jpg',
        fotoNotaPo: 'nota.jpg',
        lat: -7.4562,
        lng: 109.2865,
        jarakM: 12.0,
      );

      // Buat & setujui reschedule
      final rBaru = await resched1.create(
        noJo: 'JO-0375',
        jadwalBaru: DateTime(2026, 11, 10),
        alasan: 'Toko renovasi',
      );
      final rApproved = await resched1.setujui(rBaru.id);
      expect(rApproved.status, equals('disetujui'));

      // Simpan nilai kondite baru (semua B -> 100.0 BAIK)
      final detailAllB = <int, String>{for (int i = 1; i <= 18; i++) i: 'B'};
      final kSaved = await kondite1.save(
        salesId: 2,
        periode: '2026-10',
        detail: detailAllB,
      );
      expect(kSaved.nilaiAkhir, equals(100.0));
      expect(kSaved.label, equals('BAIK'));

      // Verifikasi monitoring & laporan terbaca konsisten
      final mon = await monitoring1.harian();
      expect(mon.rescheduleMenunggu, equals(2));
      final lap = await laporan1.rekap(periode: '2026-10');
      expect(lap.totalTarget, equals(7));

      // Tutup database sesi 1 (simulasi aplikasi ditutup)
      await db1.close();

      // Sesi 2: Buka kembali file database SQLite yang sama
      final db2 = SeuiSqliteDatabase(
        getConfig: () => AppConfig(),
        factoryOverride: databaseFactoryFfiNoIsolate,
        dbPathOverride: dbFilePath,
      );
      final auth2 = SqliteAuthRepository(db2);
      final master2 = SqliteMasterRepository(db2);
      final mapping2 = SqliteMappingRepository(db2);
      final kondite2 = SqliteKonditeRepository(db2);

      // Login memakai akun yang baru dibuat di sesi 1 dengan password kustomnya!
      final loginSession = await auth2.login(
        username: 'rudi.sales',
        password: 'rahasia999',
        role: 'sales',
      );
      expect(loginSession.user.nama, equals('Rudi Hartono'));

      // Verifikasi toko JO-0999, kunjungan JO-0501, dan kondite 100.0 tetap tersimpan
      final tokoList2 = await master2.tokoList();
      expect(tokoList2.any((t) => t.noJo == 'JO-0999'), isTrue);

      final hariIni2 = await mapping2.hariIni();
      expect(hariIni2.totalTarget, equals(7));
      expect(hariIni2.sudahDikunjungi, equals(5));

      final kLoaded = await kondite2.get(salesId: 2, periode: '2026-10');
      expect(kLoaded.nilaiAkhir, equals(100.0));

      await db2.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
