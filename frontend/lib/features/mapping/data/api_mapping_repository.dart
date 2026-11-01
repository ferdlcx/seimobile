import '../../../core/network/dio_client.dart';
import '../../admin_data/data/models/master_models.dart';
import 'mapping_repository.dart';
import 'models/mapping_toko_model.dart';

/// Kerangka implementasi API untuk MappingRepository (`/mapping/*`).
class ApiMappingRepository implements MappingRepository {
  final DioClient client;

  ApiMappingRepository(this.client);

  @override
  Future<List<MappingToko>> get({
    required int salesId,
    required int tahun,
    int? wilayahId,
  }) async {
    // TODO(backend): Hubungkan ke GET /api/v1/mapping
    final res = await client.dio.get<Map<String, dynamic>>(
      '/mapping',
      queryParameters: {
        'sales_id': salesId,
        'tahun': tahun,
        'wilayah_id': ?wilayahId,
      },
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => MappingToko.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<MappingToko> items) async {
    // TODO(backend): Hubungkan ke PUT /api/v1/mapping
    await client.dio.put<void>(
      '/mapping',
      data: {'items': items.map((e) => e.toJson()).toList()},
    );
  }

  @override
  Future<MappingHariIniData> hariIni({int? wilayahId}) async {
    // TODO(backend): Hubungkan ke GET /api/v1/mapping/hari-ini
    final res = await client.dio.get<Map<String, dynamic>>(
      '/mapping/hari-ini',
      queryParameters: {'wilayah_id': ?wilayahId},
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    final list = (data['toko'] as List<dynamic>)
        .map((e) => Toko.fromJson(e as Map<String, dynamic>))
        .toList();
    return MappingHariIniData(
      daftarToko: list,
      sudahDikunjungi: data['sudah_dikunjungi'] as int? ?? 0,
      totalTarget: data['total_target'] as int? ?? list.length,
    );
  }
}
