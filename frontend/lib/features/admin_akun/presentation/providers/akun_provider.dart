import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../auth/data/models/pengguna_model.dart';

class AkunState {
  final List<Pengguna> akunList;
  final bool isLoading;
  final String? errorMessage;
  final String? successBanner;

  const AkunState({
    this.akunList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successBanner,
  });

  AkunState copyWith({
    List<Pengguna>? akunList,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successBanner,
    bool clearBanner = false,
  }) {
    return AkunState(
      akunList: akunList ?? this.akunList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successBanner: clearBanner ? null : (successBanner ?? this.successBanner),
    );
  }
}

class AkunNotifier extends Notifier<AkunState> {
  @override
  AkunState build() {
    // Muat data awal saat provider dibuat
    Future.microtask(() => loadAkun());
    return const AkunState(isLoading: true);
  }

  Future<void> loadAkun() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(akunRepositoryProvider);
      final list = await repo.list();
      state = state.copyWith(akunList: list, isLoading: false);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  Future<bool> tambahAkun({
    required String nama,
    required String username,
    required String password,
    required String role,
    required bool aktif,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearBanner: true);
    try {
      final repo = ref.read(akunRepositoryProvider);
      final baru = await repo.create(
        nama: nama,
        username: username,
        password: password,
        role: role,
        aktif: aktif,
      );
      state = state.copyWith(
        akunList: [baru, ...state.akunList.where((a) => a.id != baru.id)],
        isLoading: false,
        successBanner:
            'Akun berhasil ditambahkan. Notifikasi dikirim: akun baru sudah muncul dengan label BARU.',
      );
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  Future<void> setAktif(int id, bool aktif) async {
    try {
      final repo = ref.read(akunRepositoryProvider);
      final updated = await repo.setAktif(id, aktif);
      state = state.copyWith(
        akunList: state.akunList.map((a) => a.id == id ? updated : a).toList(),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(errorMessage: msg);
    }
  }

  void clearBanner() {
    state = state.copyWith(clearBanner: true);
  }
}

final akunProvider = NotifierProvider<AkunNotifier, AkunState>(
  AkunNotifier.new,
);
