import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Konfigurasi aplikasi S.E.U.I Centre.
/// Jangan hardcode nilai bisnis di widget; ambil dari AppConfig.
class AppConfig {
  /// Base URL API backend (diambil dari --dart-define=API_BASE_URL=...).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Gunakan implementasi Mock (true) atau API nyata (false).
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// Feature flag untuk modul Reschedule & Approval.
  final bool enableReschedule;

  /// Radius maksimal check-in GPS dalam meter.
  final double radiusCheckinMeter;

  /// Bobot nilai kondite untuk perhitungan rata-rata 18 kriteria.
  final Map<String, int> bobotNilai;

  /// Batas hari toko belum dikunjungi untuk memunculkan peringatan.
  final int batasHariBelumDikunjungi;

  /// Simulasi kegagalan acak (±5%) pada mock repository agar state error teruji.
  final bool enableMockRandomError;

  /// Gunakan lokasi GPS simulasi (dekat toko) untuk keperluan demo/emulator.
  final bool useSimulatedGps;

  /// Tanggal "hari ini" di lingkungan mock (Jumat, 30 Okt 2026).
  final DateTime mockToday;

  AppConfig({
    this.enableReschedule = true,
    this.radiusCheckinMeter = 50.0,
    this.bobotNilai = const {
      'B': 100,
      'C': 75,
      'K': 50,
      'SK': 25,
    },
    this.batasHariBelumDikunjungi = 30,
    this.enableMockRandomError = false,
    this.useSimulatedGps = true,
    DateTime? mockToday,
  }) : mockToday = mockToday ?? DateTime(2026, 10, 30, 10, 24);

  AppConfig copyWith({
    bool? enableReschedule,
    double? radiusCheckinMeter,
    Map<String, int>? bobotNilai,
    int? batasHariBelumDikunjungi,
    bool? enableMockRandomError,
    bool? useSimulatedGps,
    DateTime? mockToday,
  }) {
    return AppConfig(
      enableReschedule: enableReschedule ?? this.enableReschedule,
      radiusCheckinMeter: radiusCheckinMeter ?? this.radiusCheckinMeter,
      bobotNilai: bobotNilai ?? this.bobotNilai,
      batasHariBelumDikunjungi:
          batasHariBelumDikunjungi ?? this.batasHariBelumDikunjungi,
      enableMockRandomError:
          enableMockRandomError ?? this.enableMockRandomError,
      useSimulatedGps: useSimulatedGps ?? this.useSimulatedGps,
      mockToday: mockToday ?? this.mockToday,
    );
  }
}

class AppConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() => AppConfig();

  void updateConfig(AppConfig newConfig) {
    state = newConfig;
  }
}

final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);
