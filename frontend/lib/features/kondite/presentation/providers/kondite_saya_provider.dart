import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../admin_data/data/models/master_models.dart';
import '../../data/models/penilaian_kondite_model.dart';

class KonditeSayaState {
  final PenilaianKondite? penilaian;
  final List<Kriteria> kriteriaList;
  final bool isLoading;
  final String? errorMessage;

  const KonditeSayaState({
    this.penilaian,
    this.kriteriaList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  KonditeSayaState copyWith({
    PenilaianKondite? penilaian,
    List<Kriteria>? kriteriaList,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return KonditeSayaState(
      penilaian: penilaian ?? this.penilaian,
      kriteriaList: kriteriaList ?? this.kriteriaList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class KonditeSayaNotifier extends Notifier<KonditeSayaState> {
  @override
  KonditeSayaState build() {
    Future.microtask(() => loadKonditeSaya());
    return const KonditeSayaState(isLoading: true);
  }

  Future<void> loadKonditeSaya() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(konditeRepositoryProvider);
      final masterRepo = ref.read(masterRepositoryProvider);

      final results = await Future.wait([
        repo.saya(),
        masterRepo.kriteria(),
      ]);

      final penilaian = results[0] as PenilaianKondite;
      final kriteriaList = results[1] as List<Kriteria>;

      state = state.copyWith(
        penilaian: penilaian,
        kriteriaList: kriteriaList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final konditeSayaProvider =
    NotifierProvider<KonditeSayaNotifier, KonditeSayaState>(
  KonditeSayaNotifier.new,
);
