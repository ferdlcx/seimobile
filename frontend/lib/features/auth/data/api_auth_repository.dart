import '../../../core/network/dio_client.dart';
import 'auth_repository.dart';
import 'models/pengguna_model.dart';

/// Kerangka implementasi API untuk AuthRepository (`/api/v1/auth/*`).
class ApiAuthRepository implements AuthRepository {
  final DioClient client;

  ApiAuthRepository(this.client);

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
    required String role,
    String? mode,
  }) async {
    // TODO(backend): Hubungkan ke POST /api/v1/auth/login
    final response = await client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'role': role,
        'mode': ?mode,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = Pengguna.fromJson(data['user'] as Map<String, dynamic>);
    await client.secureStorage.write(key: 'auth_token', value: token);
    if (mode != null) {
      await client.secureStorage.write(key: 'auth_mode', value: mode);
    }
    return AuthSession(token: token, user: user, mode: mode ?? role);
  }

  @override
  Future<void> logout() async {
    // TODO(backend): Hubungkan ke POST /api/v1/auth/logout
    await client.dio.post<void>('/auth/logout');
    await client.secureStorage.delete(key: 'auth_token');
    await client.secureStorage.delete(key: 'auth_mode');
  }

  @override
  Future<AuthSession?> me() async {
    // TODO(backend): Hubungkan ke GET /api/v1/auth/me
    final token = await client.secureStorage.read(key: 'auth_token');
    if (token == null) return null;
    final response = await client.dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data!['data'] as Map<String, dynamic>;
    final user = Pengguna.fromJson(data);
    final mode = await client.secureStorage.read(key: 'auth_mode') ?? user.role;
    return AuthSession(token: token, user: user, mode: mode);
  }

  @override
  Future<void> simpanTandaTangan(String base64Signature) async {
    // TODO(backend): Hubungkan ke endpoint simpan tanda tangan profil
  }
}
