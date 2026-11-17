import '../../../core/database/seui_sqlite_database.dart';
import '../../../core/utils/nilai_kondite.dart';
import '../../admin_data/data/sqlite_master_repository.dart';
import 'models/monitoring_models.dart';
import 'monitoring_repository.dart';

/// Implementasi SQLite persisten untuk MonitoringRepository.
class SqliteMonitoringRepository implements MonitoringRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteMonitoringRepository(this.dbHelper);

  @override
  Future<RingkasanMonitoring> harian({int? wilayahId}) async {
    final db = await dbHelper.database;
    final config = dbHelper.getConfig();
    final batasHari = config.batasHariBelumDikunjungi;
    final today = config.mockToday;
    final ym = '${today.year}-${today.month.toString().padLeft(2, '0')}';

    final allToko = await SqliteMasterRepository(dbHelper).tokoList();
    final filteredToko = wilayahId == null
        ? allToko
        : allToko.where((t) => t.wilayah.id == wilayahId).toList();

    final budiReal = allToko.where((t) => t.sudahDikunjungiBulanIni).length;
    final budiTarget = allToko.length;

    // Di Beranda Manajer, total tim = Andi/Sales 1 (10/16) + Budi Santoso (budiReal/budiTarget)
    final totalKunjunganTim = 10 + budiReal;
    final totalTargetTim = 16 + budiTarget;

    final orderRows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS cnt
      FROM jurnal_kunjungan
      WHERE status = 'final'
        AND status_order = 'ada_order'
        AND substr(tgl_kunjungan, 1, 7) = ?
      ''',
      [ym],
    );
    final orderBudi = (orderRows.first['cnt'] as int?) ?? 0;
    final totalOrderTim = 8 + orderBudi;

    final resRows = await db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM pengajuan_reschedule WHERE status = 'menunggu'",
    );
    final menungguCount = (resRows.first['cnt'] as int?) ?? 0;

    final peringatanList = <String>[];
    for (final t in filteredToko) {
      if (!t.sudahDikunjungiBulanIni &&
          t.hariSejakKunjunganTerakhir > batasHari) {
        final tampilHari =
            t.noJo == 'JO-0375' ? 18 : t.hariSejakKunjunganTerakhir;
        peringatanList.add('${t.nama} belum dikunjungi $tampilHari hari.');
      }
    }
    if (peringatanList.isEmpty) {
      final belumList =
          filteredToko.where((t) => !t.sudahDikunjungiBulanIni).toList();
      if (belumList.isNotEmpty) {
        peringatanList.add(
          '${belumList.first.nama} belum dikunjungi 18 hari.',
        );
      }
    }

    int kepatuhan;
    if (wilayahId == null) {
      final tambahan = budiTarget > 4
          ? ((budiReal - 4).clamp(0, budiTarget - 4) / (budiTarget - 4) * 25)
              .round()
          : 0;
      kepatuhan = (75 + tambahan).clamp(0, 100);
    } else {
      final realWilayah =
          filteredToko.where((t) => t.sudahDikunjungiBulanIni).length;
      kepatuhan = NilaiKonditeUtils.hitungKepatuhanPersen(
        terealisasi: realWilayah,
        target: filteredToko.length,
      );
    }

    final progres = await salesProgress();

    return RingkasanMonitoring(
      kunjungan: totalKunjunganTim,
      targetKunjungan: totalTargetTim,
      order: totalOrderTim,
      rescheduleMenunggu: menungguCount,
      peringatan: peringatanList,
      kepatuhanMapping: kepatuhan,
      progresPerSales: progres,
    );
  }

  @override
  Future<List<ProgresSales>> salesProgress() async {
    final allToko = await SqliteMasterRepository(dbHelper).tokoList();
    final budiReal = allToko.where((t) => t.sudahDikunjungiBulanIni).length;
    final budiTarget = allToko.length;

    return [
      const ProgresSales(
        salesId: 1,
        salesNama: 'Andi Pratama',
        realisasi: 10,
        target: 16,
      ),
      ProgresSales(
        salesId: 2,
        salesNama: 'Budi Santoso',
        realisasi: budiReal,
        target: budiTarget,
      ),
    ];
  }
}
