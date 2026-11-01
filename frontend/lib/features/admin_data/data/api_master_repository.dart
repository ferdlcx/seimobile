import '../../../core/network/dio_client.dart';
import 'master_repository.dart';
import 'models/master_models.dart';

/// Kerangka implementasi API untuk MasterRepository (`/wilayah`, `/toko`, `/kriteria`).
class ApiMasterRepository implements MasterRepository {
  final DioClient client;

  ApiMasterRepository(this.client);

  @override
  Future<List<Wilayah>> wilayah() async {
    // TODO(backend): Hubungkan ke GET /api/v1/wilayah
    final res = await client.dio.get<Map<String, dynamic>>('/wilayah');
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Wilayah.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Toko>> tokoList({int? wilayahId, String? q}) async {
    // TODO(backend): Hubungkan ke GET /api/v1/toko
    final res = await client.dio.get<Map<String, dynamic>>(
      '/toko',
      queryParameters: {
        'wilayah_id': ?wilayahId,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    final list = res.data!['data'] as List<dynamic>;
    return list.map((e) => Toko.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Toko> tokoCreate({
    required String noJo,
    required String nama,
    required int wilayahId,
    required String alamat,
    String ket = '',
    double? lat,
    double? lng,
  }) async {
    // TODO(backend): Hubungkan ke POST /api/v1/toko
    final res = await client.dio.post<Map<String, dynamic>>(
      '/toko',
      data: {
        'no_jo': noJo,
        'nama_toko': nama,
        'id_wilayah': wilayahId,
        'alamat': alamat,
        'ket_toko': ket,
        'latitude': lat ?? -7.4250,
        'longitude': lng ?? 109.2350,
      },
    );
    return Toko.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<Kriteria>> kriteria() async {
    // TODO(backend): Hubungkan ke GET /api/v1/kriteria
    final res = await client.dio.get<Map<String, dynamic>>('/kriteria');
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => Kriteria.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Kriteria> updateKriteria(
    int id, {
    required String nama,
    bool? aktif,
  }) async {
    // TODO(backend): Hubungkan ke PUT /api/v1/kriteria/{id}
    final res = await client.dio.put<Map<String, dynamic>>(
      '/kriteria/$id',
      data: {
        'nama': nama,
        'aktif': ?aktif,
      },
    );
    return Kriteria.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
