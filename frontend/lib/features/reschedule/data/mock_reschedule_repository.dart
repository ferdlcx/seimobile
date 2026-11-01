import '../../../core/mock/mock_database.dart';
import 'models/pengajuan_reschedule_model.dart';
import 'reschedule_repository.dart';

/// Implementasi Mock untuk RescheduleRepository.
class MockRescheduleRepository implements RescheduleRepository {
  final MockDatabase db;

  MockRescheduleRepository(this.db);

  @override
  Future<List<PengajuanReschedule>> list() async {
    await db.simulateNetworkDelay();
    return List<PengajuanReschedule>.from(db.rescheduleList);
  }

  @override
  Future<PengajuanReschedule> create({
    required String noJo,
    required DateTime jadwalBaru,
    required String alasan,
  }) async {
    await db.simulateNetworkDelay();
    final toko = db.tokoList.firstWhere(
      (t) => t.noJo == noJo,
      orElse: () => db.tokoList.first,
    );

    final nextId = db.rescheduleList.isEmpty
        ? 1
        : db.rescheduleList.map((e) => e.id).reduce((a, b) => a > b ? a : b) +
            1;

    final baru = PengajuanReschedule(
      id: nextId,
      noJo: toko.noJo,
      namaToko: toko.nama,
      jadwalLama: db.getConfig().mockToday,
      jadwalBaru: jadwalBaru,
      alasan: alasan.trim(),
      status: 'menunggu',
      salesNama: db.currentSession?.user.nama ?? 'Budi Santoso',
      salesId: db.currentSession?.user.id ?? 2,
    );

    db.rescheduleList = [baru, ...db.rescheduleList];
    return baru;
  }

  @override
  Future<PengajuanReschedule> setujui(int id) async {
    await db.simulateNetworkDelay();
    late PengajuanReschedule updated;
    db.rescheduleList = db.rescheduleList.map((r) {
      if (r.id == id) {
        updated = r.copyWith(status: 'disetujui');
        return updated;
      }
      return r;
    }).toList();
    return updated;
  }

  @override
  Future<PengajuanReschedule> tolak(int id) async {
    await db.simulateNetworkDelay();
    late PengajuanReschedule updated;
    db.rescheduleList = db.rescheduleList.map((r) {
      if (r.id == id) {
        updated = r.copyWith(status: 'ditolak');
        return updated;
      }
      return r;
    }).toList();
    return updated;
  }
}
