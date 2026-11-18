import '../../../core/mock/mock_database.dart';
import '../../mapping/data/models/mapping_toko_model.dart';
import 'master_repository.dart';
import 'models/master_models.dart';

/// Implementasi Mock untuk MasterRepository.
class MockMasterRepository implements MasterRepository {
  final MockDatabase db;

  MockMasterRepository(this.db);

  @override
  Future<List<Wilayah>> wilayah() async {
    await db.simulateNetworkDelay();
    return List<Wilayah>.from(db.wilayahList);
  }

  @override
  Future<Wilayah> wilayahCreate({required String nama}) async {
    await db.simulateNetworkDelay();
    final trimmed = nama.trim();
    if (trimmed.isEmpty) {
      throw Exception('Nama wilayah wajib diisi.');
    }
    final exists = db.wilayahList.any(
      (w) => w.nama.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      throw Exception('Wilayah "$trimmed" sudah terdaftar.');
    }
    final nextId = db.wilayahList.isEmpty
        ? 1
        : db.wilayahList.map((w) => w.id).reduce((a, b) => a > b ? a : b) + 1;
    final baru = Wilayah(id: nextId, nama: trimmed);
    db.wilayahList = [...db.wilayahList, baru];
    return baru;
  }

  @override
  Future<List<Toko>> tokoList({int? wilayahId, String? q}) async {
    await db.simulateNetworkDelay();
    return db.tokoList.where((t) {
      if (wilayahId != null && t.wilayah.id != wilayahId) return false;
      if (q != null && q.trim().isNotEmpty) {
        final query = q.trim().toLowerCase();
        final matchNama = t.nama.toLowerCase().contains(query);
        final matchJo = t.noJo.toLowerCase().contains(query);
        if (!matchNama && !matchJo) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Toko> tokoCreate({
    required String noJo,
    required String nama,
    required int wilayahId,
    required String alamat,
    String ket = '',
    double? lat,
    double? lng,
  }) async {
    await db.simulateNetworkDelay();
    final exists = db.tokoList.any(
      (t) => t.noJo.toUpperCase() == noJo.trim().toUpperCase(),
    );
    if (exists) {
      throw Exception('Nomor JO "${noJo.trim()}" sudah terdaftar.');
    }

    final wilayah = db.wilayahList.firstWhere(
      (w) => w.id == wilayahId,
      orElse: () => db.wilayahList.first,
    );

    final baru = Toko(
      noJo: noJo.trim().toUpperCase(),
      nama: nama.trim(),
      alamat: alamat.trim(),
      ket: ket.trim(),
      wilayah: wilayah,
      lat: lat ?? -7.4250,
      lng: lng ?? 109.2350,
      sudahDikunjungiBulanIni: false,
      hariSejakKunjunganTerakhir: 0,
    );

    db.tokoList = [...db.tokoList, baru];

    // Tambahkan juga baris default ke mapping seluruh sales aktif agar langsung muncul.
    final activeSalesIds = db.akunList
        .where((u) => u.role == 'sales' && u.aktif)
        .map((u) => u.id)
        .toList();
    final targetSalesIds = activeSalesIds.isEmpty ? <int>[2] : activeSalesIds;

    var nextMapId = db.mappingList.isEmpty
        ? 1
        : db.mappingList
                .map((e) => e.idMapping)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final newMappings = <MappingToko>[];
    for (final sid in targetSalesIds) {
      newMappings.add(
        MappingToko(
          idMapping: nextMapId++,
          idSales: sid,
          tahun: db.getConfig().mockToday.year,
          toko: baru,
          bulan: List<bool>.filled(12, true),
          terealisasi: List<bool>.filled(12, false),
        ),
      );
    }
    db.mappingList = [...db.mappingList, ...newMappings];

    return baru;
  }

  @override
  Future<List<Kriteria>> kriteria() async {
    await db.simulateNetworkDelay();
    return List<Kriteria>.from(db.kriteriaList);
  }

  @override
  Future<Kriteria> updateKriteria(
    int id, {
    required String nama,
    bool? aktif,
  }) async {
    await db.simulateNetworkDelay();
    late Kriteria updated;
    db.kriteriaList = db.kriteriaList.map((k) {
      if (k.id == id) {
        updated = k.copyWith(nama: nama, aktif: aktif);
        return updated;
      }
      return k;
    }).toList();
    return updated;
  }
}
