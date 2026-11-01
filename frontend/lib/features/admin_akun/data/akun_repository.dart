import '../../auth/data/models/pengguna_model.dart';

/// Kontrak repository pengelolaan akun oleh Admin Tagihan sejajar dengan `/akun/*`.
abstract class AkunRepository {
  Future<List<Pengguna>> list();

  Future<Pengguna> create({
    required String nama,
    required String username,
    required String password,
    required String role,
    required bool aktif,
  });

  Future<Pengguna> setAktif(int id, bool aktif);
}
