import '../../../core/mock/mock_database.dart';
import 'auth_repository.dart';

/// Implementasi Mock untuk AuthRepository.
class MockAuthRepository implements AuthRepository {
  final MockDatabase db;

  MockAuthRepository(this.db);

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
    required String role,
    String? mode,
  }) async {
    await db.simulateNetworkDelay();

    final trimmedUser = username.trim().toLowerCase();
    final matched = db.akunList.where(
      (a) => a.username.toLowerCase() == trimmedUser && a.role == role,
    );

    if (matched.isEmpty || password != 'password123') {
      throw Exception('Username atau password tidak sesuai dengan peran ini.');
    }

    final user = matched.first;
    if (!user.aktif) {
      throw Exception('Akun ini sedang nonaktif. Hubungi Admin Tagihan.');
    }

    final resolvedMode = role == 'manajer_sales'
        ? (mode == 'sales' ? 'sales' : 'manajer')
        : role;

    final session = AuthSession(
      token: 'mock-sanctum-token-${user.id}',
      user: user,
      mode: resolvedMode,
    );
    db.currentSession = session;
    return session;
  }

  @override
  Future<void> logout() async {
    await db.simulateNetworkDelay();
    db.currentSession = null;
  }

  @override
  Future<AuthSession?> me() async {
    await db.simulateNetworkDelay();
    return db.currentSession;
  }

  @override
  Future<void> simpanTandaTangan(String base64Signature) async {
    await db.simulateNetworkDelay();
    final current = db.currentSession;
    if (current != null) {
      final updatedUser = current.user.copyWith(
        tandaTanganBase64: base64Signature,
      );
      db.currentSession = AuthSession(
        token: current.token,
        user: updatedUser,
        mode: current.mode,
      );
      db.akunList = db.akunList.map((a) {
        return a.id == updatedUser.id ? updatedUser : a;
      }).toList();
    }
  }
}
