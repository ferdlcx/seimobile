/// Logika perhitungan nilai akhir kondite, label kondite, dan kepatuhan mapping.
class NilaiKonditeUtils {
  /// Menghitung nilai akhir kondite (rata-rata bobot dari kriteria, dibulatkan 1 desimal).
  static double hitungNilaiAkhir(
    Map<int, String> detail,
    Map<String, int> bobotNilai,
  ) {
    if (detail.isEmpty) return 0.0;
    int total = 0;
    for (final kode in detail.values) {
      total += bobotNilai[kode] ?? 0;
    }
    final rata = total / detail.length;
    return double.parse(rata.toStringAsFixed(1));
  }

  /// Menentukan label kondite berdasarkan nilai akhir:
  /// >= 85: BAIK, >= 70: CUKUP, >= 50: KURANG, selain itu: SANGAT KURANG.
  static String tentukanLabel(double nilaiAkhir) {
    if (nilaiAkhir >= 85.0) return 'BAIK';
    if (nilaiAkhir >= 70.0) return 'CUKUP';
    if (nilaiAkhir >= 50.0) return 'KURANG';
    return 'SANGAT KURANG';
  }

  /// Menghitung persentase kepatuhan mapping:
  /// toko terealisasi bulan ini / target toko bulan ini (0 bila target 0).
  static int hitungKepatuhanPersen({
    required int terealisasi,
    required int target,
  }) {
    if (target <= 0) return 0;
    return ((terealisasi / target) * 100).round();
  }
}
