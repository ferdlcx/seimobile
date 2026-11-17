import '../../../core/database/seui_sqlite_database.dart';
import 'master_repository.dart';
import 'models/master_models.dart';

/// Implementasi SQLite persisten untuk MasterRepository.
class SqliteMasterRepository implements MasterRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteMasterRepository(this.dbHelper);

  @override
  Future<List<Wilayah>> wilayah() async {
    final db = await dbHelper.database;
    final rows = await db.query('wilayah', orderBy: 'id_wilayah ASC');
    return rows
        .map(
          (r) => Wilayah(
            id: r['id_wilayah'] as int,
            nama: r['nama_wilayah'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<List<Toko>> tokoList({int? wilayahId, String? q}) async {
    final db = await dbHelper.database;
    final today = dbHelper.getConfig().mockToday;
    final ym = '${today.year}-${today.month.toString().padLeft(2, '0')}';

    final whereClauses = <String>[];
    final args = <Object?>[ym, today.year, today.month];

    if (wilayahId != null) {
      whereClauses.add('t.id_wilayah = ?');
      args.add(wilayahId);
    }
    if (q != null && q.trim().isNotEmpty) {
      final like = '%${q.trim().toLowerCase()}%';
      whereClauses.add('(LOWER(t.nama_toko) LIKE ? OR LOWER(t.no_jo) LIKE ?)');
      args.add(like);
      args.add(like);
    }

    final whereSql =
        whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final rows = await db.rawQuery('''
      SELECT
        t.*,
        w.nama_wilayah,
        CASE
          WHEN EXISTS (
            SELECT 1 FROM jurnal_kunjungan j
            WHERE j.no_jo = t.no_jo
              AND j.status = 'final'
              AND substr(j.tgl_kunjungan, 1, 7) = ?
          ) OR EXISTS (
            SELECT 1 FROM mapping_toko mt
            INNER JOIN mapping_bulan mb ON mb.id_mapping = mt.id_mapping
            WHERE mt.no_jo = t.no_jo
              AND mt.tahun = ?
              AND mb.bulan = ?
              AND mb.terealisasi = 1
          )
          THEN 1 ELSE 0
        END AS sudah_dikunjungi
      FROM toko t
      INNER JOIN wilayah w ON w.id_wilayah = t.id_wilayah
      $whereSql
      ORDER BY t.rowid ASC
    ''', args);

    return rows.map(mapTokoRow).toList();
  }

  /// Konversi baris join `toko` + `wilayah` menjadi model [Toko].
  static Toko mapTokoRow(Map<String, Object?> r) {
    return Toko(
      noJo: r['no_jo'] as String,
      nama: r['nama_toko'] as String,
      alamat: r['alamat'] as String? ?? '',
      ket: r['ket_toko'] as String? ?? '',
      wilayah: Wilayah(
        id: r['id_wilayah'] as int,
        nama: r['nama_wilayah'] as String? ?? '',
      ),
      lat: (r['latitude'] as num).toDouble(),
      lng: (r['longitude'] as num).toDouble(),
      sudahDikunjungiBulanIni: (r['sudah_dikunjungi'] as int? ?? 0) == 1,
      hariSejakKunjunganTerakhir:
          r['hari_sejak_kunjungan_terakhir'] as int? ?? 0,
    );
  }

  @override
  Future<Toko> tokoCreate({
    required String noJo,
    required String nama,
    required int wilayahId,
    required String alamat,
    String ket = '',
    double? lat,
    double? lng,
  }) async {
    final db = await dbHelper.database;
    final upperJo = noJo.trim().toUpperCase();
    final existing = await db.query(
      'toko',
      columns: ['no_jo'],
      where: 'UPPER(no_jo) = ?',
      whereArgs: [upperJo],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('Nomor JO "${noJo.trim()}" sudah terdaftar.');
    }

    final wilayahRows = await db.query(
      'wilayah',
      where: 'id_wilayah = ?',
      whereArgs: [wilayahId],
      limit: 1,
    );
    final wilayahRow = wilayahRows.isNotEmpty
        ? wilayahRows.first
        : (await db.query('wilayah', orderBy: 'id_wilayah ASC', limit: 1)).first;
    final resolvedWilayahId = wilayahRow['id_wilayah'] as int;
    final resolvedLat = lat ?? -7.4250;
    final resolvedLng = lng ?? 109.2350;
    final todayYear = dbHelper.getConfig().mockToday.year;

    await db.transaction((txn) async {
      await txn.insert('toko', {
        'no_jo': upperJo,
        'id_wilayah': resolvedWilayahId,
        'nama_toko': nama.trim(),
        'alamat': alamat.trim(),
        'ket_toko': ket.trim(),
        'latitude': resolvedLat,
        'longitude': resolvedLng,
        'hari_sejak_kunjungan_terakhir': 0,
      });

      final idMapping = await txn.insert('mapping_toko', {
        'id_admin': 1,
        'id_sales': 2,
        'no_jo': upperJo,
        'tahun': todayYear,
      });
      for (int m = 1; m <= 12; m++) {
        await txn.insert('mapping_bulan', {
          'id_mapping': idMapping,
          'bulan': m,
          'direncanakan': 1,
          'terealisasi': 0,
        });
      }
    });

    return Toko(
      noJo: upperJo,
      nama: nama.trim(),
      alamat: alamat.trim(),
      ket: ket.trim(),
      wilayah: Wilayah(
        id: resolvedWilayahId,
        nama: wilayahRow['nama_wilayah'] as String,
      ),
      lat: resolvedLat,
      lng: resolvedLng,
      sudahDikunjungiBulanIni: false,
      hariSejakKunjunganTerakhir: 0,
    );
  }

  @override
  Future<List<Kriteria>> kriteria() async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'kriteria_kondite',
      orderBy: 'urutan ASC',
    );
    return rows
        .map(
          (r) => Kriteria(
            id: r['id_kriteria'] as int,
            urutan: r['urutan'] as int,
            nama: r['nama'] as String,
            aktif: (r['aktif'] as int? ?? 1) == 1,
          ),
        )
        .toList();
  }

  @override
  Future<Kriteria> updateKriteria(
    int id, {
    required String nama,
    bool? aktif,
  }) async {
    final db = await dbHelper.database;
    final values = <String, Object?>{'nama': nama.trim()};
    if (aktif != null) {
      values['aktif'] = aktif ? 1 : 0;
    }
    await db.update(
      'kriteria_kondite',
      values,
      where: 'id_kriteria = ?',
      whereArgs: [id],
    );
    final rows = await db.query(
      'kriteria_kondite',
      where: 'id_kriteria = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Kriteria tidak ditemukan.');
    }
    final r = rows.first;
    return Kriteria(
      id: r['id_kriteria'] as int,
      urutan: r['urutan'] as int,
      nama: r['nama'] as String,
      aktif: (r['aktif'] as int? ?? 1) == 1,
    );
  }
}
