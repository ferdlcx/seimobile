import 'models/penilaian_kondite_model.dart';

/// Kontrak repository penilaian kondite 18 kriteria sejajar dengan `/kondite/*`.
abstract class KonditeRepository {
  Future<PenilaianKondite> get({
    required int salesId,
    required String periode,
  });

  Future<PenilaianKondite> save({
    required int salesId,
    required String periode,
    required Map<int, String> detail,
  });

  Future<PenilaianKondite> saya();
}
