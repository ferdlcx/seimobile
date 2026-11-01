import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../monitoring/data/models/monitoring_models.dart';
import '../../data/laporan_repository.dart';

class LaporanState {
  final int? filterWilayahId;
  final RingkasanMonitoring? monitoring;
  final LaporanRekapData? rekap;
  final bool isLoading;
  final String? errorMessage;

  const LaporanState({
    this.filterWilayahId,
    this.monitoring,
    this.rekap,
    this.isLoading = false,
    this.errorMessage,
  });

  LaporanState copyWith({
    int? filterWilayahId,
    bool clearFilterWilayah = false,
    RingkasanMonitoring? monitoring,
    LaporanRekapData? rekap,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LaporanState(
      filterWilayahId: clearFilterWilayah
          ? null
          : (filterWilayahId ?? this.filterWilayahId),
      monitoring: monitoring ?? this.monitoring,
      rekap: rekap ?? this.rekap,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LaporanNotifier extends Notifier<LaporanState> {
  @override
  LaporanState build() {
    Future.microtask(() => loadData());
    return const LaporanState(isLoading: true);
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final monitoringRepo = ref.read(monitoringRepositoryProvider);
      final laporanRepo = ref.read(laporanRepositoryProvider);

      final results = await Future.wait([
        monitoringRepo.harian(wilayahId: state.filterWilayahId),
        laporanRepo.rekap(
          periode: '2026-10',
          wilayahId: state.filterWilayahId,
        ),
      ]);

      final m = results[0] as RingkasanMonitoring;
      final r = results[1] as LaporanRekapData;

      state = state.copyWith(
        monitoring: m,
        rekap: r,
        isLoading: false,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  Future<void> filterWilayah(int? wilayahId) async {
    state = state.copyWith(
      filterWilayahId: wilayahId,
      clearFilterWilayah: wilayahId == null,
    );
    await loadData();
  }
}

final laporanProvider = NotifierProvider<LaporanNotifier, LaporanState>(
  LaporanNotifier.new,
);
