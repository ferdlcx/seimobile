/// Model pengajuan reschedule kunjungan toko oleh sales.
class PengajuanReschedule {
  final int id;
  final String noJo;
  final String namaToko;
  final DateTime jadwalLama;
  final DateTime jadwalBaru;
  final String alasan;
  final String status; // 'menunggu' | 'disetujui' | 'ditolak'
  final String salesNama;
  final int salesId;

  const PengajuanReschedule({
    required this.id,
    required this.noJo,
    required this.namaToko,
    required this.jadwalLama,
    required this.jadwalBaru,
    required this.alasan,
    required this.status,
    required this.salesNama,
    this.salesId = 2,
  });

  PengajuanReschedule copyWith({
    int? id,
    String? noJo,
    String? namaToko,
    DateTime? jadwalLama,
    DateTime? jadwalBaru,
    String? alasan,
    String? status,
    String? salesNama,
    int? salesId,
  }) {
    return PengajuanReschedule(
      id: id ?? this.id,
      noJo: noJo ?? this.noJo,
      namaToko: namaToko ?? this.namaToko,
      jadwalLama: jadwalLama ?? this.jadwalLama,
      jadwalBaru: jadwalBaru ?? this.jadwalBaru,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      salesNama: salesNama ?? this.salesNama,
      salesId: salesId ?? this.salesId,
    );
  }

  factory PengajuanReschedule.fromJson(Map<String, dynamic> json) {
    return PengajuanReschedule(
      id: json['id'] as int,
      noJo: json['no_jo'] as String,
      namaToko: json['nama_toko'] as String,
      jadwalLama: DateTime.parse(json['jadwal_lama'] as String),
      jadwalBaru: DateTime.parse(json['jadwal_baru'] as String),
      alasan: json['alasan'] as String,
      status: json['status'] as String,
      salesNama: json['sales_nama'] as String? ?? 'Budi Santoso',
      salesId: json['id_sales'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_jo': noJo,
      'nama_toko': namaToko,
      'jadwal_lama': jadwalLama.toIso8601String(),
      'jadwal_baru': jadwalBaru.toIso8601String(),
      'alasan': alasan,
      'status': status,
      'sales_nama': salesNama,
      'id_sales': salesId,
    };
  }
}
