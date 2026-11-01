import '../../monitoring/data/models/monitoring_models.dart';

/// Hasil laporan rekap bulanan per wilayah beserta baris total.
class LaporanRekapData {
  final String periodeLabel;
  final List<RekapWilayah> barisWilayah;
  final int totalTarget;
  final int totalReal;
  final int totalPersen;
  final DateTime waktuCetak;

  const LaporanRekapData({
    required this.periodeLabel,
    required this.barisWilayah,
    required this.totalTarget,
    required this.totalReal,
    required this.totalPersen,
    required this.waktuCetak,
  });
}

/// Kontrak repository laporan rekap sejajar dengan `/laporan/rekap`.
abstract class LaporanRepository {
  Future<LaporanRekapData> rekap({
    required String periode,
    int? wilayahId,
  });
}
