import '../../../admin_data/data/models/master_models.dart';

/// Model mapping tahunan toko per sales (matriks toko × 12 bulan JAN–DES).
class MappingToko {
  final int idMapping;
  final int idSales;
  final int tahun;
  final Toko toko;

  /// Rencana jadwal kunjungan 12 bulan (indeks 0 = JAN .. 11 = DES).
  final List<bool> bulan;

  /// Status terealisasi 12 bulan (indeks 0 = JAN .. 11 = DES).
  final List<bool> terealisasi;

  const MappingToko({
    required this.idMapping,
    required this.idSales,
    required this.tahun,
    required this.toko,
    required this.bulan,
    List<bool>? terealisasi,
  }) : terealisasi = terealisasi ??
            const [
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
              false,
            ];

  MappingToko copyWith({
    int? idMapping,
    int? idSales,
    int? tahun,
    Toko? toko,
    List<bool>? bulan,
    List<bool>? terealisasi,
  }) {
    return MappingToko(
      idMapping: idMapping ?? this.idMapping,
      idSales: idSales ?? this.idSales,
      tahun: tahun ?? this.tahun,
      toko: toko ?? this.toko,
      bulan: bulan ?? List<bool>.from(this.bulan),
      terealisasi: terealisasi ?? List<bool>.from(this.terealisasi),
    );
  }

  factory MappingToko.fromJson(Map<String, dynamic> json) {
    final rawBulan = (json['bulan'] as List<dynamic>?)
            ?.map((e) => e as bool)
            .toList() ??
        List<bool>.filled(12, false);
    final rawReal = (json['terealisasi'] as List<dynamic>?)
            ?.map((e) => e as bool)
            .toList() ??
        List<bool>.filled(12, false);
    return MappingToko(
      idMapping: json['id_mapping'] as int,
      idSales: json['id_sales'] as int,
      tahun: json['tahun'] as int,
      toko: Toko.fromJson(json['toko'] as Map<String, dynamic>),
      bulan: rawBulan,
      terealisasi: rawReal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mapping': idMapping,
      'id_sales': idSales,
      'tahun': tahun,
      'toko': toko.toJson(),
      'bulan': bulan,
      'terealisasi': terealisasi,
    };
  }
}
