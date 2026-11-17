import '../../../core/database/seui_sqlite_database.dart';
import '../../auth/data/models/pengguna_model.dart';
import 'akun_repository.dart';

/// Implementasi SQLite persisten untuk AkunRepository.
class SqliteAkunRepository implements AkunRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteAkunRepository(this.dbHelper);

  @override
  Future<List<Pengguna>> list() async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'pengguna',
      orderBy: 'is_baru DESC, id ASC',
    );
    return rows.map(SeuiSqliteDatabase.mapPenggunaRow).toList();
  }

  @override
  Future<Pengguna> create({
    required String nama,
    required String username,
    required String password,
    required String role,
    required bool aktif,
  }) async {
    final db = await dbHelper.database;
    final trimmedUsername = username.trim();
    final existing = await db.query(
      'pengguna',
      columns: ['id'],
      where: 'LOWER(username) = ?',
      whereArgs: [trimmedUsername.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('Username "$username" sudah digunakan.');
    }

    final newId = await db.transaction((txn) async {
      await txn.update('pengguna', {'is_baru': 0});
      return txn.insert('pengguna', {
        'nama': nama.trim(),
        'username': trimmedUsername,
        'password_hash': SeuiSqliteDatabase.hashPassword(password),
        'role': role,
        'aktif': aktif ? 1 : 0,
        'is_baru': 1,
      });
    });

    final rows = await db.query(
      'pengguna',
      where: 'id = ?',
      whereArgs: [newId],
      limit: 1,
    );
    return SeuiSqliteDatabase.mapPenggunaRow(rows.first);
  }

  @override
  Future<Pengguna> setAktif(int id, bool aktif) async {
    final db = await dbHelper.database;
    await db.update(
      'pengguna',
      {'aktif': aktif ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    final rows = await db.query(
      'pengguna',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Akun tidak ditemukan.');
    }
    return SeuiSqliteDatabase.mapPenggunaRow(rows.first);
  }
}
