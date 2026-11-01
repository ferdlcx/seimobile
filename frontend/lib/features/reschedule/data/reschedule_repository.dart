import 'models/pengajuan_reschedule_model.dart';

/// Kontrak repository pengajuan dan approval reschedule sejajar dengan `/reschedule/*`.
abstract class RescheduleRepository {
  Future<List<PengajuanReschedule>> list();

  Future<PengajuanReschedule> create({
    required String noJo,
    required DateTime jadwalBaru,
    required String alasan,
  });

  Future<PengajuanReschedule> setujui(int id);

  Future<PengajuanReschedule> tolak(int id);
}
