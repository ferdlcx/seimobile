import 'models/master_models.dart';

/// Kontrak repository data master (wilayah, toko, kriteria) sejajar dengan `/wilayah`, `/toko`, `/kriteria`.
abstract class MasterRepository {
  Future<List<Wilayah>> wilayah();

  Future<List<Toko>> tokoList({int? wilayahId, String? q});

  Future<Toko> tokoCreate({
    required String noJo,
    required String nama,
    required int wilayahId,
    required String alamat,
    String ket = '',
    double? lat,
    double? lng,
  });

  Future<List<Kriteria>> kriteria();

  Future<Kriteria> updateKriteria(int id, {required String nama, bool? aktif});
}
