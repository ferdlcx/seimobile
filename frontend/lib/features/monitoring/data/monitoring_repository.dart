import 'models/monitoring_models.dart';

/// Kontrak repository monitoring harian dan progres sales sejajar dengan `/monitoring/*`.
abstract class MonitoringRepository {
  Future<RingkasanMonitoring> harian({int? wilayahId});

  Future<List<ProgresSales>> salesProgress();
}
