import '../../../core/mock/mock_database.dart';
import 'mapping_repository.dart';
import 'models/mapping_toko_model.dart';

/// Implementasi Mock untuk MappingRepository.
class MockMappingRepository implements MappingRepository {
  final MockDatabase db;

  MockMappingRepository(this.db);

  @override
  Future<List<MappingToko>> get({
    required int salesId,
    required int tahun,
    int? wilayahId,
  }) async {
    await db.simulateNetworkDelay();
    // Bila salesId belum punya baris di mappingList, buatkan dari tokoList
    final existingForSales = db.mappingList
        .where((m) => m.idSales == salesId && m.tahun == tahun)
        .toList();

    if (existingForSales.isEmpty) {
      int nextId = db.mappingList.isEmpty
          ? 1
          : db.mappingList
                  .map((e) => e.idMapping)
                  .reduce((a, b) => a > b ? a : b) +
              1;
      for (final t in db.tokoList) {
        db.mappingList.add(
          MappingToko(
            idMapping: nextId++,
            idSales: salesId,
            tahun: tahun,
            toko: t,
            bulan: List<bool>.filled(12, true),
            terealisasi: List<bool>.generate(
              12,
              (m) => m == 9 ? t.sudahDikunjungiBulanIni : m < 9,
            ),
          ),
        );
      }
    }

    return db.mappingList.where((m) {
      if (m.idSales != salesId || m.tahun != tahun) return false;
      if (wilayahId != null && m.toko.wilayah.id != wilayahId) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> save(List<MappingToko> items) async {
    await db.simulateNetworkDelay();
    for (final updated in items) {
      final index = db.mappingList.indexWhere(
        (m) => m.idMapping == updated.idMapping,
      );
      if (index != -1) {
        db.mappingList[index] = updated;
      } else {
        db.mappingList.add(updated);
      }
    }
  }

  @override
  Future<MappingHariIniData> hariIni({int? wilayahId}) async {
    await db.simulateNetworkDelay();
    final currentMonthIdx = (db.getConfig().mockToday.month - 1).clamp(0, 11);

    // Ambil toko yang direncanakan pada bulan berjalan untuk sales aktif (default Budi = 2)
    final plannedMappings = db.mappingList.where((m) {
      if (m.idSales != 2) return false;
      return m.bulan[currentMonthIdx];
    }).toList();

    final allPlannedToko = plannedMappings.map((m) {
      final latestToko = db.tokoList.firstWhere(
        (t) => t.noJo == m.toko.noJo,
        orElse: () => m.toko,
      );
      return latestToko;
    }).toList();

    final totalTarget = allPlannedToko.length;
    final sudahDikunjungi = allPlannedToko
        .where((t) => t.sudahDikunjungiBulanIni)
        .length;

    final filtered = wilayahId == null
        ? allPlannedToko
        : allPlannedToko.where((t) => t.wilayah.id == wilayahId).toList();

    return MappingHariIniData(
      daftarToko: filtered,
      sudahDikunjungi: sudahDikunjungi,
      totalTarget: totalTarget,
    );
  }
}
