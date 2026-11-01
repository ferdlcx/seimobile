import 'models/jurnal_kunjungan_model.dart';

/// Kontrak repository jurnal kunjungan lapangan sejajar dengan `/jurnal/*`.
abstract class JurnalRepository {
  Future<List<JurnalKunjungan>> list({DateTime? tanggal, int? salesId});

  Future<JurnalKunjungan> create({
    required String noJo,
    required HasilKunjungan hasil,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    required double lat,
    required double lng,
    required double jarakM,
  });

  Future<JurnalKunjungan> saveDraft({
    required String noJo,
    required HasilKunjungan hasil,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    required double lat,
    required double lng,
    required double jarakM,
  });

  Future<JurnalKunjungan?> getDraft(String noJo);

  Future<JurnalKunjungan> finalize(int id);
}
