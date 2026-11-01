import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/mapping_repository.dart';

class MappingHariIniState {
  final int? filterWilayahId;
  final MappingHariIniData? data;
  final bool isLoading;
  final String? errorMessage;

  const MappingHariIniState({
    this.filterWilayahId,
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  MappingHariIniState copyWith({
    int? filterWilayahId,
    bool clearFilterWilayah = false,
    MappingHariIniData? data,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MappingHariIniState(
      filterWilayahId: clearFilterWilayah
          ? null
          : (filterWilayahId ?? this.filterWilayahId),
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MappingHariIniNotifier extends Notifier<MappingHariIniState> {
  @override
  MappingHariIniState build() {
    Future.microtask(() => loadMappingHariIni());
    return const MappingHariIniState(isLoading: true);
  }

  Future<void> loadMappingHariIni() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(mappingRepositoryProvider);
      final res = await repo.hariIni(wilayahId: state.filterWilayahId);
      state = state.copyWith(data: res, isLoading: false);
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
    await loadMappingHariIni();
  }
}

final mappingHariIniProvider =
    NotifierProvider<MappingHariIniNotifier, MappingHariIniState>(
  MappingHariIniNotifier.new,
);
