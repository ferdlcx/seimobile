import '../../../core/network/dio_client.dart';
import 'models/monitoring_models.dart';
import 'monitoring_repository.dart';

/// Kerangka implementasi API untuk MonitoringRepository (`/monitoring/*`).
class ApiMonitoringRepository implements MonitoringRepository {
  final DioClient client;

  ApiMonitoringRepository(this.client);

  @override
  Future<RingkasanMonitoring> harian({int? wilayahId}) async {
    // TODO(backend): Hubungkan ke GET /api/v1/monitoring/harian
    final res = await client.dio.get<Map<String, dynamic>>(
      '/monitoring/harian',
      queryParameters: {'wilayah_id': ?wilayahId},
    );
    return RingkasanMonitoring.fromJson(
      res.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ProgresSales>> salesProgress() async {
    // TODO(backend): Hubungkan ke GET /api/v1/monitoring/sales-progress
    final res = await client.dio.get<Map<String, dynamic>>(
      '/monitoring/sales-progress',
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => ProgresSales.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
