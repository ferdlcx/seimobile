import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../admin_data/data/models/master_models.dart';
import '../../data/models/monitoring_models.dart';

class MonitoringState {
  final RingkasanMonitoring? ringkasan;
  final int? filterWilayahId;
  final List<Wilayah> wilayahList;
  final bool isLoading;
  final String? errorMessage;

  const MonitoringState({
    this.ringkasan,
    this.filterWilayahId,
    this.wilayahList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MonitoringState copyWith({
    RingkasanMonitoring? ringkasan,
    int? filterWilayahId,
    bool clearFilterWilayah = false,
    List<Wilayah>? wilayahList,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MonitoringState(
      ringkasan: ringkasan ?? this.ringkasan,
      filterWilayahId: clearFilterWilayah
          ? null
          : (filterWilayahId ?? this.filterWilayahId),
      wilayahList: wilayahList ?? this.wilayahList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MonitoringNotifier extends Notifier<MonitoringState> {
  @override
  MonitoringState build() {
    Future.microtask(() => loadMonitoring());
    return const MonitoringState(isLoading: true);
  }

  Future<void> loadMonitoring() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(monitoringRepositoryProvider);
      final masterRepo = ref.read(masterRepositoryProvider);

      final results = await Future.wait([
        repo.harian(wilayahId: state.filterWilayahId),
        masterRepo.wilayah(),
      ]);

      final ringkasan = results[0] as RingkasanMonitoring;
      final wilayahList = results[1] as List<Wilayah>;

      state = state.copyWith(
        ringkasan: ringkasan,
        wilayahList: wilayahList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> filterWilayah(int? wilayahId) async {
    state = state.copyWith(
      filterWilayahId: wilayahId,
      clearFilterWilayah: wilayahId == null,
    );
    await loadMonitoring();
  }
}

final monitoringProvider =
    NotifierProvider<MonitoringNotifier, MonitoringState>(
  MonitoringNotifier.new,
);
