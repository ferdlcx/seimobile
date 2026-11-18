import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/models/pengguna_model.dart';
import '../config/app_config.dart';

/// Database SQLite persisten murni Dart/Flutter untuk S.E.U.I Centre.
/// Mengimplementasikan skema relasional pada docs/03-model-data.md
/// serta menyimpan data secara permanen di perangkat tanpa membutuhkan backend PHP.
class SeuiSqliteDatabase {
  final AppConfig Function() getConfig;
  final DatabaseFactory? factoryOverride;
  final String? dbPathOverride;

  Database? _db;
  Future<Database>? _openingFuture;

  SeuiSqliteDatabase({
    required this.getConfig,
    this.factoryOverride,
    this.dbPathOverride,
  });

  /// Hash kata sandi menggunakan SHA-256 dengan salt aplikasi.
  static String hashPassword(String plain) {
    final bytes = utf8.encode('seui-centre:$plain');
    return sha256.convert(bytes).toString();
  }

  /// Cek apakah berjalan di lingkungan `flutter test` agar memakai DB memori terisolasi.
  static bool get _isFlutterTest =>
      Platform.environment.containsKey('FLUTTER_TEST');

  /// Membuka atau mengembalikan instance Database SQLite yang sudah terinisialisasi.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    if (_openingFuture != null) {
      return _openingFuture!;
    }
    _openingFuture = _open();
    try {
      _db = await _openingFuture!;
      return _db!;
    } finally {
      _openingFuture = null;
    }
  }

  Future<Database> _open() async {
    final factory = factoryOverride ?? databaseFactory;
    final String path;
    final bool isInMemory;

    if (dbPathOverride != null) {
      path = dbPathOverride!;
      isInMemory = path == inMemoryDatabasePath;
    } else if (_isFlutterTest) {
      path = inMemoryDatabasePath;
      isInMemory = true;
    } else {
      final dir = await factory.getDatabasesPath();
      path = p.join(dir, 'seui_centre.db');
      isInMemory = false;
    }

    final options = OpenDatabaseOptions(
      version: 2,
      singleInstance: !isInMemory,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE jurnal_kunjungan ADD COLUMN jenis_aktivitas TEXT NOT NULL DEFAULT 'Kunjungan & Order'",
          );
        }
      },
    );

    return factory.openDatabase(path, options: options);
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE wilayah (
        id_wilayah INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_wilayah TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE toko (
        no_jo TEXT PRIMARY KEY,
        id_wilayah INTEGER NOT NULL,
        nama_toko TEXT NOT NULL,
        alamat TEXT NOT NULL,
        ket_toko TEXT NOT NULL DEFAULT '',
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        hari_sejak_kunjungan_terakhir INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id_wilayah) REFERENCES wilayah(id_wilayah)
      )
    ''');

    await db.execute('''
      CREATE TABLE pengguna (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        aktif INTEGER NOT NULL DEFAULT 1,
        tanda_tangan_path TEXT,
        is_baru INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE mapping_toko (
        id_mapping INTEGER PRIMARY KEY AUTOINCREMENT,
        id_admin INTEGER NOT NULL,
        id_sales INTEGER NOT NULL,
        no_jo TEXT NOT NULL,
        tahun INTEGER NOT NULL,
        UNIQUE(id_sales, no_jo, tahun),
        FOREIGN KEY (id_admin) REFERENCES pengguna(id),
        FOREIGN KEY (id_sales) REFERENCES pengguna(id),
        FOREIGN KEY (no_jo) REFERENCES toko(no_jo)
      )
    ''');

    await db.execute('''
      CREATE TABLE mapping_bulan (
        id_mapping INTEGER NOT NULL,
        bulan INTEGER NOT NULL,
        direncanakan INTEGER NOT NULL DEFAULT 0,
        terealisasi INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (id_mapping, bulan),
        FOREIGN KEY (id_mapping) REFERENCES mapping_toko(id_mapping) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE jurnal_kunjungan (
        id_kunjungan INTEGER PRIMARY KEY AUTOINCREMENT,
        id_mapping INTEGER,
        id_sales INTEGER NOT NULL,
        no_jo TEXT NOT NULL,
        tgl_kunjungan TEXT NOT NULL,
        status_order TEXT NOT NULL,
        jenis_aktivitas TEXT NOT NULL DEFAULT 'Kunjungan & Order',
        ket_aktivitas TEXT NOT NULL DEFAULT '',
        foto_display_path TEXT,
        foto_nota_po_path TEXT,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        jarak_checkin_m REAL NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (id_mapping) REFERENCES mapping_toko(id_mapping),
        FOREIGN KEY (id_sales) REFERENCES pengguna(id),
        FOREIGN KEY (no_jo) REFERENCES toko(no_jo)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_jurnal_sales_tgl
      ON jurnal_kunjungan (id_sales, tgl_kunjungan)
    ''');

    await db.execute('''
      CREATE INDEX idx_jurnal_toko_tgl
      ON jurnal_kunjungan (no_jo, tgl_kunjungan)
    ''');

    await db.execute('''
      CREATE TABLE kriteria_kondite (
        id_kriteria INTEGER PRIMARY KEY AUTOINCREMENT,
        urutan INTEGER NOT NULL,
        nama TEXT NOT NULL,
        aktif INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE penilaian_kondite (
        id_kondite INTEGER PRIMARY KEY AUTOINCREMENT,
        id_sales INTEGER NOT NULL,
        id_manajer INTEGER NOT NULL,
        periode_bulan TEXT NOT NULL,
        tgl_penilaian TEXT NOT NULL,
        nilai_akhir REAL NOT NULL,
        label TEXT NOT NULL,
        UNIQUE(id_sales, periode_bulan),
        FOREIGN KEY (id_sales) REFERENCES pengguna(id),
        FOREIGN KEY (id_manajer) REFERENCES pengguna(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE detail_penilaian (
        id_kondite INTEGER NOT NULL,
        id_kriteria INTEGER NOT NULL,
        nilai TEXT NOT NULL,
        PRIMARY KEY (id_kondite, id_kriteria),
        FOREIGN KEY (id_kondite) REFERENCES penilaian_kondite(id_kondite) ON DELETE CASCADE,
        FOREIGN KEY (id_kriteria) REFERENCES kriteria_kondite(id_kriteria)
      )
    ''');

    await db.execute('''
      CREATE TABLE pengajuan_reschedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_sales INTEGER NOT NULL,
        no_jo TEXT NOT NULL,
        nama_toko_snapshot TEXT,
        jadwal_lama TEXT NOT NULL,
        jadwal_baru TEXT NOT NULL,
        alasan TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'menunggu',
        id_manajer INTEGER,
        tgl_proses TEXT,
        FOREIGN KEY (id_sales) REFERENCES pengguna(id),
        FOREIGN KEY (no_jo) REFERENCES toko(no_jo)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER NOT NULL,
        token TEXT NOT NULL,
        mode TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES pengguna(id)
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    final defaultPassHash = hashPassword('password123');

    await db.transaction((txn) async {
      // 1. Pengguna awal
      await txn.insert('pengguna', {
        'id': 1,
        'nama': 'Andi Pratama',
        'username': 'andi.tagihan',
        'password_hash': defaultPassHash,
        'role': 'admin_tagihan',
        'aktif': 1,
        'is_baru': 0,
      });
      await txn.insert('pengguna', {
        'id': 2,
        'nama': 'Budi Santoso',
        'username': 'budi.santoso',
        'password_hash': defaultPassHash,
        'role': 'sales',
        'aktif': 1,
        'is_baru': 0,
      });
      await txn.insert('pengguna', {
        'id': 3,
        'nama': 'Maya Kusuma',
        'username': 'maya.kusuma',
        'password_hash': defaultPassHash,
        'role': 'manajer_sales',
        'aktif': 1,
        'is_baru': 0,
      });
      await txn.insert('pengguna', {
        'id': 4,
        'nama': 'Dewi Lestari',
        'username': 'dewi.lestari',
        'password_hash': defaultPassHash,
        'role': 'sales',
        'aktif': 0,
        'is_baru': 0,
      });

      // 2. Wilayah Purwokerto
      await txn.insert('wilayah', {
        'id_wilayah': 1,
        'nama_wilayah': 'Purwokerto Timur',
      });
      await txn.insert('wilayah', {
        'id_wilayah': 2,
        'nama_wilayah': 'Purwokerto Barat',
      });
      await txn.insert('wilayah', {
        'id_wilayah': 3,
        'nama_wilayah': 'Purwokerto Selatan',
      });
      await txn.insert('wilayah', {
        'id_wilayah': 4,
        'nama_wilayah': 'Sokaraja',
      });

      // 3. Toko pelanggan (6 toko)
      final seedToko = [
        {
          'no_jo': 'JO-0412',
          'id_wilayah': 1,
          'nama_toko': 'Toko Makmur Jaya',
          'alamat': 'Jl. Jenderal Sudirman No. 45, Purwokerto Timur',
          'ket_toko': 'Pelanggan rutin suku cadang motor',
          'latitude': -7.4243,
          'longitude': 109.2391,
          'hari_sejak_kunjungan_terakhir': 2,
        },
        {
          'no_jo': 'JO-0388',
          'id_wilayah': 1,
          'nama_toko': 'Toko Sumber Rejeki',
          'alamat': 'Jl. Gatot Subroto No. 12, Purwokerto Timur',
          'ket_toko': 'Fokus oli dan kampas rem',
          'latitude': -7.4215,
          'longitude': 109.2410,
          'hari_sejak_kunjungan_terakhir': 4,
        },
        {
          'no_jo': 'JO-0501',
          'id_wilayah': 4,
          'nama_toko': 'Toko Bintang Terang',
          'alamat': 'Jl. Contoh No. 18, Sokaraja',
          'ket_toko': 'Toko besar area Sokaraja',
          'latitude': -7.4562,
          'longitude': 109.2865,
          'hari_sejak_kunjungan_terakhir': 20,
        },
        {
          'no_jo': 'JO-0375',
          'id_wilayah': 2,
          'nama_toko': 'Toko Berkah Abadi',
          'alamat': 'Jl. Kober No. 88, Purwokerto Barat',
          'ket_toko': 'Rutin order awal/akhir bulan',
          'latitude': -7.4180,
          'longitude': 109.2150,
          'hari_sejak_kunjungan_terakhir': 34,
        },
        {
          'no_jo': 'JO-0420',
          'id_wilayah': 2,
          'nama_toko': 'Toko Sentosa Abadi',
          'alamat': 'Jl. KS Tubun No. 21, Purwokerto Barat',
          'ket_toko': 'Sparepart umum',
          'latitude': -7.4201,
          'longitude': 109.2122,
          'hari_sejak_kunjungan_terakhir': 1,
        },
        {
          'no_jo': 'JO-0433',
          'id_wilayah': 3,
          'nama_toko': 'Toko Harapan Jaya',
          'alamat': 'Jl. DI Panjaitan No. 60, Purwokerto Selatan',
          'ket_toko': 'Langganan ban dan rantai',
          'latitude': -7.4410,
          'longitude': 109.2380,
          'hari_sejak_kunjungan_terakhir': 3,
        },
      ];
      for (final row in seedToko) {
        await txn.insert('toko', row);
      }

      // 4. 18 Kriteria Kondite
      const kriteriaNames = [
        'Kehadiran dan jam kunjungan',
        'Kesesuaian prosedur',
        'Respon toko',
        'Target dan efektivitas',
        'Kepatuhan mapping',
        'Ketepatan check-in',
        'Kriteria 7',
        'Kriteria 8',
        'Kriteria 9',
        'Kriteria 10',
        'Kriteria 11',
        'Kriteria 12',
        'Kriteria 13',
        'Kriteria 14',
        'Kriteria 15',
        'Kriteria 16',
        'Kriteria 17',
        'Kriteria 18',
      ];
      for (int i = 0; i < kriteriaNames.length; i++) {
        await txn.insert('kriteria_kondite', {
          'id_kriteria': i + 1,
          'urutan': i + 1,
          'nama': kriteriaNames[i],
          'aktif': 1,
        });
      }

      // 5. Mapping Toko & Mapping Bulan (2026 untuk Budi Santoso id_sales=2)
      const polaBulan = <List<bool>>[
        [false, true, true, false, true, true, false, true, true, true, true, true],
        [true, true, false, true, true, false, true, true, false, true, true, false],
        [true, false, true, true, false, true, true, false, true, true, false, true],
        [false, true, true, false, true, true, false, true, true, true, true, true],
        [true, true, false, true, true, false, true, true, false, true, true, false],
        [true, false, true, true, false, true, true, false, true, true, false, true],
      ];
      const visitedInOct = [true, true, false, false, true, true];

      for (int i = 0; i < seedToko.length; i++) {
        final noJo = seedToko[i]['no_jo'] as String;
        final idMapping = await txn.insert('mapping_toko', {
          'id_admin': 1,
          'id_sales': 2,
          'no_jo': noJo,
          'tahun': 2026,
        });
        final rencana = polaBulan[i % polaBulan.length];
        for (int m = 0; m < 12; m++) {
          final planned = rencana[m];
          final realized = !planned
              ? false
              : (m < 9 ? true : (m == 9 ? visitedInOct[i] : false));
          await txn.insert('mapping_bulan', {
            'id_mapping': idMapping,
            'bulan': m + 1,
            'direncanakan': planned ? 1 : 0,
            'terealisasi': realized ? 1 : 0,
          });
        }
      }

      // 6. Jurnal Kunjungan awal (4 final di Oktober 2026)
      final seedJurnal = [
        {
          'id_mapping': 1,
          'id_sales': 2,
          'no_jo': 'JO-0412',
          'tgl_kunjungan': '2026-10-28T09:30:00.000',
          'status_order': 'ada_order',
          'ket_aktivitas': 'Order rutin kampas rem 10 set dan oli mesin.',
          'foto_display_path': 'mock_display_0412.jpg',
          'foto_nota_po_path': 'mock_nota_0412.jpg',
          'lat': -7.4243,
          'lng': 109.2391,
          'jarak_checkin_m': 10.5,
          'status': 'final',
        },
        {
          'id_mapping': 2,
          'id_sales': 2,
          'no_jo': 'JO-0388',
          'tgl_kunjungan': '2026-10-26T11:15:00.000',
          'status_order': 'ada_order',
          'ket_aktivitas': 'Repeat order busi dan filter udara.',
          'foto_display_path': 'mock_display_0388.jpg',
          'foto_nota_po_path': 'mock_nota_0388.jpg',
          'lat': -7.4215,
          'lng': 109.2410,
          'jarak_checkin_m': 14.0,
          'status': 'final',
        },
        {
          'id_mapping': 5,
          'id_sales': 2,
          'no_jo': 'JO-0420',
          'tgl_kunjungan': '2026-10-29T14:00:00.000',
          'status_order': 'tidak_ada_order',
          'ket_aktivitas': 'Stok toko masih penuh, dijadwalkan cek bulan depan.',
          'foto_display_path': 'mock_display_0420.jpg',
          'foto_nota_po_path': null,
          'lat': -7.4201,
          'lng': 109.2122,
          'jarak_checkin_m': 18.2,
          'status': 'final',
        },
        {
          'id_mapping': 6,
          'id_sales': 2,
          'no_jo': 'JO-0433',
          'tgl_kunjungan': '2026-10-27T10:00:00.000',
          'status_order': 'ada_order',
          'ket_aktivitas': 'Order ban luar 5 pcs.',
          'foto_display_path': 'mock_display_0433.jpg',
          'foto_nota_po_path': 'mock_nota_0433.jpg',
          'lat': -7.4410,
          'lng': 109.2380,
          'jarak_checkin_m': 8.4,
          'status': 'final',
        },
      ];
      for (final row in seedJurnal) {
        await txn.insert('jurnal_kunjungan', row);
      }

      // 7. Pengajuan Reschedule awal
      final seedReschedule = [
        {
          'id': 1,
          'id_sales': 2,
          'no_jo': 'JO-0375',
          'nama_toko_snapshot': 'Toko Berkah Abadi',
          'jadwal_lama': '2026-10-30T00:00:00.000',
          'jadwal_baru': '2026-11-03T00:00:00.000',
          'alasan': 'Pemilik toko sedang keluar kota.',
          'status': 'menunggu',
        },
        {
          'id': 2,
          'id_sales': 2,
          'no_jo': 'JO-0501',
          'nama_toko_snapshot': 'Toko Bintang Terang',
          'jadwal_lama': '2026-10-30T00:00:00.000',
          'jadwal_baru': '2026-11-04T00:00:00.000',
          'alasan': 'Jadwal bentrok dengan rute.',
          'status': 'menunggu',
        },
        {
          'id': 3,
          'id_sales': 2,
          'no_jo': 'JO-0420',
          'nama_toko_snapshot': 'Toko Sentosa Abadi',
          'jadwal_lama': '2026-10-25T00:00:00.000',
          'jadwal_baru': '2026-11-04T00:00:00.000',
          'alasan': 'Jadwal bentrok dengan rute Sokaraja.',
          'status': 'ditolak',
          'id_manajer': 3,
          'tgl_proses': '2026-10-25T15:00:00.000',
        },
        {
          'id': 4,
          'id_sales': 2,
          'no_jo': 'JO-0412',
          'nama_toko_snapshot': 'Toko Cahaya Mulia',
          'jadwal_lama': '2026-10-22T00:00:00.000',
          'jadwal_baru': '2026-11-05T00:00:00.000',
          'alasan': 'Jadwal diperbarui atas permintaan toko.',
          'status': 'disetujui',
          'id_manajer': 3,
          'tgl_proses': '2026-10-22T14:30:00.000',
        },
      ];
      for (final row in seedReschedule) {
        await txn.insert('pengajuan_reschedule', row);
      }

      // 8. Penilaian Kondite Budi Santoso (10 B + 8 C = 88.9 BAIK)
      final idKondite = await txn.insert('penilaian_kondite', {
        'id_sales': 2,
        'id_manajer': 3,
        'periode_bulan': '2026-10',
        'tgl_penilaian': '2026-10-30',
        'nilai_akhir': 88.9,
        'label': 'BAIK',
      });
      const detailBudi = <int, String>{
        1: 'B',
        2: 'B',
        3: 'C',
        4: 'B',
        5: 'B',
        6: 'C',
        7: 'B',
        8: 'B',
        9: 'C',
        10: 'B',
        11: 'C',
        12: 'B',
        13: 'C',
        14: 'B',
        15: 'C',
        16: 'B',
        17: 'C',
        18: 'C',
      };
      for (final entry in detailBudi.entries) {
        await txn.insert('detail_penilaian', {
          'id_kondite': idKondite,
          'id_kriteria': entry.key,
          'nilai': entry.value,
        });
      }
    });
  }

  /// Konversi baris tabel `pengguna` ke model [Pengguna].
  static Pengguna mapPenggunaRow(Map<String, Object?> row) {
    return Pengguna(
      id: row['id'] as int,
      nama: row['nama'] as String,
      username: row['username'] as String,
      role: row['role'] as String,
      aktif: (row['aktif'] as int? ?? 1) == 1,
      isBaru: (row['is_baru'] as int? ?? 0) == 1,
      tandaTanganBase64: row['tanda_tangan_path'] as String?,
    );
  }

  /// Ambil sesi login aktif yang tersimpan di tabel `app_session`.
  Future<AuthSession?> getActiveSession() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT s.token, s.mode, p.*
      FROM app_session s
      INNER JOIN pengguna p ON p.id = s.user_id
      WHERE s.id = 1
      LIMIT 1
    ''');
    if (rows.isEmpty) return null;
    final row = rows.first;
    return AuthSession(
      token: row['token'] as String,
      user: mapPenggunaRow(row),
      mode: row['mode'] as String,
    );
  }

  /// Simpan atau perbarui sesi login aktif di tabel `app_session`.
  Future<void> saveActiveSession(AuthSession session) async {
    final db = await database;
    await db.insert(
      'app_session',
      {
        'id': 1,
        'user_id': session.user.id,
        'token': session.token,
        'mode': session.mode,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Hapus sesi login aktif saat logout.
  Future<void> clearActiveSession() async {
    final db = await database;
    await db.delete('app_session', where: 'id = ?', whereArgs: [1]);
  }
}
