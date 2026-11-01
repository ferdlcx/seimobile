/// Model wilayah pemasaran (mis. Purwokerto Timur, Sokaraja).
class Wilayah {
  final int id;
  final String nama;

  const Wilayah({
    required this.id,
    required this.nama,
  });

  factory Wilayah.fromJson(Map<String, dynamic> json) {
    return Wilayah(
      id: (json['id_wilayah'] ?? json['id']) as int,
      nama: (json['nama_wilayah'] ?? json['nama']) as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_wilayah': id,
      'nama_wilayah': nama,
    };
  }
}

/// Model toko pelanggan yang diidentifikasi dengan No JO.
class Toko {
  final String noJo;
  final String nama;
  final String alamat;
  final String ket;
  final Wilayah wilayah;
  final double lat;
  final double lng;
  final bool sudahDikunjungiBulanIni;
  final int hariSejakKunjunganTerakhir;

  const Toko({
    required this.noJo,
    required this.nama,
    required this.alamat,
    this.ket = '',
    required this.wilayah,
    required this.lat,
    required this.lng,
    this.sudahDikunjungiBulanIni = false,
    this.hariSejakKunjunganTerakhir = 0,
  });

  Toko copyWith({
    String? noJo,
    String? nama,
    String? alamat,
    String? ket,
    Wilayah? wilayah,
    double? lat,
    double? lng,
    bool? sudahDikunjungiBulanIni,
    int? hariSejakKunjunganTerakhir,
  }) {
    return Toko(
      noJo: noJo ?? this.noJo,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      ket: ket ?? this.ket,
      wilayah: wilayah ?? this.wilayah,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      sudahDikunjungiBulanIni:
          sudahDikunjungiBulanIni ?? this.sudahDikunjungiBulanIni,
      hariSejakKunjunganTerakhir:
          hariSejakKunjunganTerakhir ?? this.hariSejakKunjunganTerakhir,
    );
  }

  factory Toko.fromJson(Map<String, dynamic> json) {
    final wilayahJson = json['wilayah'] as Map<String, dynamic>?;
    return Toko(
      noJo: json['no_jo'] as String,
      nama: (json['nama_toko'] ?? json['nama']) as String,
      alamat: json['alamat'] as String? ?? '',
      ket: (json['ket_toko'] ?? json['ket']) as String? ?? '',
      wilayah: wilayahJson != null
          ? Wilayah.fromJson(wilayahJson)
          : Wilayah(
              id: json['id_wilayah'] as int? ?? 1,
              nama: json['nama_wilayah'] as String? ?? 'Purwokerto Timur',
            ),
      lat: (json['latitude'] ?? json['lat'] as num?)?.toDouble() ?? -7.4244,
      lng: (json['longitude'] ?? json['lng'] as num?)?.toDouble() ?? 109.2302,
      sudahDikunjungiBulanIni:
          json['sudah_dikunjungi_bulan_ini'] as bool? ?? false,
      hariSejakKunjunganTerakhir:
          json['hari_sejak_kunjungan_terakhir'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no_jo': noJo,
      'nama_toko': nama,
      'alamat': alamat,
      'ket_toko': ket,
      'id_wilayah': wilayah.id,
      'wilayah': wilayah.toJson(),
      'latitude': lat,
      'longitude': lng,
      'sudah_dikunjungi_bulan_ini': sudahDikunjungiBulanIni,
      'hari_sejak_kunjungan_terakhir': hariSejakKunjunganTerakhir,
    };
  }
}

/// Model kriteria penilaian kondite (18 kriteria).
class Kriteria {
  final int id;
  final int urutan;
  final String nama;
  final bool aktif;

  const Kriteria({
    required this.id,
    required this.urutan,
    required this.nama,
    this.aktif = true,
  });

  Kriteria copyWith({
    int? id,
    int? urutan,
    String? nama,
    bool? aktif,
  }) {
    return Kriteria(
      id: id ?? this.id,
      urutan: urutan ?? this.urutan,
      nama: nama ?? this.nama,
      aktif: aktif ?? this.aktif,
    );
  }

  factory Kriteria.fromJson(Map<String, dynamic> json) {
    return Kriteria(
      id: (json['id_kriteria'] ?? json['id']) as int,
      urutan: json['urutan'] as int,
      nama: json['nama'] as String,
      aktif: json['aktif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kriteria': id,
      'urutan': urutan,
      'nama': nama,
      'aktif': aktif,
    };
  }
}
