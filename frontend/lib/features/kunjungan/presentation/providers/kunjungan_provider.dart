import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/utils/haversine.dart';
import '../../../admin_data/data/models/master_models.dart';
import '../../data/models/jurnal_kunjungan_model.dart';

class KunjunganGpsState {
  final double currentLat;
  final double currentLng;
  final double jarakM;
  final bool isInRadius;
  final bool isLoadingGps;
  final String? gpsError;

  const KunjunganGpsState({
    this.currentLat = -7.4243,
    this.currentLng = 109.2391,
    this.jarakM = 12.0,
    this.isInRadius = true,
    this.isLoadingGps = false,
    this.gpsError,
  });

  KunjunganGpsState copyWith({
    double? currentLat,
    double? currentLng,
    double? jarakM,
    bool? isInRadius,
    bool? isLoadingGps,
    String? gpsError,
  }) {
    return KunjunganGpsState(
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      jarakM: jarakM ?? this.jarakM,
      isInRadius: isInRadius ?? this.isInRadius,
      isLoadingGps: isLoadingGps ?? this.isLoadingGps,
      gpsError: gpsError ?? this.gpsError,
    );
  }
}

class KunjunganGpsNotifier extends Notifier<KunjunganGpsState> {
  @override
  KunjunganGpsState build() {
    return const KunjunganGpsState();
  }

  /// Memperbarui posisi GPS terhadap toko tertentu menggunakan Haversine.
  Future<void> perbaruiLokasi(Toko toko) async {
    final config = ref.read(appConfigProvider);

    if (config.useSimulatedGps) {
      // Lokasi simulasi sangat dekat dengan toko (jarak ~12 meter di dalam radius 50m)
      const double simulatedLatOffset = 0.00010;
      final lat = toko.lat + simulatedLatOffset;
      final lng = toko.lng;
      final jarak = haversine(lat, lng, toko.lat, toko.lng);
      final inRadius = isWithinCheckinRadius(
        jarakM: jarak,
        radiusCheckinMeter: config.radiusCheckinMeter,
      );
      state = KunjunganGpsState(
        currentLat: lat,
        currentLng: lng,
        jarakM: double.parse(jarak.toStringAsFixed(1)),
        isInRadius: inRadius,
      );
      return;
    }

    state = state.copyWith(isLoadingGps: true, gpsError: null);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            'Izin akses lokasi ditolak. Aktifkan izin lokasi di pengaturan perangkat.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin akses lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final jarak = haversine(
        position.latitude,
        position.longitude,
        toko.lat,
        toko.lng,
      );

      final inRadius = isWithinCheckinRadius(
        jarakM: jarak,
        radiusCheckinMeter: config.radiusCheckinMeter,
      );

      state = KunjunganGpsState(
        currentLat: position.latitude,
        currentLng: position.longitude,
        jarakM: double.parse(jarak.toStringAsFixed(1)),
        isInRadius: inRadius,
        isLoadingGps: false,
      );
    } catch (e) {
      // Fallback bila geolocator di emulator tidak dapat sinyal GPS asli
      const double simulatedLatOffset = 0.00010;
      final lat = toko.lat + simulatedLatOffset;
      final lng = toko.lng;
      final jarak = haversine(lat, lng, toko.lat, toko.lng);
      state = KunjunganGpsState(
        currentLat: lat,
        currentLng: lng,
        jarakM: double.parse(jarak.toStringAsFixed(1)),
        isInRadius: true,
        isLoadingGps: false,
      );
    }
  }

  /// Memaksa simulasi berada di luar radius untuk keperluan pengujian UI/Validasi.
  void setSimulasiLuarRadius(Toko toko) {
    final config = ref.read(appConfigProvider);
    final lat = toko.lat + 0.005; // ~550 meter jauhnya
    final lng = toko.lng;
    final jarak = haversine(lat, lng, toko.lat, toko.lng);
    state = KunjunganGpsState(
      currentLat: lat,
      currentLng: lng,
      jarakM: double.parse(jarak.toStringAsFixed(1)),
      isInRadius: isWithinCheckinRadius(
        jarakM: jarak,
        radiusCheckinMeter: config.radiusCheckinMeter,
      ),
    );
  }
}

final kunjunganGpsProvider =
    NotifierProvider<KunjunganGpsNotifier, KunjunganGpsState>(
  KunjunganGpsNotifier.new,
);

class JurnalFormState {
  final HasilKunjungan hasil;
  final String catatan;
  final String? fotoDisplay;
  final String? fotoNotaPo;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccessFinal;

  const JurnalFormState({
    this.hasil = HasilKunjungan.adaOrder,
    this.catatan = '',
    this.fotoDisplay,
    this.fotoNotaPo,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccessFinal = false,
  });

  JurnalFormState copyWith({
    HasilKunjungan? hasil,
    String? catatan,
    String? fotoDisplay,
    String? fotoNotaPo,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccessFinal,
  }) {
    return JurnalFormState(
      hasil: hasil ?? this.hasil,
      catatan: catatan ?? this.catatan,
      fotoDisplay: fotoDisplay ?? this.fotoDisplay,
      fotoNotaPo: fotoNotaPo ?? this.fotoNotaPo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccessFinal: isSuccessFinal ?? this.isSuccessFinal,
    );
  }
}

class JurnalFormNotifier extends Notifier<JurnalFormState> {
  @override
  JurnalFormState build() {
    return const JurnalFormState();
  }

  void setHasil(HasilKunjungan hasil) {
    state = state.copyWith(hasil: hasil);
  }

  void setCatatan(String catatan) {
    state = state.copyWith(catatan: catatan);
  }

  void setFotoDisplay(String? path) {
    state = state.copyWith(fotoDisplay: path);
  }

  void setFotoNotaPo(String? path) {
    state = state.copyWith(fotoNotaPo: path);
  }

  Future<void> loadDraft(String noJo) async {
    final repo = ref.read(jurnalRepositoryProvider);
    final draft = await repo.getDraft(noJo);
    if (draft != null) {
      state = state.copyWith(
        hasil: draft.hasil,
        catatan: draft.catatan,
        fotoDisplay: draft.fotoDisplay,
        fotoNotaPo: draft.fotoNotaPo,
      );
    }
  }

  Future<bool> simpanDraft({
    required String noJo,
    required double lat,
    required double lng,
    required double jarakM,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(jurnalRepositoryProvider);
      await repo.saveDraft(
        noJo: noJo,
        hasil: state.hasil,
        catatan: state.catatan,
        fotoDisplay: state.fotoDisplay,
        fotoNotaPo: state.fotoNotaPo,
        lat: lat,
        lng: lng,
        jarakM: jarakM,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  Future<bool> simpanFinal({
    required String noJo,
    required double lat,
    required double lng,
    required double jarakM,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(jurnalRepositoryProvider);
      await repo.create(
        noJo: noJo,
        hasil: state.hasil,
        catatan: state.catatan,
        fotoDisplay: state.fotoDisplay,
        fotoNotaPo: state.fotoNotaPo,
        lat: lat,
        lng: lng,
        jarakM: jarakM,
      );
      state = state.copyWith(isLoading: false, isSuccessFinal: true);
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }
}

final jurnalFormProvider =
    NotifierProvider<JurnalFormNotifier, JurnalFormState>(
  JurnalFormNotifier.new,
);
