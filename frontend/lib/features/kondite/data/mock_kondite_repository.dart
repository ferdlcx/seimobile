import '../../../core/mock/mock_database.dart';
import '../../../core/utils/nilai_kondite.dart';
import 'kondite_repository.dart';
import 'models/penilaian_kondite_model.dart';

/// Implementasi Mock untuk KonditeRepository.
class MockKonditeRepository implements KonditeRepository {
  final MockDatabase db;

  MockKonditeRepository(this.db);

  @override
  Future<PenilaianKondite> get({
    required int salesId,
    required String periode,
  }) async {
    await db.simulateNetworkDelay();
    final key = '$salesId-$periode';
    final existing = db.konditeMap[key];
    if (existing != null) return existing;

    final salesNama = db.akunList
        .firstWhere(
          (a) => a.id == salesId,
          orElse: () => db.akunList.firstWhere((a) => a.role == 'sales'),
        )
        .nama;

    final defaultDetail = <int, String>{
      for (int i = 1; i <= 18; i++) i: (i % 3 == 0 ? 'C' : 'B'),
    };
    final config = db.getConfig();
    final nilaiAkhir = NilaiKonditeUtils.hitungNilaiAkhir(
      defaultDetail,
      config.bobotNilai,
    );
    final label = NilaiKonditeUtils.tentukanLabel(nilaiAkhir);

    final baru = PenilaianKondite(
      salesId: salesId,
      salesNama: salesNama,
      periode: periode,
      detail: defaultDetail,
      nilaiAkhir: nilaiAkhir,
      label: label,
    );
    db.konditeMap[key] = baru;
    return baru;
  }

  @override
  Future<PenilaianKondite> save({
    required int salesId,
    required String periode,
    required Map<int, String> detail,
  }) async {
    await db.simulateNetworkDelay();
    final config = db.getConfig();
    final nilaiAkhir = NilaiKonditeUtils.hitungNilaiAkhir(
      detail,
      config.bobotNilai,
    );
    final label = NilaiKonditeUtils.tentukanLabel(nilaiAkhir);

    final salesNama = db.akunList
        .firstWhere(
          (a) => a.id == salesId,
          orElse: () => db.akunList.firstWhere((a) => a.role == 'sales'),
        )
        .nama;

    final saved = PenilaianKondite(
      salesId: salesId,
      salesNama: salesNama,
      periode: periode,
      detail: Map<int, String>.from(detail),
      nilaiAkhir: nilaiAkhir,
      label: label,
    );
    db.konditeMap['$salesId-$periode'] = saved;
    return saved;
  }

  @override
  Future<PenilaianKondite> saya() async {
    // Di layar Kondite Saya (Sales), ambil kondite Budi Santoso (salesId = 2)
    return get(salesId: 2, periode: '2026-10');
  }
}
