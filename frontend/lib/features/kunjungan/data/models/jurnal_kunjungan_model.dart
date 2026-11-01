/// Hasil kunjungan sales di toko.
enum HasilKunjungan {
  adaOrder('ada_order', 'Ada Order'),
  tidakAdaOrder('tidak_ada_order', 'Tidak Ada Order'),
  tokoTutup('toko_tutup', 'Toko Tutup');

  final String jsonValue;
  final String label;
  const HasilKunjungan(this.jsonValue, this.label);

  static HasilKunjungan fromString(String? value) {
    switch (value) {
      case 'ada_order':
      case 'adaOrder':
        return HasilKunjungan.adaOrder;
      case 'tidak_ada_order':
      case 'tidakAdaOrder':
        return HasilKunjungan.tidakAdaOrder;
      case 'toko_tutup':
      case 'tokoTutup':
        return HasilKunjungan.tokoTutup;
      default:
        return HasilKunjungan.adaOrder;
    }
  }
}

/// Status penyimpanan jurnal kunjungan.
enum StatusJurnal {
  draft('draft'),
  finalStatus('final');

  final String jsonValue;
  const StatusJurnal(this.jsonValue);

  static StatusJurnal fromString(String? value) {
    return value == 'draft' ? StatusJurnal.draft : StatusJurnal.finalStatus;
  }
}

/// Model jurnal kunjungan lapangan sales.
class JurnalKunjungan {
  final int id;
  final int salesId;
  final String noJo;
  final DateTime tanggal;
  final HasilKunjungan hasil;
  final String catatan;
  final String? fotoDisplay;
  final String? fotoNotaPo;
  final double lat;
  final double lng;
  final double jarakM;
  final StatusJurnal status;

  const JurnalKunjungan({
    required this.id,
    this.salesId = 2,
    required this.noJo,
    required this.tanggal,
    required this.hasil,
    required this.catatan,
    this.fotoDisplay,
    this.fotoNotaPo,
    required this.lat,
    required this.lng,
    required this.jarakM,
    required this.status,
  });

  JurnalKunjungan copyWith({
    int? id,
    int? salesId,
    String? noJo,
    DateTime? tanggal,
    HasilKunjungan? hasil,
    String? catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    double? lat,
    double? lng,
    double? jarakM,
    StatusJurnal? status,
  }) {
    return JurnalKunjungan(
      id: id ?? this.id,
      salesId: salesId ?? this.salesId,
      noJo: noJo ?? this.noJo,
      tanggal: tanggal ?? this.tanggal,
      hasil: hasil ?? this.hasil,
      catatan: catatan ?? this.catatan,
      fotoDisplay: fotoDisplay ?? this.fotoDisplay,
      fotoNotaPo: fotoNotaPo ?? this.fotoNotaPo,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      jarakM: jarakM ?? this.jarakM,
      status: status ?? this.status,
    );
  }

  factory JurnalKunjungan.fromJson(Map<String, dynamic> json) {
    return JurnalKunjungan(
      id: (json['id_kunjungan'] ?? json['id']) as int,
      salesId: (json['id_sales'] ?? json['sales_id']) as int? ?? 2,
      noJo: json['no_jo'] as String,
      tanggal: DateTime.parse(
        (json['tgl_kunjungan'] ?? json['tanggal']) as String,
      ),
      hasil: HasilKunjungan.fromString(
        (json['status_order'] ?? json['hasil']) as String?,
      ),
      catatan: (json['ket_aktivitas'] ?? json['catatan']) as String? ?? '',
      fotoDisplay:
          (json['foto_display_path'] ?? json['foto_display']) as String?,
      fotoNotaPo:
          (json['foto_nota_po_path'] ?? json['foto_nota_po']) as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      jarakM: ((json['jarak_checkin_m'] ?? json['jarak_m']) as num).toDouble(),
      status: StatusJurnal.fromString(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kunjungan': id,
      'id_sales': salesId,
      'no_jo': noJo,
      'tgl_kunjungan': tanggal.toIso8601String(),
      'status_order': hasil.jsonValue,
      'ket_aktivitas': catatan,
      'foto_display_path': fotoDisplay,
      'foto_nota_po_path': fotoNotaPo,
      'lat': lat,
      'lng': lng,
      'jarak_checkin_m': jarakM,
      'status': status.jsonValue,
    };
  }
}
