import 'dart:math' as math;
import '../../features/admin_data/data/models/master_models.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/models/pengguna_model.dart';
import '../../features/kondite/data/models/penilaian_kondite_model.dart';
import '../../features/kunjungan/data/models/jurnal_kunjungan_model.dart';
import '../../features/mapping/data/models/mapping_toko_model.dart';
import '../../features/reschedule/data/models/pengajuan_reschedule_model.dart';
import '../config/app_config.dart';

/// Penyimpanan in-memory tunggal (shared state) untuk seluruh Mock Repository.
/// Semua mutasi (tambah toko, simpan mapping, simpan jurnal, approval reschedule,
/// simpan kondite) langsung tercermin lintas fitur dan peran.
class MockDatabase {
  final AppConfig Function() getConfig;
  final math.Random _rng = math.Random();

  AuthSession? currentSession;

  late List<Pengguna> akunList;
  late List<Wilayah> wilayahList;
  late List<Toko> tokoList;
  late List<Kriteria> kriteriaList;
  late List<MappingToko> mappingList;
  late List<JurnalKunjungan> jurnalList;
  final Map<String, JurnalKunjungan> draftByNoJo = {};
  late List<PengajuanReschedule> rescheduleList;
  late Map<String, PenilaianKondite> konditeMap; // key: '$salesId-$periode'

  MockDatabase({required this.getConfig}) {
    resetToSeed();
  }

  /// Simulasi jeda jaringan 400–800 ms dan ±5% kegagalan acak bila diaktifkan di AppConfig.
  Future<void> simulateNetworkDelay() async {
    final config = getConfig();
    final ms = 400 + _rng.nextInt(401);
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (config.enableMockRandomError && _rng.nextDouble() < 0.05) {
      throw Exception(
        'Gagal memuat data dari server (simulasi gangguan jaringan). Silakan coba lagi.',
      );
    }
  }

  void resetToSeed() {
    akunList = [
      const Pengguna(
        id: 1,
        nama: 'Andi Pratama',
        username: 'andi.tagihan',
        role: 'admin_tagihan',
        aktif: true,
      ),
      const Pengguna(
        id: 2,
        nama: 'Budi Santoso',
        username: 'budi.santoso',
        role: 'sales',
        aktif: true,
      ),
      const Pengguna(
        id: 3,
        nama: 'Maya Kusuma',
        username: 'maya.kusuma',
        role: 'manajer_sales',
        aktif: true,
      ),
      const Pengguna(
        id: 4,
        nama: 'Dewi Lestari',
        username: 'dewi.lestari',
        role: 'sales',
        aktif: false,
      ),
    ];

    wilayahList = const [
      Wilayah(id: 1, nama: 'Purwokerto Timur'),
      Wilayah(id: 2, nama: 'Purwokerto Barat'),
      Wilayah(id: 3, nama: 'Purwokerto Selatan'),
      Wilayah(id: 4, nama: 'Sokaraja'),
    ];

    // 6 toko demo di sekitar Purwokerto.
    // Progres awal Budi: 4 dari 6 toko sudah dikunjungi bulan ini (Okt 2026).
    // Belum dikunjungi: Bintang Terang (JO-0501) & Berkah Abadi (JO-0375).
    tokoList = [
      Toko(
        noJo: 'JO-0412',
        nama: 'Toko Makmur Jaya',
        alamat: 'Jl. Jenderal Sudirman No. 45, Purwokerto Timur',
        ket: 'Pelanggan rutin suku cadang motor',
        wilayah: wilayahList[0], // Timur
        lat: -7.4243,
        lng: 109.2391,
        sudahDikunjungiBulanIni: true,
        hariSejakKunjunganTerakhir: 2,
      ),
      Toko(
        noJo: 'JO-0388',
        nama: 'Toko Sumber Rejeki',
        alamat: 'Jl. Gatot Subroto No. 12, Purwokerto Timur',
        ket: 'Fokus oli dan kampas rem',
        wilayah: wilayahList[0], // Timur
        lat: -7.4215,
        lng: 109.2410,
        sudahDikunjungiBulanIni: true,
        hariSejakKunjunganTerakhir: 4,
      ),
      Toko(
        noJo: 'JO-0501',
        nama: 'Toko Bintang Terang',
        alamat: 'Jl. Contoh No. 18, Sokaraja',
        ket: 'Toko besar area Sokaraja',
        wilayah: wilayahList[3], // Sokaraja
        lat: -7.4562,
        lng: 109.2865,
        sudahDikunjungiBulanIni: false,
        hariSejakKunjunganTerakhir: 32,
      ),
      Toko(
        noJo: 'JO-0375',
        nama: 'Toko Berkah Abadi',
        alamat: 'Jl. Kober No. 88, Purwokerto Barat',
        ket: 'Rutin order awal/akhir bulan',
        wilayah: wilayahList[1], // Barat
        lat: -7.4180,
        lng: 109.2150,
        sudahDikunjungiBulanIni: false,
        hariSejakKunjunganTerakhir: 34,
      ),
      Toko(
        noJo: 'JO-0420',
        nama: 'Toko Sentosa Abadi',
        alamat: 'Jl. KS Tubun No. 21, Purwokerto Barat',
        ket: 'Sparepart umum',
        wilayah: wilayahList[1], // Barat
        lat: -7.4201,
        lng: 109.2122,
        sudahDikunjungiBulanIni: true,
        hariSejakKunjunganTerakhir: 1,
      ),
      Toko(
        noJo: 'JO-0433',
        nama: 'Toko Harapan Jaya',
        alamat: 'Jl. DI Panjaitan No. 60, Purwokerto Selatan',
        ket: 'Langganan ban dan rantai',
        wilayah: wilayahList[2], // Selatan
        lat: -7.4410,
        lng: 109.2380,
        sudahDikunjungiBulanIni: true,
        hariSejakKunjunganTerakhir: 3,
      ),
    ];

    kriteriaList = const [
      Kriteria(id: 1, urutan: 1, nama: 'Kehadiran dan jam kunjungan'),
      Kriteria(id: 2, urutan: 2, nama: 'Kesesuaian prosedur'),
      Kriteria(id: 3, urutan: 3, nama: 'Respon toko'),
      Kriteria(id: 4, urutan: 4, nama: 'Target dan efektivitas'),
      Kriteria(id: 5, urutan: 5, nama: 'Kepatuhan mapping'),
      Kriteria(id: 6, urutan: 6, nama: 'Ketepatan check-in'),
      Kriteria(id: 7, urutan: 7, nama: 'Kriteria 7'),
      Kriteria(id: 8, urutan: 8, nama: 'Kriteria 8'),
      Kriteria(id: 9, urutan: 9, nama: 'Kriteria 9'),
      Kriteria(id: 10, urutan: 10, nama: 'Kriteria 10'),
      Kriteria(id: 11, urutan: 11, nama: 'Kriteria 11'),
      Kriteria(id: 12, urutan: 12, nama: 'Kriteria 12'),
      Kriteria(id: 13, urutan: 13, nama: 'Kriteria 13'),
      Kriteria(id: 14, urutan: 14, nama: 'Kriteria 14'),
      Kriteria(id: 15, urutan: 15, nama: 'Kriteria 15'),
      Kriteria(id: 16, urutan: 16, nama: 'Kriteria 16'),
      Kriteria(id: 17, urutan: 17, nama: 'Kriteria 17'),
      Kriteria(id: 18, urutan: 18, nama: 'Kriteria 18'),
    ];

    // Mapping tahun 2026 untuk Budi Santoso (salesId = 2)
    mappingList = List<MappingToko>.generate(tokoList.length, (i) {
      final t = tokoList[i];
      final rencana = List<bool>.filled(12, true);
      final realisasi = List<bool>.generate(12, (m) {
        if (m < 9) return true; // Jan-Sep terealisasi
        if (m == 9) return t.sudahDikunjungiBulanIni; // Okt (indeks 9)
        return false;
      });
      return MappingToko(
        idMapping: i + 1,
        idSales: 2,
        tahun: 2026,
        toko: t,
        bulan: rencana,
        terealisasi: realisasi,
      );
    });

    jurnalList = [
      JurnalKunjungan(
        id: 1,
        salesId: 2,
        noJo: 'JO-0412',
        tanggal: DateTime(2026, 10, 28, 9, 30),
        hasil: HasilKunjungan.adaOrder,
        catatan: 'Order rutin kampas rem 10 set dan oli mesin.',
        fotoDisplay: 'mock_display_0412.jpg',
        fotoNotaPo: 'mock_nota_0412.jpg',
        lat: -7.4243,
        lng: 109.2391,
        jarakM: 10.5,
        status: StatusJurnal.finalStatus,
      ),
      JurnalKunjungan(
        id: 2,
        salesId: 2,
        noJo: 'JO-0388',
        tanggal: DateTime(2026, 10, 26, 11, 15),
        hasil: HasilKunjungan.adaOrder,
        catatan: 'Repeat order busi dan filter udara.',
        fotoDisplay: 'mock_display_0388.jpg',
        fotoNotaPo: 'mock_nota_0388.jpg',
        lat: -7.4215,
        lng: 109.2410,
        jarakM: 14.0,
        status: StatusJurnal.finalStatus,
      ),
      JurnalKunjungan(
        id: 3,
        salesId: 2,
        noJo: 'JO-0420',
        tanggal: DateTime(2026, 10, 29, 14, 0),
        hasil: HasilKunjungan.tidakAdaOrder,
        catatan: 'Stok toko masih penuh, dijadwalkan cek bulan depan.',
        fotoDisplay: 'mock_display_0420.jpg',
        lat: -7.4201,
        lng: 109.2122,
        jarakM: 18.2,
        status: StatusJurnal.finalStatus,
      ),
      JurnalKunjungan(
        id: 4,
        salesId: 2,
        noJo: 'JO-0433',
        tanggal: DateTime(2026, 10, 27, 10, 0),
        hasil: HasilKunjungan.adaOrder,
        catatan: 'Order ban luar 5 pcs.',
        fotoDisplay: 'mock_display_0433.jpg',
        fotoNotaPo: 'mock_nota_0433.jpg',
        lat: -7.4410,
        lng: 109.2380,
        jarakM: 8.4,
        status: StatusJurnal.finalStatus,
      ),
    ];

    rescheduleList = [
      PengajuanReschedule(
        id: 1,
        noJo: 'JO-0375',
        namaToko: 'Toko Berkah Abadi',
        jadwalLama: DateTime(2026, 10, 30),
        jadwalBaru: DateTime(2026, 11, 3),
        alasan: 'Pemilik toko sedang keluar kota.',
        status: 'menunggu',
        salesNama: 'Budi Santoso',
        salesId: 2,
      ),
      PengajuanReschedule(
        id: 2,
        noJo: 'JO-0501',
        namaToko: 'Toko Bintang Terang',
        jadwalLama: DateTime(2026, 10, 30),
        jadwalBaru: DateTime(2026, 11, 4),
        alasan: 'Jadwal bentrok dengan rute Sokaraja.',
        status: 'menunggu',
        salesNama: 'Budi Santoso',
        salesId: 2,
      ),
      PengajuanReschedule(
        id: 3,
        noJo: 'JO-0420',
        namaToko: 'Toko Sentosa Abadi',
        jadwalLama: DateTime(2026, 10, 25),
        jadwalBaru: DateTime(2026, 11, 4),
        alasan: 'Jadwal bentrok dengan rute Sokaraja.',
        status: 'ditolak',
        salesNama: 'Budi Santoso',
        salesId: 2,
      ),
      PengajuanReschedule(
        id: 4,
        noJo: 'JO-0412',
        namaToko: 'Toko Cahaya Mulia',
        jadwalLama: DateTime(2026, 10, 22),
        jadwalBaru: DateTime(2026, 11, 5),
        alasan: 'Jadwal diperbarui atas permintaan toko.',
        status: 'disetujui',
        salesNama: 'Budi Santoso',
        salesId: 2,
      ),
    ];

    // Seed kondite Budi Santoso (10x B = 1000, 8x C = 600 -> 1600/18 = 88.9 BAIK)
    final detailBudi = <int, String>{
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

    konditeMap = {
      '2-2026-10': PenilaianKondite(
        salesId: 2,
        salesNama: 'Budi Santoso',
        periode: '2026-10',
        detail: detailBudi,
        nilaiAkhir: 88.9,
        label: 'BAIK',
      ),
    };
  }

  /// Tandai toko sudah dikunjungi pada bulan kunjungan dan sinkronkan ke mappingList & tokoList.
  void markTokoVisited(String noJo, DateTime tanggal) {
    final monthIdx = (tanggal.month - 1).clamp(0, 11);

    tokoList = tokoList.map((t) {
      if (t.noJo == noJo) {
        return t.copyWith(
          sudahDikunjungiBulanIni: true,
          hariSejakKunjunganTerakhir: 0,
        );
      }
      return t;
    }).toList();

    mappingList = mappingList.map((m) {
      if (m.toko.noJo == noJo) {
        final newReal = List<bool>.from(m.terealisasi);
        newReal[monthIdx] = true;
        final updatedToko = tokoList.firstWhere(
          (t) => t.noJo == noJo,
          orElse: () => m.toko.copyWith(sudahDikunjungiBulanIni: true),
        );
        return m.copyWith(
          toko: updatedToko,
          terealisasi: newReal,
        );
      }
      return m;
    }).toList();
  }
}
