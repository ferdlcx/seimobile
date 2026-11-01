import '../../../core/network/dio_client.dart';
import '../../auth/data/models/pengguna_model.dart';
import 'akun_repository.dart';

/// Kerangka implementasi API untuk AkunRepository (`/api/v1/akun/*`).
class ApiAkunRepository implements AkunRepository {
  final DioClient client;

  ApiAkunRepository(this.client);

  @override
  Future<List<Pengguna>> list() async {
    // TODO(backend): Hubungkan ke GET /api/v1/akun
    final res = await client.dio.get<Map<String, dynamic>>('/akun');
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Pengguna.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Pengguna> create({
    required String nama,
    required String username,
    required String password,
    required String role,
    required bool aktif,
  }) async {
    // TODO(backend): Hubungkan ke POST /api/v1/akun
    final res = await client.dio.post<Map<String, dynamic>>(
      '/akun',
      data: {
        'nama': nama,
        'username': username,
        'password': password,
        'role': role,
        'aktif': aktif,
      },
    );
    return Pengguna.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<Pengguna> setAktif(int id, bool aktif) async {
    // TODO(backend): Hubungkan ke PATCH /api/v1/akun/{id}/aktif
    final res = await client.dio.patch<Map<String, dynamic>>(
      '/akun/$id/aktif',
      data: {'aktif': aktif},
    );
    return Pengguna.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
