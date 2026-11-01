import '../../../core/mock/mock_database.dart';
import 'jurnal_repository.dart';
import 'models/jurnal_kunjungan_model.dart';

/// Implementasi Mock untuk JurnalRepository.
class MockJurnalRepository implements JurnalRepository {
  final MockDatabase db;

  MockJurnalRepository(this.db);

  @override
  Future<List<JurnalKunjungan>> list({DateTime? tanggal, int? salesId}) async {
    await db.simulateNetworkDelay();
    return db.jurnalList.where((j) {
      if (salesId != null && j.salesId != salesId) return false;
      if (tanggal != null) {
        if (j.tanggal.year != tanggal.year ||
            j.tanggal.month != tanggal.month ||
            j.tanggal.day != tanggal.day) {
          return false;
        }
      }
      return true;
    }).toList();
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
    await db.simulateNetworkDelay();

    if (hasil == HasilKunjungan.adaOrder &&
        (fotoNotaPo == null || fotoNotaPo.trim().isEmpty)) {
      throw Exception('Foto nota PO wajib dilampirkan bila hasil kunjungan Ada Order.');
    }

    final nextId = db.jurnalList.isEmpty
        ? 1
        : db.jurnalList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

    final now = db.getConfig().mockToday;
    final baru = JurnalKunjungan(
      id: nextId,
      salesId: db.currentSession?.user.id ?? 2,
      noJo: noJo,
      tanggal: now,
      hasil: hasil,
      catatan: catatan.trim(),
      fotoDisplay: fotoDisplay,
      fotoNotaPo: fotoNotaPo,
      lat: lat,
      lng: lng,
      jarakM: jarakM,
      status: StatusJurnal.finalStatus,
    );

    db.jurnalList = [baru, ...db.jurnalList];
    db.draftByNoJo.remove(noJo);

    // Sinkronkan status toko menjadi Sudah dan update bulan terealisasi di Mapping
    db.markTokoVisited(noJo, now);

    return baru;
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
    await db.simulateNetworkDelay();
    final existing = db.draftByNoJo[noJo];
    final id = existing?.id ??
        (db.jurnalList.isEmpty
            ? 100
            : db.jurnalList.map((e) => e.id).reduce((a, b) => a > b ? a : b) +
                1);

    final draft = JurnalKunjungan(
      id: id,
      salesId: db.currentSession?.user.id ?? 2,
      noJo: noJo,
      tanggal: db.getConfig().mockToday,
      hasil: hasil,
      catatan: catatan,
      fotoDisplay: fotoDisplay,
      fotoNotaPo: fotoNotaPo,
      lat: lat,
      lng: lng,
      jarakM: jarakM,
      status: StatusJurnal.draft,
    );
    db.draftByNoJo[noJo] = draft;
    return draft;
  }

  @override
  Future<JurnalKunjungan?> getDraft(String noJo) async {
    return db.draftByNoJo[noJo];
  }

  @override
  Future<JurnalKunjungan> finalize(int id) async {
    await db.simulateNetworkDelay();
    final entry = db.draftByNoJo.values.where((d) => d.id == id);
    if (entry.isEmpty) {
      throw Exception('Draft jurnal tidak ditemukan.');
    }
    final draft = entry.first;
    return create(
      noJo: draft.noJo,
      hasil: draft.hasil,
      catatan: draft.catatan,
      fotoDisplay: draft.fotoDisplay,
      fotoNotaPo: draft.fotoNotaPo,
      lat: draft.lat,
      lng: draft.lng,
      jarakM: draft.jarakM,
    );
  }
}
