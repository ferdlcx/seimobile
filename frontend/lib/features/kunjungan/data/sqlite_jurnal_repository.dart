import '../../../core/database/seui_sqlite_database.dart';
import 'jurnal_repository.dart';
import 'models/jurnal_kunjungan_model.dart';

/// Implementasi SQLite persisten untuk JurnalRepository.
class SqliteJurnalRepository implements JurnalRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteJurnalRepository(this.dbHelper);

  static JurnalKunjungan _mapRow(Map<String, Object?> r) {
    return JurnalKunjungan(
      id: r['id_kunjungan'] as int,
      salesId: r['id_sales'] as int,
      noJo: r['no_jo'] as String,
      tanggal: DateTime.parse(r['tgl_kunjungan'] as String),
      hasil: HasilKunjungan.fromString(r['status_order'] as String?),
      jenisAktivitas: (r['jenis_aktivitas'] as String?) ??
          JenisAktivitasKunjungan.kunjunganOrder,
      catatan: r['ket_aktivitas'] as String? ?? '',
      fotoDisplay: r['foto_display_path'] as String?,
      fotoNotaPo: r['foto_nota_po_path'] as String?,
      lat: (r['lat'] as num).toDouble(),
      lng: (r['lng'] as num).toDouble(),
      jarakM: (r['jarak_checkin_m'] as num).toDouble(),
      status: StatusJurnal.fromString(r['status'] as String?),
    );
  }

  @override
  Future<List<JurnalKunjungan>> list({DateTime? tanggal, int? salesId}) async {
    final db = await dbHelper.database;
    final where = <String>["status = 'final'"];
    final args = <Object?>[];

    if (salesId != null) {
      where.add('id_sales = ?');
      args.add(salesId);
    }
    if (tanggal != null) {
      final ymd =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
      where.add('substr(tgl_kunjungan, 1, 10) = ?');
      args.add(ymd);
    }

    final rows = await db.query(
      'jurnal_kunjungan',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'id_kunjungan DESC',
    );
    return rows.map(_mapRow).toList();
  }

  @override
  Future<JurnalKunjungan> create({
    required String noJo,
    required HasilKunjungan hasil,
    String jenisAktivitas = JenisAktivitasKunjungan.kunjunganOrder,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    required double lat,
    required double lng,
    required double jarakM,
  }) async {
    if (hasil == HasilKunjungan.adaOrder &&
        (fotoNotaPo == null || fotoNotaPo.trim().isEmpty)) {
      throw Exception(
        'Foto nota PO wajib dilampirkan bila hasil kunjungan Ada Order.',
      );
    }

    final db = await dbHelper.database;
    final session = await dbHelper.getActiveSession();
    final salesId =
        (session != null && session.user.role == 'sales') ? session.user.id : 2;
    final now = dbHelper.getConfig().mockToday;
    final tglIso = now.toIso8601String();

    final newId = await db.transaction((txn) async {
      final mappingRows = await txn.query(
        'mapping_toko',
        columns: ['id_mapping'],
        where: 'id_sales = ? AND no_jo = ? AND tahun = ?',
        whereArgs: [salesId, noJo, now.year],
        limit: 1,
      );
      final idMapping = mappingRows.isNotEmpty
          ? mappingRows.first['id_mapping'] as int
          : null;

      await txn.delete(
        'jurnal_kunjungan',
        where: "no_jo = ? AND status = 'draft'",
        whereArgs: [noJo],
      );

      final insertedId = await txn.insert('jurnal_kunjungan', {
        'id_mapping': idMapping,
        'id_sales': salesId,
        'no_jo': noJo,
        'tgl_kunjungan': tglIso,
        'status_order': hasil.jsonValue,
        'jenis_aktivitas': jenisAktivitas,
        'ket_aktivitas': catatan.trim(),
        'foto_display_path': fotoDisplay,
        'foto_nota_po_path': fotoNotaPo,
        'lat': lat,
        'lng': lng,
        'jarak_checkin_m': jarakM,
        'status': StatusJurnal.finalStatus.jsonValue,
      });

      await txn.update(
        'toko',
        {'hari_sejak_kunjungan_terakhir': 0},
        where: 'no_jo = ?',
        whereArgs: [noJo],
      );

      await txn.rawUpdate(
        '''
        UPDATE mapping_bulan
        SET terealisasi = 1
        WHERE bulan = ?
          AND id_mapping IN (
            SELECT id_mapping FROM mapping_toko
            WHERE no_jo = ? AND tahun = ?
          )
        ''',
        [now.month, noJo, now.year],
      );

      return insertedId;
    });

    final rows = await db.query(
      'jurnal_kunjungan',
      where: 'id_kunjungan = ?',
      whereArgs: [newId],
      limit: 1,
    );
    return _mapRow(rows.first);
  }

  @override
  Future<JurnalKunjungan> saveDraft({
    required String noJo,
    required HasilKunjungan hasil,
    String jenisAktivitas = JenisAktivitasKunjungan.kunjunganOrder,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    required double lat,
    required double lng,
    required double jarakM,
  }) async {
    final db = await dbHelper.database;
    final session = await dbHelper.getActiveSession();
    final salesId =
        (session != null && session.user.role == 'sales') ? session.user.id : 2;
    final now = dbHelper.getConfig().mockToday;

    final existing = await db.query(
      'jurnal_kunjungan',
      where: "no_jo = ? AND status = 'draft'",
      whereArgs: [noJo],
      limit: 1,
    );

    final values = {
      'id_sales': salesId,
      'no_jo': noJo,
      'tgl_kunjungan': now.toIso8601String(),
      'status_order': hasil.jsonValue,
      'jenis_aktivitas': jenisAktivitas,
      'ket_aktivitas': catatan,
      'foto_display_path': fotoDisplay,
      'foto_nota_po_path': fotoNotaPo,
      'lat': lat,
      'lng': lng,
      'jarak_checkin_m': jarakM,
      'status': StatusJurnal.draft.jsonValue,
    };

    final int targetId;
    if (existing.isNotEmpty) {
      targetId = existing.first['id_kunjungan'] as int;
      await db.update(
        'jurnal_kunjungan',
        values,
        where: 'id_kunjungan = ?',
        whereArgs: [targetId],
      );
    } else {
      targetId = await db.insert('jurnal_kunjungan', values);
    }

    final rows = await db.query(
      'jurnal_kunjungan',
      where: 'id_kunjungan = ?',
      whereArgs: [targetId],
      limit: 1,
    );
    return _mapRow(rows.first);
  }

  @override
  Future<JurnalKunjungan?> getDraft(String noJo) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'jurnal_kunjungan',
      where: "no_jo = ? AND status = 'draft'",
      whereArgs: [noJo],
      orderBy: 'id_kunjungan DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapRow(rows.first);
  }

  @override
  Future<JurnalKunjungan?> getLatestFinal(String noJo) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'jurnal_kunjungan',
      where: "no_jo = ? AND status = 'final'",
      whereArgs: [noJo],
      orderBy: 'id_kunjungan DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapRow(rows.first);
  }

  @override
  Future<JurnalKunjungan> updateFinal({
    required int id,
    required String noJo,
    required HasilKunjungan hasil,
    String jenisAktivitas = JenisAktivitasKunjungan.kunjunganOrder,
    required String catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
  }) async {
    if (hasil == HasilKunjungan.adaOrder &&
        (fotoNotaPo == null || fotoNotaPo.trim().isEmpty)) {
      throw Exception(
        'Foto nota PO wajib dilampirkan bila hasil kunjungan Ada Order.',
      );
    }

    final db = await dbHelper.database;
    final updatedCount = await db.update(
      'jurnal_kunjungan',
      {
        'status_order': hasil.jsonValue,
        'jenis_aktivitas': jenisAktivitas,
        'ket_aktivitas': catatan.trim(),
        'foto_display_path': fotoDisplay,
        'foto_nota_po_path': fotoNotaPo,
      },
      where: "id_kunjungan = ? AND no_jo = ? AND status = 'final'",
      whereArgs: [id, noJo],
    );
    if (updatedCount == 0) {
      throw Exception('Jurnal kunjungan tidak ditemukan untuk diperbarui.');
    }

    final rows = await db.query(
      'jurnal_kunjungan',
      where: 'id_kunjungan = ?',
      whereArgs: [id],
      limit: 1,
    );
    return _mapRow(rows.first);
  }

  @override
  Future<JurnalKunjungan> finalize(int id) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'jurnal_kunjungan',
      where: "id_kunjungan = ? AND status = 'draft'",
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Draft jurnal tidak ditemukan.');
    }
    final draft = _mapRow(rows.first);
    return create(
      noJo: draft.noJo,
      hasil: draft.hasil,
      jenisAktivitas: draft.jenisAktivitas,
      catatan: draft.catatan,
      fotoDisplay: draft.fotoDisplay,
      fotoNotaPo: draft.fotoNotaPo,
      lat: draft.lat,
      lng: draft.lng,
      jarakM: draft.jarakM,
    );
  }
}
