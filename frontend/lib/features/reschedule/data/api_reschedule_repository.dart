import '../../../core/network/dio_client.dart';
import 'models/pengajuan_reschedule_model.dart';
import 'reschedule_repository.dart';

/// Kerangka implementasi API untuk RescheduleRepository (`/reschedule/*`).
class ApiRescheduleRepository implements RescheduleRepository {
  final DioClient client;

  ApiRescheduleRepository(this.client);

  @override
  Future<List<PengajuanReschedule>> list() async {
    // TODO(backend): Hubungkan ke GET /api/v1/reschedule
    final res = await client.dio.get<Map<String, dynamic>>('/reschedule');
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => PengajuanReschedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PengajuanReschedule> create({
    required String noJo,
    required DateTime jadwalBaru,
    required String alasan,
  }) async {
    // TODO(backend): Hubungkan ke POST /api/v1/reschedule
    final res = await client.dio.post<Map<String, dynamic>>(
      '/reschedule',
      data: {
        'no_jo': noJo,
        'jadwal_baru': jadwalBaru.toIso8601String(),
        'alasan': alasan,
      },
    );
    return PengajuanReschedule.fromJson(
      res.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PengajuanReschedule> setujui(int id) async {
    // TODO(backend): Hubungkan ke POST /api/v1/reschedule/{id}/setujui
    final res = await client.dio.post<Map<String, dynamic>>(
      '/reschedule/$id/setujui',
    );
    return PengajuanReschedule.fromJson(
      res.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PengajuanReschedule> tolak(int id) async {
    // TODO(backend): Hubungkan ke POST /api/v1/reschedule/{id}/tolak
    final res = await client.dio.post<Map<String, dynamic>>(
      '/reschedule/$id/tolak',
    );
    return PengajuanReschedule.fromJson(
      res.data!['data'] as Map<String, dynamic>,
    );
  }
}
