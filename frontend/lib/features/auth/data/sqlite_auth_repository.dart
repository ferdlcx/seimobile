import 'package:sqflite/sqflite.dart';

import '../../../core/database/seui_sqlite_database.dart';
import 'auth_repository.dart';

/// Implementasi SQLite persisten untuk AuthRepository.
class SqliteAuthRepository implements AuthRepository {
  final SeuiSqliteDatabase dbHelper;

  SqliteAuthRepository(this.dbHelper);

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
    required String role,
    String? mode,
  }) async {
    final db = await dbHelper.database;
    final trimmedUser = username.trim().toLowerCase();
    final rows = await db.query(
      'pengguna',
      where: 'LOWER(username) = ? AND role = ?',
      whereArgs: [trimmedUser, role],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception('Username atau password tidak sesuai dengan peran ini.');
    }

    final row = rows.first;
    final expectedHash = row['password_hash'] as String;
    if (expectedHash != SeuiSqliteDatabase.hashPassword(password)) {
      throw Exception('Username atau password tidak sesuai dengan peran ini.');
    }

    final user = SeuiSqliteDatabase.mapPenggunaRow(row);
    if (!user.aktif) {
      throw Exception('Akun ini sedang nonaktif. Hubungi Admin Tagihan.');
    }

    final resolvedMode = role == 'manajer_sales'
        ? (mode == 'sales' ? 'sales' : 'manajer')
        : role;

    final session = AuthSession(
      token: 'local-sqlite-token-${user.id}',
      user: user,
      mode: resolvedMode,
    );
    await dbHelper.saveActiveSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    await dbHelper.clearActiveSession();
  }

  @override
  Future<AuthSession?> me() async {
    return dbHelper.getActiveSession();
  }

  @override
  Future<void> updateMode(String mode) async {
    final db = await dbHelper.database;
    await db.update(
      'app_session',
      {
        'mode': mode,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  @override
  Future<void> simpanTandaTangan(String base64Signature) async {
    final db = await dbHelper.database;
    final current = await dbHelper.getActiveSession();
    final targetUserId = current?.user.id ?? 3; // Default Maya Kusuma (Manajer)
    await db.update(
      'pengguna',
      {'tanda_tangan_path': base64Signature},
      where: 'id = ?',
      whereArgs: [targetUserId],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
