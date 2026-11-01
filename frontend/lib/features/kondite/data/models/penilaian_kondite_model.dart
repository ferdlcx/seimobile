/// Model penilaian kondite bulanan per sales (18 kriteria dengan nilai B/C/K/SK).
class PenilaianKondite {
  final int salesId;
  final String salesNama;
  final String periode; // mis. '2026-10'
  final Map<int, String> detail; // Map<kriteriaId, 'B'|'C'|'K'|'SK'>
  final double nilaiAkhir;
  final String label;

  const PenilaianKondite({
    required this.salesId,
    this.salesNama = 'Budi Santoso',
    required this.periode,
    required this.detail,
    required this.nilaiAkhir,
    required this.label,
  });

  PenilaianKondite copyWith({
    int? salesId,
    String? salesNama,
    String? periode,
    Map<int, String>? detail,
    double? nilaiAkhir,
    String? label,
  }) {
    return PenilaianKondite(
      salesId: salesId ?? this.salesId,
      salesNama: salesNama ?? this.salesNama,
      periode: periode ?? this.periode,
      detail: detail ?? Map<int, String>.from(this.detail),
      nilaiAkhir: nilaiAkhir ?? this.nilaiAkhir,
      label: label ?? this.label,
    );
  }

  factory PenilaianKondite.fromJson(Map<String, dynamic> json) {
    final rawDetail = json['detail'] as Map<String, dynamic>? ?? {};
    final parsedDetail = <int, String>{};
    rawDetail.forEach((key, value) {
      final k = int.tryParse(key);
      if (k != null) {
        parsedDetail[k] = value as String;
      }
    });

    return PenilaianKondite(
      salesId: (json['id_sales'] ?? json['sales_id']) as int,
      salesNama: json['sales_nama'] as String? ?? 'Budi Santoso',
      periode: (json['periode_bulan'] ?? json['periode']) as String,
      detail: parsedDetail,
      nilaiAkhir: ((json['nilai_akhir'] as num?) ?? 0.0).toDouble(),
      label: json['label'] as String? ?? 'BAIK',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_id': salesId,
      'sales_nama': salesNama,
      'periode': periode,
      'detail': detail.map((k, v) => MapEntry(k.toString(), v)),
      'nilai_akhir': nilaiAkhir,
      'label': label,
    };
  }
}
