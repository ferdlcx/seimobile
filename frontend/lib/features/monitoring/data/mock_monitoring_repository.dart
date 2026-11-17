import '../../../core/mock/mock_database.dart';
import '../../../core/utils/nilai_kondite.dart';
import '../../kunjungan/data/models/jurnal_kunjungan_model.dart';
import 'models/monitoring_models.dart';
import 'monitoring_repository.dart';

/// Implementasi Mock untuk MonitoringRepository.
class MockMonitoringRepository implements MonitoringRepository {
  final MockDatabase db;

  MockMonitoringRepository(this.db);

  @override
  Future<RingkasanMonitoring> harian({int? wilayahId}) async {
    await db.simulateNetworkDelay();
    final config = db.getConfig();
    final batasHari = config.batasHariBelumDikunjungi;

    final filteredToko = wilayahId == null
        ? db.tokoList
        : db.tokoList.where((t) => t.wilayah.id == wilayahId).toList();

    final budiReal = db.tokoList.where((t) => t.sudahDikunjungiBulanIni).length;
    final budiTarget = db.tokoList.length;

    // Di Beranda Manajer, total tim = Andi/Sales 1 (10/16) + Budi Santoso (budiReal/budiTarget)
    final totalKunjunganTim = 10 + budiReal;
    final totalTargetTim = 16 + budiTarget;

    final orderBudi = db.jurnalList
        .where((j) => j.hasil == HasilKunjungan.adaOrder)
        .length;
    final totalOrderTim = 8 + orderBudi;

    final menungguCount = db.rescheduleList
        .where((r) => r.status == 'menunggu')
        .length;

    // Peringatan toko belum dikunjungi > batasHariBelumDikunjungi
    final peringatanList = <String>[];
    for (final t in filteredToko) {
      if (!t.sudahDikunjungiBulanIni &&
          t.hariSejakKunjunganTerakhir > batasHari) {
        final tampilHari = t.noJo == 'JO-0375' ? 18 : t.hariSejakKunjunganTerakhir;
        peringatanList.add(
          '${t.nama} belum dikunjungi $tampilHari hari.',
        );
      }
    }
    if (peringatanList.isEmpty) {
      final belumList = filteredToko
          .where((t) => !t.sudahDikunjungiBulanIni)
          .toList();
      if (belumList.isNotEmpty) {
        peringatanList.add(
          '${belumList.first.nama} belum dikunjungi 18 hari.',
        );
      }
    }

    int kepatuhan;
    if (wilayahId == null) {
      // Kepatuhan mapping awal tim = 75% (meningkat saat kunjungan tambahan tercatat)
      final tambahan = budiTarget > 4
          ? ((budiReal - 4).clamp(0, budiTarget - 4) / (budiTarget - 4) * 25)
              .round()
          : 0;
      kepatuhan = (75 + tambahan).clamp(0, 100);
    } else {
      final realWilayah = filteredToko
          .where((t) => t.sudahDikunjungiBulanIni)
          .length;
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
    final budiReal = db.tokoList.where((t) => t.sudahDikunjungiBulanIni).length;
    final budiTarget = db.tokoList.length;

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
