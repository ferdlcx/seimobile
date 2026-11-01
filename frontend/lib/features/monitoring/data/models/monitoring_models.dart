/// Model baris rekap wilayah pada laporan rekap bulanan.
class RekapWilayah {
  final String wilayah;
  final int target;
  final int real;
  final int persen;

  const RekapWilayah({
    required this.wilayah,
    required this.target,
    required this.real,
    required this.persen,
  });

  factory RekapWilayah.fromJson(Map<String, dynamic> json) {
    return RekapWilayah(
      wilayah: json['wilayah'] as String,
      target: json['target'] as int,
      real: json['real'] as int,
      persen: json['persen'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wilayah': wilayah,
      'target': target,
      'real': real,
      'persen': persen,
    };
  }
}

/// Model progres realisasi kunjungan per sales.
class ProgresSales {
  final int salesId;
  final String salesNama;
  final int realisasi;
  final int target;

  const ProgresSales({
    required this.salesId,
    required this.salesNama,
    required this.realisasi,
    required this.target,
  });

  int get persen => target <= 0 ? 0 : ((realisasi / target) * 100).round();

  factory ProgresSales.fromJson(Map<String, dynamic> json) {
    return ProgresSales(
      salesId: json['sales_id'] as int,
      salesNama: json['sales_nama'] as String,
      realisasi: json['realisasi'] as int,
      target: json['target'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_id': salesId,
      'sales_nama': salesNama,
      'realisasi': realisasi,
      'target': target,
      'persen': persen,
    };
  }
}

/// Model ringkasan monitoring harian untuk Admin dan Manajer Sales.
class RingkasanMonitoring {
  final int kunjungan;
  final int targetKunjungan;
  final int order;
  final int rescheduleMenunggu;
  final List<String> peringatan;
  final int kepatuhanMapping;
  final List<ProgresSales> progresPerSales;

  const RingkasanMonitoring({
    required this.kunjungan,
    required this.targetKunjungan,
    required this.order,
    required this.rescheduleMenunggu,
    required this.peringatan,
    required this.kepatuhanMapping,
    required this.progresPerSales,
  });

  factory RingkasanMonitoring.fromJson(Map<String, dynamic> json) {
    final rawPeringatan = (json['peringatan'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final rawProgres = (json['progres_per_sales'] as List<dynamic>?)
            ?.map((e) => ProgresSales.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return RingkasanMonitoring(
      kunjungan: json['kunjungan'] as int,
      targetKunjungan: json['target_kunjungan'] as int,
      order: json['order'] as int,
      rescheduleMenunggu: json['reschedule_menunggu'] as int,
      peringatan: rawPeringatan,
      kepatuhanMapping: json['kepatuhan_mapping'] as int,
      progresPerSales: rawProgres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kunjungan': kunjungan,
      'target_kunjungan': targetKunjungan,
      'order': order,
      'reschedule_menunggu': rescheduleMenunggu,
      'peringatan': peringatan,
      'kepatuhan_mapping': kepatuhanMapping,
      'progres_per_sales': progresPerSales.map((e) => e.toJson()).toList(),
    };
  }
}
