import '../../admin_data/data/models/master_models.dart';
import 'models/mapping_toko_model.dart';

/// Data ringkasan mapping hari ini untuk Sales.
class MappingHariIniData {
  final List<Toko> daftarToko;
  final int sudahDikunjungi;
  final int totalTarget;

  const MappingHariIniData({
    required this.daftarToko,
    required this.sudahDikunjungi,
    required this.totalTarget,
  });
}

/// Kontrak repository mapping tahunan & mapping hari ini sejajar dengan `/mapping/*`.
abstract class MappingRepository {
  Future<List<MappingToko>> get({
    required int salesId,
    required int tahun,
    int? wilayahId,
  });

  Future<void> save(List<MappingToko> items);

  Future<MappingHariIniData> hariIni({int? wilayahId});
}
