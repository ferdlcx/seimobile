import '../../../core/database/seui_sqlite_database.dart';
import '../../../core/utils/nilai_kondite.dart';
import '../../admin_data/data/sqlite_master_repository.dart';
import '../../monitoring/data/models/monitoring_models.dart';
import 'laporan_repository.dart';

/// Implementasi SQLite persisten untuk LaporanRepository.
class SqliteLaporanRepository implements LaporanRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteLaporanRepository(this.dbHelper);

  @override
  Future<LaporanRekapData> rekap({
    required String periode,
    int? wilayahId,
  }) async {
    final masterRepo = SqliteMasterRepository(dbHelper);
    final allWilayah = await masterRepo.wilayah();
    final wilayahToProcess = wilayahId == null
        ? allWilayah
        : allWilayah.where((w) => w.id == wilayahId).toList();

    final allToko = await masterRepo.tokoList();

    final baris = <RekapWilayah>[];
    int sumTarget = 0;
    int sumReal = 0;

    for (final w in wilayahToProcess) {
      final tokoWilayah =
          allToko.where((t) => t.wilayah.id == w.id).toList();
      final target = tokoWilayah.length;
      final real =
          tokoWilayah.where((t) => t.sudahDikunjungiBulanIni).length;
      final persen = NilaiKonditeUtils.hitungKepatuhanPersen(
        terealisasi: real,
        target: target,
      );
      sumTarget += target;
      sumReal += real;
      baris.add(
        RekapWilayah(
          wilayah: w.nama,
          target: target,
          real: real,
          persen: persen,
        ),
      );
    }

    final totalPersen = NilaiKonditeUtils.hitungKepatuhanPersen(
      terealisasi: sumReal,
      target: sumTarget,
    );

    return LaporanRekapData(
      periodeLabel: 'Oktober 2026',
      barisWilayah: baris,
      totalTarget: sumTarget,
      totalReal: sumReal,
      totalPersen: totalPersen,
      waktuCetak: DateTime(2026, 10, 30, 15, 57),
    );
  }
}
