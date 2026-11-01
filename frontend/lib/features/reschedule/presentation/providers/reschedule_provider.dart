import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/pengajuan_reschedule_model.dart';

class RescheduleState {
  final List<PengajuanReschedule> items;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;

  const RescheduleState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  RescheduleState copyWith({
    List<PengajuanReschedule>? items,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return RescheduleState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class RescheduleNotifier extends Notifier<RescheduleState> {
  @override
  RescheduleState build() {
    Future.microtask(() => loadReschedule());
    return const RescheduleState(isLoading: true);
  }

  Future<void> loadReschedule() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(rescheduleRepositoryProvider);
      final items = await repo.list();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> ajukanReschedule({
    required String noJo,
    required DateTime jadwalBaru,
    required String alasan,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repo = ref.read(rescheduleRepositoryProvider);
      final baru = await repo.create(
        noJo: noJo,
        jadwalBaru: jadwalBaru,
        alasan: alasan,
      );

      state = state.copyWith(
        items: [baru, ...state.items],
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> prosesPersetujuan({
    required int id,
    required bool disetujui,
  }) async {
    try {
      final repo = ref.read(rescheduleRepositoryProvider);
      final updated = disetujui
          ? await repo.setujui(id)
          : await repo.tolak(id);

      state = state.copyWith(
        items: state.items.map((item) => item.id == id ? updated : item).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final rescheduleProvider =
    NotifierProvider<RescheduleNotifier, RescheduleState>(
  RescheduleNotifier.new,
);
