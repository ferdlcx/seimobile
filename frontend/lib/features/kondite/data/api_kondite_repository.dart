import '../../../core/network/dio_client.dart';
import 'kondite_repository.dart';
import 'models/penilaian_kondite_model.dart';

/// Kerangka implementasi API untuk KonditeRepository (`/kondite/*`).
class ApiKonditeRepository implements KonditeRepository {
  final DioClient client;

  ApiKonditeRepository(this.client);

  @override
  Future<PenilaianKondite> get({
    required int salesId,
    required String periode,
  }) async {
    // TODO(backend): Hubungkan ke GET /api/v1/kondite
    final res = await client.dio.get<Map<String, dynamic>>(
      '/kondite',
      queryParameters: {
        'sales_id': salesId,
        'periode': periode,
      },
    );
    return PenilaianKondite.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<PenilaianKondite> save({
    required int salesId,
    required String periode,
    required Map<int, String> detail,
  }) async {
    // TODO(backend): Hubungkan ke PUT /api/v1/kondite
    final res = await client.dio.put<Map<String, dynamic>>(
      '/kondite',
      data: {
        'sales_id': salesId,
        'periode': periode,
        'detail': detail.entries
            .map((e) => {'id_kriteria': e.key, 'nilai': e.value})
            .toList(),
      },
    );
    return PenilaianKondite.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<PenilaianKondite> saya() async {
    // TODO(backend): Hubungkan ke GET /api/v1/kondite/saya
    final res = await client.dio.get<Map<String, dynamic>>('/kondite/saya');
    return PenilaianKondite.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
