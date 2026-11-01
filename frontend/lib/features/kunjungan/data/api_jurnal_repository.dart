import '../../../core/network/dio_client.dart';
import 'jurnal_repository.dart';
import 'models/jurnal_kunjungan_model.dart';

/// Kerangka implementasi API untuk JurnalRepository (`/jurnal/*`).
class ApiJurnalRepository implements JurnalRepository {
  final DioClient client;

  ApiJurnalRepository(this.client);

  @override
  Future<List<JurnalKunjungan>> list({DateTime? tanggal, int? salesId}) async {
    // TODO(backend): Hubungkan ke GET /api/v1/jurnal
    final res = await client.dio.get<Map<String, dynamic>>(
      '/jurnal',
      queryParameters: {
        if (tanggal != null) 'tanggal': tanggal.toIso8601String(),
        'sales_id': ?salesId,
      },
    );
    final list = res.data!['data'] as List<dynamic>;
    return list
        .map((e) => JurnalKunjungan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<JurnalKunjungan> create({
    required String noJo,
    required HasilKunjungan hasil,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    required double lat,
    required double lng,
    required double jarakM,
  }) async {
    // TODO(backend): Hubungkan ke POST /api/v1/jurnal (multipart/form-data)
    final res = await client.dio.post<Map<String, dynamic>>(
      '/jurnal',
      data: {
        'no_jo': noJo,
        'status_order': hasil.jsonValue,
        'ket_aktivitas': catatan,
        'lat': lat,
        'lng': lng,
        'foto_display': fotoDisplay,
        'foto_nota_po': fotoNotaPo,
      },
    );
    return JurnalKunjungan.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<JurnalKunjungan> saveDraft({
    required String noJo,
    required HasilKunjungan hasil,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    required double lat,
    required double lng,
    required double jarakM,
  }) async {
    // TODO(backend): Hubungkan ke POST /api/v1/jurnal/draft
    final res = await client.dio.post<Map<String, dynamic>>(
      '/jurnal/draft',
      data: {
        'no_jo': noJo,
        'status_order': hasil.jsonValue,
        'ket_aktivitas': catatan,
        'lat': lat,
        'lng': lng,
        'foto_display': fotoDisplay,
        'foto_nota_po': fotoNotaPo,
      },
    );
    return JurnalKunjungan.fromJson(res.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<JurnalKunjungan?> getDraft(String noJo) async {
    // TODO(backend): Ambil draft lokal atau dari API
    return null;
  }

  @override
  Future<JurnalKunjungan> finalize(int id) async {
    // TODO(backend): Hubungkan ke POST /api/v1/jurnal/{id}/finalisasi
    final res = await client.dio.post<Map<String, dynamic>>(
      '/jurnal/$id/finalisasi',
    );
    return JurnalKunjungan.fromJson(res.data!['data'] as Map<String, dynamic>);
  }
}
