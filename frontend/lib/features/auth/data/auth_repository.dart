import 'models/pengguna_model.dart';

/// Hasil autentikasi saat login berhasil.
class AuthSession {
  final String token;
  final Pengguna user;
  final String mode; // 'admin_tagihan' | 'sales' | 'manajer'

  const AuthSession({
    required this.token,
    required this.user,
    required this.mode,
  });
}

/// Kontrak repository autentikasi sejajar dengan endpoint `/auth/*`.
abstract class AuthRepository {
  Future<AuthSession> login({
    required String username,
    required String password,
    required String role,
    String? mode,
  });

  Future<void> logout();

  Future<AuthSession?> me();

  Future<void> simpanTandaTangan(String base64Signature);
}
