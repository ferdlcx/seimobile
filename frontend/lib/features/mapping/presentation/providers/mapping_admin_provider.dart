import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/mapping_toko_model.dart';

class MappingAdminState {
  final int selectedSalesId;
  final int selectedTahun;
  final int? filterWilayahId;
  final List<MappingToko> items;
  final bool isLoading;
  final String? errorMessage;
  final bool isSavedSuccess;
  final DateTime? savedTimestamp;

  const MappingAdminState({
    this.selectedSalesId = 2, // Budi Santoso
    this.selectedTahun = 2026,
    this.filterWilayahId,
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSavedSuccess = false,
    this.savedTimestamp,
  });

  MappingAdminState copyWith({
    int? selectedSalesId,
    int? selectedTahun,
    int? filterWilayahId,
    bool clearFilterWilayah = false,
    List<MappingToko>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSavedSuccess,
    DateTime? savedTimestamp,
  }) {
    return MappingAdminState(
      selectedSalesId: selectedSalesId ?? this.selectedSalesId,
      selectedTahun: selectedTahun ?? this.selectedTahun,
      filterWilayahId: clearFilterWilayah
          ? null
          : (filterWilayahId ?? this.filterWilayahId),
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSavedSuccess: isSavedSuccess ?? this.isSavedSuccess,
      savedTimestamp: savedTimestamp ?? this.savedTimestamp,
    );
  }
}

class MappingAdminNotifier extends Notifier<MappingAdminState> {
  @override
  MappingAdminState build() {
    Future.microtask(() => loadMapping());
    return const MappingAdminState(isLoading: true);
  }

  Future<void> loadMapping() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(mappingRepositoryProvider);
      final list = await repo.get(
        salesId: state.selectedSalesId,
        tahun: state.selectedTahun,
        wilayahId: state.filterWilayahId,
      );
      state = state.copyWith(items: list, isLoading: false);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  void toggleCell(int itemIndex, int monthIndex) {
    if (itemIndex < 0 || itemIndex >= state.items.length) return;
    final item = state.items[itemIndex];
    final updatedBulan = List<bool>.from(item.bulan);
    updatedBulan[monthIndex] = !updatedBulan[monthIndex];

    final updatedItem = item.copyWith(bulan: updatedBulan);
    final updatedList = List<MappingToko>.from(state.items);
    updatedList[itemIndex] = updatedItem;

    state = state.copyWith(items: updatedList, isSavedSuccess: false);
  }

  Future<bool> saveMapping() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(mappingRepositoryProvider);
      await repo.save(state.items);
      state = state.copyWith(
        isLoading: false,
        isSavedSuccess: true,
        savedTimestamp: DateTime(2026, 10, 30, 10, 24),
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  Future<void> setSales(int salesId) async {
    state = state.copyWith(
      selectedSalesId: salesId,
      isSavedSuccess: false,
    );
    await loadMapping();
  }

  Future<void> filterWilayah(int? wilayahId) async {
    state = state.copyWith(
      filterWilayahId: wilayahId,
      clearFilterWilayah: wilayahId == null,
      isSavedSuccess: false,
    );
    await loadMapping();
  }
}

final mappingAdminProvider =
    NotifierProvider<MappingAdminNotifier, MappingAdminState>(
  MappingAdminNotifier.new,
);
