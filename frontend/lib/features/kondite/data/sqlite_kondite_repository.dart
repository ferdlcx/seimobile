import 'package:sqflite/sqflite.dart';

import '../../../core/database/seui_sqlite_database.dart';
import '../../../core/utils/nilai_kondite.dart';
import 'kondite_repository.dart';
import 'models/penilaian_kondite_model.dart';

/// Implementasi SQLite persisten untuk KonditeRepository.
class SqliteKonditeRepository implements KonditeRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteKonditeRepository(this.dbHelper);

  @override
  Future<PenilaianKondite> get({
    required int salesId,
    required String periode,
  }) async {
    final db = await dbHelper.database;

    final existingRows = await db.rawQuery('''
      SELECT pk.*, p.nama AS sales_nama
      FROM penilaian_kondite pk
      LEFT JOIN pengguna p ON p.id = pk.id_sales
      WHERE pk.id_sales = ? AND pk.periode_bulan = ?
      LIMIT 1
    ''', [salesId, periode]);

    if (existingRows.isNotEmpty) {
      final header = existingRows.first;
      final idKondite = header['id_kondite'] as int;
      final detailRows = await db.query(
        'detail_penilaian',
        where: 'id_kondite = ?',
        whereArgs: [idKondite],
        orderBy: 'id_kriteria ASC',
      );
      final detail = <int, String>{
        for (final row in detailRows)
          row['id_kriteria'] as int: row['nilai'] as String,
      };

      return PenilaianKondite(
        salesId: salesId,
        salesNama: header['sales_nama'] as String? ?? 'Sales',
        periode: periode,
        detail: detail,
        nilaiAkhir: (header['nilai_akhir'] as num).toDouble(),
        label: header['label'] as String,
      );
    }

    // Jika belum pernah dinilai untuk periode ini, buat nilai awal di SQLite.
    final defaultDetail = <int, String>{
      for (int i = 1; i <= 18; i++) i: (i % 3 == 0 ? 'C' : 'B'),
    };
    return save(
      salesId: salesId,
      periode: periode,
      detail: defaultDetail,
    );
  }

  @override
  Future<PenilaianKondite> save({
    required int salesId,
    required String periode,
    required Map<int, String> detail,
  }) async {
    final db = await dbHelper.database;
    final config = dbHelper.getConfig();
    final nilaiAkhir = NilaiKonditeUtils.hitungNilaiAkhir(
      detail,
      config.bobotNilai,
    );
    final label = NilaiKonditeUtils.tentukanLabel(nilaiAkhir);

    final session = await dbHelper.getActiveSession();
    final manajerId = session?.user.id ?? 3;
    final today = config.mockToday;
    final tglStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final userRows = await db.query(
      'pengguna',
      columns: ['nama'],
      where: 'id = ?',
      whereArgs: [salesId],
      limit: 1,
    );
    final salesNama = userRows.isNotEmpty
        ? userRows.first['nama'] as String
        : 'Budi Santoso';

    await db.transaction((txn) async {
      final existing = await txn.query(
        'penilaian_kondite',
        columns: ['id_kondite'],
        where: 'id_sales = ? AND periode_bulan = ?',
        whereArgs: [salesId, periode],
        limit: 1,
      );

      final int idKondite;
      if (existing.isNotEmpty) {
        idKondite = existing.first['id_kondite'] as int;
        await txn.update(
          'penilaian_kondite',
          {
            'id_manajer': manajerId,
            'tgl_penilaian': tglStr,
            'nilai_akhir': nilaiAkhir,
            'label': label,
          },
          where: 'id_kondite = ?',
          whereArgs: [idKondite],
        );
        await txn.delete(
          'detail_penilaian',
          where: 'id_kondite = ?',
          whereArgs: [idKondite],
        );
      } else {
        idKondite = await txn.insert('penilaian_kondite', {
          'id_sales': salesId,
          'id_manajer': manajerId,
          'periode_bulan': periode,
          'tgl_penilaian': tglStr,
          'nilai_akhir': nilaiAkhir,
          'label': label,
        });
      }

      for (final entry in detail.entries) {
        await txn.insert(
          'detail_penilaian',
          {
            'id_kondite': idKondite,
            'id_kriteria': entry.key,
            'nilai': entry.value,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    return PenilaianKondite(
      salesId: salesId,
      salesNama: salesNama,
      periode: periode,
      detail: Map<int, String>.from(detail),
      nilaiAkhir: nilaiAkhir,
      label: label,
    );
  }

  @override
  Future<PenilaianKondite> saya() async {
    final session = await dbHelper.getActiveSession();
    final salesId =
        (session != null && session.user.role == 'sales') ? session.user.id : 2;
    return get(salesId: salesId, periode: '2026-10');
  }
}
