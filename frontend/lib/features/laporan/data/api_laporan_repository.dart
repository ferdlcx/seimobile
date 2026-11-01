import '../../../core/network/dio_client.dart';
import '../../monitoring/data/models/monitoring_models.dart';
import 'laporan_repository.dart';

/// Kerangka implementasi API untuk LaporanRepository (`/laporan/rekap`).
class ApiLaporanRepository implements LaporanRepository {
  final DioClient client;

  ApiLaporanRepository(this.client);

  @override
  Future<LaporanRekapData> rekap({
    required String periode,
    int? wilayahId,
  }) async {
    // TODO(backend): Hubungkan ke GET /api/v1/laporan/rekap
    final res = await client.dio.get<Map<String, dynamic>>(
      '/laporan/rekap',
      queryParameters: {
        'periode': periode,
        'wilayah_id': ?wilayahId,
      },
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    final list = (data['baris'] as List<dynamic>)
        .map((e) => RekapWilayah.fromJson(e as Map<String, dynamic>))
        .toList();
    return LaporanRekapData(
      periodeLabel: data['periode_label'] as String? ?? periode,
      barisWilayah: list,
      totalTarget: data['total_target'] as int? ?? 0,
      totalReal: data['total_real'] as int? ?? 0,
      totalPersen: data['total_persen'] as int? ?? 0,
      waktuCetak: DateTime.now(),
    );
  }
}
