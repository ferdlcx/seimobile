import '../../../core/database/seui_sqlite_database.dart';
import 'models/pengajuan_reschedule_model.dart';
import 'reschedule_repository.dart';

/// Implementasi SQLite persisten untuk RescheduleRepository.
class SqliteRescheduleRepository implements RescheduleRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteRescheduleRepository(this.dbHelper);

  static PengajuanReschedule _mapRow(Map<String, Object?> r) {
    return PengajuanReschedule(
      id: r['id'] as int,
      noJo: r['no_jo'] as String,
      namaToko: (r['nama_toko_snapshot'] ?? r['nama_toko']) as String? ?? '',
      jadwalLama: DateTime.parse(r['jadwal_lama'] as String),
      jadwalBaru: DateTime.parse(r['jadwal_baru'] as String),
      alasan: r['alasan'] as String,
      status: r['status'] as String,
      salesNama: r['sales_nama'] as String? ?? 'Budi Santoso',
      salesId: r['id_sales'] as int? ?? 2,
    );
  }

  Future<PengajuanReschedule> _findById(int id) async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT r.*, t.nama_toko, p.nama AS sales_nama
      FROM pengajuan_reschedule r
      LEFT JOIN toko t ON t.no_jo = r.no_jo
      LEFT JOIN pengguna p ON p.id = r.id_sales
      WHERE r.id = ?
      LIMIT 1
    ''', [id]);
    if (rows.isEmpty) {
      throw Exception('Pengajuan reschedule tidak ditemukan.');
    }
    return _mapRow(rows.first);
  }

  @override
  Future<List<PengajuanReschedule>> list() async {
    final db = await dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT r.*, t.nama_toko, p.nama AS sales_nama
      FROM pengajuan_reschedule r
      LEFT JOIN toko t ON t.no_jo = r.no_jo
      LEFT JOIN pengguna p ON p.id = r.id_sales
      ORDER BY
        CASE WHEN r.status = 'menunggu' THEN 0 ELSE 1 END ASC,
        r.id DESC
    ''');
    return rows.map(_mapRow).toList();
  }

  @override
  Future<PengajuanReschedule> create({
    required String noJo,
    required DateTime jadwalBaru,
    required String alasan,
  }) async {
    final db = await dbHelper.database;
    final tokoRows = await db.query(
      'toko',
      where: 'no_jo = ?',
      whereArgs: [noJo],
      limit: 1,
    );
    final toko = tokoRows.isNotEmpty
        ? tokoRows.first
        : (await db.query('toko', limit: 1)).first;

    final session = await dbHelper.getActiveSession();
    final salesId =
        (session != null && session.user.role == 'sales') ? session.user.id : 2;
    final today = dbHelper.getConfig().mockToday;

    final newId = await db.insert('pengajuan_reschedule', {
      'id_sales': salesId,
      'no_jo': toko['no_jo'] as String,
      'nama_toko_snapshot': toko['nama_toko'] as String,
      'jadwal_lama': today.toIso8601String(),
      'jadwal_baru': jadwalBaru.toIso8601String(),
      'alasan': alasan.trim(),
      'status': 'menunggu',
    });

    return _findById(newId);
  }

  @override
  Future<PengajuanReschedule> setujui(int id) async {
    return _proses(id, 'disetujui');
  }

  @override
  Future<PengajuanReschedule> tolak(int id) async {
    return _proses(id, 'ditolak');
  }

  Future<PengajuanReschedule> _proses(int id, String statusBaru) async {
    final db = await dbHelper.database;
    final session = await dbHelper.getActiveSession();
    final manajerId = session?.user.id ?? 3;
    final nowIso = dbHelper.getConfig().mockToday.toIso8601String();

    await db.update(
      'pengajuan_reschedule',
      {
        'status': statusBaru,
        'id_manajer': manajerId,
        'tgl_proses': nowIso,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return _findById(id);
  }
}
