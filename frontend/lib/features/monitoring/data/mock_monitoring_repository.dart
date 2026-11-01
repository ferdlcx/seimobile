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
        peringatanList.add(
          '${t.nama} belum dikunjungi ${t.hariSejakKunjunganTerakhir} hari.',
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

    final kepatuhan = NilaiKonditeUtils.hitungKepatuhanPersen(
      terealisasi: totalKunjunganTim,
      target: totalTargetTim,
    );

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
