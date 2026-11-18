import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../admin_akun/presentation/providers/akun_provider.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../kondite/presentation/providers/kondite_saya_provider.dart';
import '../../../kondite/presentation/providers/manajer_kondite_provider.dart';
import '../../../laporan/presentation/providers/laporan_provider.dart';
import '../../../mapping/presentation/providers/mapping_admin_provider.dart';
import '../../../mapping/presentation/providers/mapping_hari_ini_provider.dart';
import '../../../monitoring/presentation/providers/monitoring_provider.dart';
import '../../../reschedule/presentation/providers/reschedule_provider.dart';
import '../../data/auth_repository.dart';

/// State autentikasi saat ini (menyimpan user yang login, token, dan mode aktif).
class AuthState {
  final AuthSession? session;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => session != null;

  /// Peran asli dari akun (`admin_tagihan`, `sales`, `manajer_sales`).
  String? get role => session?.user.role;

  /// Mode tampilan aktif (`admin_tagihan`, `sales`, `manajer`).
  /// Manajer Sales memiliki kemampuan berpindah ke mode `sales` tanpa login ulang.
  String? get activeMode => session?.mode;

  AuthState copyWith({
    AuthSession? session,
    bool clearSession = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      session: clearSession ? null : (session ?? this.session),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void _invalidateFeatureProviders() {
    ref.invalidate(akunProvider);
    ref.invalidate(masterDataProvider);
    ref.invalidate(mappingAdminProvider);
    ref.invalidate(mappingHariIniProvider);
    ref.invalidate(monitoringProvider);
    ref.invalidate(rescheduleProvider);
    ref.invalidate(konditeSayaProvider);
    ref.invalidate(manajerKonditeProvider);
    ref.invalidate(laporanProvider);
  }

  Future<bool> login({
    required String username,
    required String password,
    required String role,
    String? mode,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.login(
        username: username,
        password: password,
        role: role,
        mode: mode,
      );
      state = AuthState(session: session, isLoading: false);
      _invalidateFeatureProviders();
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  /// Berpindah mode antara Manajer dan Sales khusus untuk akun Manajer Sales.
  void switchMode(String newMode) {
    final current = state.session;
    if (current == null) return;
    if (current.user.role != 'manajer_sales') return;

    final updated = AuthSession(
      token: current.token,
      user: current.user,
      mode: newMode,
    );
    ref.read(authRepositoryProvider).updateMode(newMode);
    state = state.copyWith(session: updated);
    _invalidateFeatureProviders();
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState();
    _invalidateFeatureProviders();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
