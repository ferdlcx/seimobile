/// Model pengguna aplikasi (Admin Tagihan, Sales, Manajer Sales).
class Pengguna {
  final int id;
  final String nama;
  final String username;
  final String role; // 'admin_tagihan' | 'sales' | 'manajer_sales'
  final bool aktif;
  final bool isBaru;
  final String? tandaTanganBase64;

  const Pengguna({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
    required this.aktif,
    this.isBaru = false,
    this.tandaTanganBase64,
  });

  String get labelPeran {
    switch (role) {
      case 'admin_tagihan':
        return 'Admin Tagihan';
      case 'manajer_sales':
        return 'Manajer Sales';
      case 'sales':
      default:
        return 'Sales';
    }
  }

  Pengguna copyWith({
    int? id,
    String? nama,
    String? username,
    String? role,
    bool? aktif,
    bool? isBaru,
    String? tandaTanganBase64,
  }) {
    return Pengguna(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      role: role ?? this.role,
      aktif: aktif ?? this.aktif,
      isBaru: isBaru ?? this.isBaru,
      tandaTanganBase64: tandaTanganBase64 ?? this.tandaTanganBase64,
    );
  }

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      nama: json['nama'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      aktif: json['aktif'] as bool? ?? true,
      isBaru: json['is_baru'] as bool? ?? false,
      tandaTanganBase64: json['tanda_tangan_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'role': role,
      'aktif': aktif,
      'is_baru': isBaru,
      'tanda_tangan_path': tandaTanganBase64,
    };
  }
}
