import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/utils/nilai_kondite.dart';
import '../../../admin_data/data/models/master_models.dart';
import '../../../auth/data/models/pengguna_model.dart';

class ManajerKonditeState {
  final List<Pengguna> salesList;
  final int selectedSalesId;
  final String periode; // misal '2026-10'
  final List<Kriteria> kriteriaList;
  final Map<int, String> detailNilai; // Map<kriteriaId, 'B'|'C'|'K'|'SK'>
  final double nilaiAkhir;
  final String label;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool isSuccessSave;

  const ManajerKonditeState({
    this.salesList = const [],
    this.selectedSalesId = 2,
    this.periode = '2026-10',
    this.kriteriaList = const [],
    this.detailNilai = const {},
    this.nilaiAkhir = 88.9,
    this.label = 'BAIK',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.isSuccessSave = false,
  });

  Pengguna? get selectedSales {
    final match = salesList.where((s) => s.id == selectedSalesId);
    return match.isNotEmpty ? match.first : null;
  }

  ManajerKonditeState copyWith({
    List<Pengguna>? salesList,
    int? selectedSalesId,
    String? periode,
    List<Kriteria>? kriteriaList,
    Map<int, String>? detailNilai,
    double? nilaiAkhir,
    String? label,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccessSave,
  }) {
    return ManajerKonditeState(
      salesList: salesList ?? this.salesList,
      selectedSalesId: selectedSalesId ?? this.selectedSalesId,
      periode: periode ?? this.periode,
      kriteriaList: kriteriaList ?? this.kriteriaList,
      detailNilai: detailNilai ?? this.detailNilai,
      nilaiAkhir: nilaiAkhir ?? this.nilaiAkhir,
      label: label ?? this.label,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccessSave: isSuccessSave ?? this.isSuccessSave,
    );
  }
}

class ManajerKonditeNotifier extends Notifier<ManajerKonditeState> {
  @override
  ManajerKonditeState build() {
    Future.microtask(() => loadInitialData());
    return const ManajerKonditeState(isLoading: true);
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final akunRepo = ref.read(akunRepositoryProvider);
      final masterRepo = ref.read(masterRepositoryProvider);

      final results = await Future.wait([
        akunRepo.list(),
        masterRepo.kriteria(),
      ]);

      final allAkun = results[0] as List<Pengguna>;
      final salesList = allAkun
          .where((u) => u.role == 'sales' || u.role == 'manajer_sales')
          .toList();
      final kriteriaList = results[1] as List<Kriteria>;

      final activeSales = salesList.isNotEmpty ? salesList.first.id : 2;
      state = state.copyWith(
        salesList: salesList,
        kriteriaList: kriteriaList,
        selectedSalesId: activeSales,
      );

      await loadPenilaianSales(activeSales);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadPenilaianSales(int salesId) async {
    state = state.copyWith(isLoading: true, selectedSalesId: salesId, clearError: true);
    try {
      final repo = ref.read(konditeRepositoryProvider);
      final config = ref.read(appConfigProvider);

      final penilaian = await repo.get(
        salesId: salesId,
        periode: state.periode,
      );

      final detail = Map<int, String>.from(penilaian.detail);
      // Lengkapi jika ada kriteria yang belum terisi
      for (final k in state.kriteriaList) {
        detail.putIfAbsent(k.id, () => 'B');
      }

      final nilai = NilaiKonditeUtils.hitungNilaiAkhir(detail, config.bobotNilai);
      final label = NilaiKonditeUtils.tentukanLabel(nilai);

      state = state.copyWith(
        detailNilai: detail,
        nilaiAkhir: nilai,
        label: label,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void updateNilaiKriteria(int kriteriaId, String nilaiHuruf) {
    final config = ref.read(appConfigProvider);
    final updated = Map<int, String>.from(state.detailNilai);
    updated[kriteriaId] = nilaiHuruf;

    final nilai = NilaiKonditeUtils.hitungNilaiAkhir(updated, config.bobotNilai);
    final label = NilaiKonditeUtils.tentukanLabel(nilai);

    state = state.copyWith(
      detailNilai: updated,
      nilaiAkhir: nilai,
      label: label,
    );
  }

  Future<bool> simpanPenilaian() async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = ref.read(konditeRepositoryProvider);
      await repo.save(
        salesId: state.selectedSalesId,
        periode: state.periode,
        detail: state.detailNilai,
      );

      state = state.copyWith(isSaving: false, isSuccessSave: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final manajerKonditeProvider =
    NotifierProvider<ManajerKonditeNotifier, ManajerKonditeState>(
  ManajerKonditeNotifier.new,
);
