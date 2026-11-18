import 'package:sqflite/sqflite.dart';

import '../../../core/database/seui_sqlite_database.dart';
import '../../admin_data/data/models/master_models.dart';
import '../../admin_data/data/sqlite_master_repository.dart';
import 'mapping_repository.dart';
import 'models/mapping_toko_model.dart';

/// Implementasi SQLite persisten untuk MappingRepository.
class SqliteMappingRepository implements MappingRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteMappingRepository(this.dbHelper);

  static const _polaDefault = <List<bool>>[
    [false, true, true, false, true, true, false, true, true, true, true, true],
    [true, true, false, true, true, false, true, true, false, true, true, false],
    [true, false, true, true, false, true, true, false, true, true, false, true],
  ];

  @override
  Future<List<MappingToko>> get({
    required int salesId,
    required int tahun,
    int? wilayahId,
  }) async {
    final db = await dbHelper.database;
    final today = dbHelper.getConfig().mockToday;
    final ym = '${today.year}-${today.month.toString().padLeft(2, '0')}';

    // Pastikan setiap toko sudah punya baris mapping untuk (salesId, tahun).
    final existingCountRows = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM mapping_toko WHERE id_sales = ? AND tahun = ?',
      [salesId, tahun],
    );
    final existingCount =
        (existingCountRows.first['cnt'] as int?) ?? 0;

    final missingTokoRows = await db.rawQuery('''
      SELECT no_jo FROM toko
      WHERE no_jo NOT IN (
        SELECT no_jo FROM mapping_toko WHERE id_sales = ? AND tahun = ?
      )
      ORDER BY rowid ASC
    ''', [salesId, tahun]);

    if (missingTokoRows.isNotEmpty) {
      await db.transaction((txn) async {
        for (int i = 0; i < missingTokoRows.length; i++) {
          final noJo = missingTokoRows[i]['no_jo'] as String;
          final idMapping = await txn.insert('mapping_toko', {
            'id_admin': 1,
            'id_sales': salesId,
            'no_jo': noJo,
            'tahun': tahun,
          });
          if (existingCount == 0) {
            final rencana = _polaDefault[i % _polaDefault.length];
            for (int m = 0; m < 12; m++) {
              final planned = rencana[m];
              final realized = !planned ? false : (m < 9);
              await txn.insert('mapping_bulan', {
                'id_mapping': idMapping,
                'bulan': m + 1,
                'direncanakan': planned ? 1 : 0,
                'terealisasi': realized ? 1 : 0,
              });
            }
          } else {
            for (int m = 1; m <= 12; m++) {
              await txn.insert('mapping_bulan', {
                'id_mapping': idMapping,
                'bulan': m,
                'direncanakan': 1,
                'terealisasi': 0,
              });
            }
          }
        }
      });
    }

    final whereClauses = <String>['mt.id_sales = ?', 'mt.tahun = ?'];
    final args = <Object?>[ym, salesId, tahun];
    if (wilayahId != null) {
      whereClauses.add('t.id_wilayah = ?');
      args.add(wilayahId);
    }

    final rows = await db.rawQuery('''
      SELECT
        mt.id_mapping,
        mt.id_sales,
        mt.tahun,
        t.*,
        w.nama_wilayah,
        CASE
          WHEN EXISTS (
            SELECT 1 FROM jurnal_kunjungan j
            WHERE j.no_jo = t.no_jo
              AND j.status = 'final'
              AND substr(j.tgl_kunjungan, 1, 7) = ?
          )
          THEN 1 ELSE 0
        END AS sudah_dikunjungi
      FROM mapping_toko mt
      INNER JOIN toko t ON t.no_jo = mt.no_jo
      INNER JOIN wilayah w ON w.id_wilayah = t.id_wilayah
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY mt.id_mapping ASC
    ''', args);

    final result = <MappingToko>[];
    for (final r in rows) {
      final idMapping = r['id_mapping'] as int;
      final bulanRows = await db.query(
        'mapping_bulan',
        where: 'id_mapping = ?',
        whereArgs: [idMapping],
        orderBy: 'bulan ASC',
      );
      final bulan = List<bool>.filled(12, false);
      final terealisasi = List<bool>.filled(12, false);
      for (final b in bulanRows) {
        final idx = ((b['bulan'] as int) - 1).clamp(0, 11);
        bulan[idx] = (b['direncanakan'] as int? ?? 0) == 1;
        terealisasi[idx] = (b['terealisasi'] as int? ?? 0) == 1;
      }

      final tokoBase = SqliteMasterRepository.mapTokoRow(r);
      final toko = tokoBase.copyWith(
        sudahDikunjungiBulanIni:
            tokoBase.sudahDikunjungiBulanIni || terealisasi[today.month - 1],
      );

      result.add(
        MappingToko(
          idMapping: idMapping,
          idSales: r['id_sales'] as int,
          tahun: r['tahun'] as int,
          toko: toko,
          bulan: bulan,
          terealisasi: terealisasi,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> save(List<MappingToko> items) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      for (final item in items) {
        for (int m = 0; m < 12; m++) {
          await txn.insert(
            'mapping_bulan',
            {
              'id_mapping': item.idMapping,
              'bulan': m + 1,
              'direncanakan': item.bulan[m] ? 1 : 0,
              'terealisasi': item.terealisasi[m] ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  @override
  Future<MappingHariIniData> hariIni({int? wilayahId}) async {
    final db = await dbHelper.database;
    final today = dbHelper.getConfig().mockToday;
    final ym = '${today.year}-${today.month.toString().padLeft(2, '0')}';

    final session = await dbHelper.getActiveSession();
    final salesId =
        (session != null && session.user.role == 'sales') ? session.user.id : 2;

    // Pastikan mapping untuk tahun berjalan tersedia.
    await get(salesId: salesId, tahun: today.year);

    final rows = await db.rawQuery('''
      SELECT
        t.*,
        w.nama_wilayah,
        CASE
          WHEN mb.terealisasi = 1 OR EXISTS (
            SELECT 1 FROM jurnal_kunjungan j
            WHERE j.no_jo = t.no_jo
              AND j.status = 'final'
              AND substr(j.tgl_kunjungan, 1, 7) = ?
          )
          THEN 1 ELSE 0
        END AS sudah_dikunjungi
      FROM mapping_toko mt
      INNER JOIN mapping_bulan mb ON mb.id_mapping = mt.id_mapping
      INNER JOIN toko t ON t.no_jo = mt.no_jo
      INNER JOIN wilayah w ON w.id_wilayah = t.id_wilayah
      WHERE mt.id_sales = ?
        AND mt.tahun = ?
        AND mb.bulan = ?
        AND mb.direncanakan = 1
      ORDER BY mt.id_mapping ASC
    ''', [ym, salesId, today.year, today.month]);

    final allPlannedToko = rows.map(SqliteMasterRepository.mapTokoRow).toList();
    final totalTarget = allPlannedToko.length;
    final sudahDikunjungi =
        allPlannedToko.where((t) => t.sudahDikunjungiBulanIni).length;

    final List<Toko> filtered = wilayahId == null
        ? allPlannedToko
        : allPlannedToko.where((t) => t.wilayah.id == wilayahId).toList();

    return MappingHariIniData(
      daftarToko: filtered,
      sudahDikunjungi: sudahDikunjungi,
      totalTarget: totalTarget,
    );
  }
}
