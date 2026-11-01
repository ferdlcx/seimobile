import '../../../core/mock/mock_database.dart';
import '../../auth/data/models/pengguna_model.dart';
import 'akun_repository.dart';

/// Implementasi Mock untuk AkunRepository.
class MockAkunRepository implements AkunRepository {
  final MockDatabase db;

  MockAkunRepository(this.db);

  @override
  Future<List<Pengguna>> list() async {
    await db.simulateNetworkDelay();
    return List<Pengguna>.from(db.akunList);
  }

  @override
  Future<Pengguna> create({
    required String nama,
    required String username,
    required String password,
    required String role,
    required bool aktif,
  }) async {
    await db.simulateNetworkDelay();
    final exists = db.akunList.any(
      (a) => a.username.toLowerCase() == username.trim().toLowerCase(),
    );
    if (exists) {
      throw Exception('Username "$username" sudah digunakan.');
    }

    final nextId = db.akunList.isEmpty
        ? 1
        : db.akunList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

    final baru = Pengguna(
      id: nextId,
      nama: nama.trim(),
      username: username.trim(),
      role: role,
      aktif: aktif,
      isBaru: true,
    );

    // Taruh akun baru di urutan paling atas agar langsung terlihat dengan badge BARU.
    db.akunList = [
      baru,
      ...db.akunList.map((a) => a.copyWith(isBaru: false)),
    ];
    return baru;
  }

  @override
  Future<Pengguna> setAktif(int id, bool aktif) async {
    await db.simulateNetworkDelay();
    late Pengguna updated;
    db.akunList = db.akunList.map((a) {
      if (a.id == id) {
        updated = a.copyWith(aktif: aktif);
        return updated;
      }
      return a;
    }).toList();
    return updated;
  }
}
