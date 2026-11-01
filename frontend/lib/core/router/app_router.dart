import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin_akun/presentation/screens/admin_akun_screen.dart';
import '../../features/admin_akun/presentation/screens/tambah_akun_screen.dart';
import '../../features/admin_data/presentation/screens/admin_data_screen.dart';
import '../../features/admin_data/presentation/screens/tambah_toko_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_berhasil_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/pilih_peran_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/kondite/presentation/screens/kondite_saya_screen.dart';
import '../../features/kondite/presentation/screens/lembar_cetak_kondite_screen.dart';
import '../../features/kondite/presentation/screens/manajer_kondite_screen.dart';
import '../../features/kunjungan/presentation/screens/detail_toko_screen.dart';
import '../../features/kunjungan/presentation/screens/sales_kunjungan_screen.dart';
import '../../features/kunjungan/presentation/screens/wizard_jurnal_screen.dart';
import '../../features/laporan/presentation/screens/admin_laporan_screen.dart';
import '../../features/laporan/presentation/screens/hasil_rekap_screen.dart';
import '../../features/laporan/presentation/screens/manajer_laporan_screen.dart';
import '../../features/mapping/presentation/screens/admin_mapping_screen.dart';
import '../../features/mapping/presentation/screens/sales_mapping_screen.dart';
import '../../features/monitoring/presentation/screens/manajer_beranda_screen.dart';
import '../../features/reschedule/presentation/screens/form_reschedule_screen.dart';
import '../../features/reschedule/presentation/screens/manajer_approval_screen.dart';
import '../../features/reschedule/presentation/screens/sales_reschedule_screen.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

/// Listenable untuk memberi tahu GoRouter saat AuthState berubah tanpa membuat ulang instance GoRouter.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Fungsi murni untuk mengecek guard rute berdasarkan status autentikasi dan mode peran.
/// Mengembalikan rute pengalihan (redirect) bila akses ditolak, atau `null` bila diizinkan.
String? evaluateRouteGuard({
  required String location,
  required AuthState auth,
}) {
  final isPublicRoute = location == '/splash' ||
      location == '/pilih-peran' ||
      location.startsWith('/login/');

  if (!auth.isAuthenticated) {
    if (isPublicRoute) return null;
    return '/pilih-peran';
  }

  // Jika sudah terautentikasi dan berada di layar login berhasil, izinkan
  if (location == '/login-berhasil') {
    return null;
  }

  // Jika baru selesai login (sedang di /login/*), arahkan ke layar konfirmasi /login-berhasil
  if (location.startsWith('/login/')) {
    return '/login-berhasil';
  }

  // Jika sudah terautentikasi tetapi berada di splash atau pilih-peran, arahkan ke beranda
  if (location == '/splash' || location == '/pilih-peran') {
    return defaultHomeRouteForMode(auth.activeMode);
  }

  final mode = auth.activeMode;

  // Guard rute Admin Tagihan: selain admin_tagihan ditolak
  if (location.startsWith('/admin')) {
    if (auth.role != 'admin_tagihan') {
      return defaultHomeRouteForMode(mode);
    }
    return null;
  }

  // Guard rute Sales: hanya mode sales yang diizinkan
  if (location.startsWith('/sales')) {
    if (mode != 'sales') {
      return defaultHomeRouteForMode(mode);
    }
    return null;
  }

  // Guard rute Manajer Sales: hanya mode manajer yang diizinkan
  if (location.startsWith('/manajer')) {
    if (mode != 'manajer') {
      return defaultHomeRouteForMode(mode);
    }
    return null;
  }

  return null;
}

String defaultHomeRouteForMode(String? mode) {
  switch (mode) {
    case 'admin_tagihan':
      return '/admin/akun';
    case 'manajer':
      return '/manajer/beranda';
    case 'sales':
    default:
      return '/sales/mapping';
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      return evaluateRouteGuard(
        location: state.matchedLocation,
        auth: auth,
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/pilih-peran',
        builder: (context, state) => const PilihPeranScreen(),
      ),
      GoRoute(
        path: '/login/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'sales';
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/login-berhasil',
        builder: (context, state) => const LoginBerhasilScreen(),
      ),

      // Modul Admin Tagihan
      GoRoute(
        path: '/admin/akun',
        builder: (context, state) => const AdminAkunScreen(),
      ),
      GoRoute(
        path: '/admin/akun/tambah',
        builder: (context, state) => const TambahAkunScreen(),
      ),
      GoRoute(
        path: '/admin/data',
        builder: (context, state) => const AdminDataScreen(),
      ),
      GoRoute(
        path: '/admin/data/tambah-toko',
        builder: (context, state) => const TambahTokoScreen(),
      ),
      GoRoute(
        path: '/admin/mapping',
        builder: (context, state) => const AdminMappingScreen(),
      ),
      GoRoute(
        path: '/admin/laporan',
        builder: (context, state) => const AdminLaporanScreen(),
      ),
      GoRoute(
        path: '/admin/laporan/hasil-rekap',
        builder: (context, state) => const HasilRekapScreen(),
      ),

      // Modul Sales
      GoRoute(
        path: '/sales/mapping',
        builder: (context, state) => const SalesMappingScreen(),
      ),
      GoRoute(
        path: '/sales/kunjungan',
        builder: (context, state) => const SalesKunjunganScreen(),
      ),
      GoRoute(
        path: '/sales/kunjungan/detail/:noJo',
        builder: (context, state) {
          final noJo = state.pathParameters['noJo'] ?? '';
          return DetailTokoScreen(noJo: noJo);
        },
      ),
      GoRoute(
        path: '/sales/kunjungan/wizard/:noJo',
        builder: (context, state) {
          final noJo = state.pathParameters['noJo'] ?? '';
          return WizardJurnalScreen(noJo: noJo);
        },
      ),
      GoRoute(
        path: '/sales/reschedule',
        builder: (context, state) => const SalesRescheduleScreen(),
      ),
      GoRoute(
        path: '/sales/reschedule/tambah',
        builder: (context, state) {
          final noJo = state.uri.queryParameters['noJo'];
          return FormRescheduleScreen(initialNoJo: noJo);
        },
      ),
      GoRoute(
        path: '/sales/kondite',
        builder: (context, state) => const KonditeSayaScreen(),
      ),

      // Modul Manajer Sales
      GoRoute(
        path: '/manajer/beranda',
        builder: (context, state) => const ManajerBerandaScreen(),
      ),
      GoRoute(
        path: '/manajer/reschedule',
        builder: (context, state) => const ManajerApprovalScreen(),
      ),
      GoRoute(
        path: '/manajer/kondite',
        builder: (context, state) => const ManajerKonditeScreen(),
      ),
      GoRoute(
        path: '/manajer/kondite/cetak',
        builder: (context, state) => const LembarCetakKonditeScreen(),
      ),
      GoRoute(
        path: '/manajer/laporan',
        builder: (context, state) => const ManajerLaporanScreen(),
      ),
      GoRoute(
        path: '/manajer/laporan/hasil-rekap',
        builder: (context, state) => const HasilRekapScreen(),
      ),

      // Placeholder Fallback
      GoRoute(
        path: '/admin/:menu',
        builder: (context, state) {
          final menu = state.pathParameters['menu'] ?? 'akun';
          return _RolePlaceholderScreen(
            role: 'admin_tagihan',
            roleLabel: 'Admin Tagihan',
            currentMenu: menu,
            accentColor: AppColors.adminTeal,
          );
        },
      ),
      GoRoute(
        path: '/sales/:menu',
        builder: (context, state) {
          final menu = state.pathParameters['menu'] ?? 'mapping';
          return _RolePlaceholderScreen(
            role: 'sales',
            roleLabel: 'Sales',
            currentMenu: menu,
            accentColor: AppColors.salesOrange,
          );
        },
      ),
      GoRoute(
        path: '/manajer/:menu',
        builder: (context, state) {
          final menu = state.pathParameters['menu'] ?? 'beranda';
          return _RolePlaceholderScreen(
            role: 'manajer_sales',
            roleLabel: 'Manajer Sales',
            currentMenu: menu,
            accentColor: AppColors.manajerBlue,
          );
        },
      ),
    ],
  );
});

class _RolePlaceholderScreen extends ConsumerWidget {
  final String role;
  final String roleLabel;
  final String currentMenu;
  final Color accentColor;

  const _RolePlaceholderScreen({
    required this.role,
    required this.roleLabel,
    required this.currentMenu,
    required this.accentColor,
  });

  List<RoleNavItem> _buildNavItems(bool enableReschedule) {
    if (role == 'admin_tagihan') {
      return const [
        RoleNavItem(
          label: 'Akun',
          icon: Icons.people_outline,
          route: '/admin/akun',
        ),
        RoleNavItem(
          label: 'Data',
          icon: Icons.storage_outlined,
          route: '/admin/data',
        ),
        RoleNavItem(
          label: 'Mapping',
          icon: Icons.grid_on_outlined,
          route: '/admin/mapping',
        ),
        RoleNavItem(
          label: 'Laporan',
          icon: Icons.assessment_outlined,
          route: '/admin/laporan',
        ),
      ];
    }

    if (role == 'manajer_sales') {
      return [
        const RoleNavItem(
          label: 'Beranda',
          icon: Icons.dashboard_outlined,
          route: '/manajer/beranda',
        ),
        if (enableReschedule)
          const RoleNavItem(
            label: 'Reschedule',
            icon: Icons.event_repeat_outlined,
            route: '/manajer/reschedule',
          ),
        const RoleNavItem(
          label: 'Kondite',
          icon: Icons.fact_check_outlined,
          route: '/manajer/kondite',
        ),
        const RoleNavItem(
          label: 'Laporan',
          icon: Icons.assessment_outlined,
          route: '/manajer/laporan',
        ),
      ];
    }

    return [
      const RoleNavItem(
        label: 'Mapping',
        icon: Icons.map_outlined,
        route: '/sales/mapping',
      ),
      const RoleNavItem(
        label: 'Kunjungan',
        icon: Icons.place_outlined,
        route: '/sales/kunjungan',
      ),
      if (enableReschedule)
        const RoleNavItem(
          label: 'Reschedule',
          icon: Icons.event_repeat_outlined,
          route: '/sales/reschedule',
        ),
      const RoleNavItem(
        label: 'Kondite',
        icon: Icons.star_outline,
        route: '/sales/kondite',
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final navItems = _buildNavItems(config.enableReschedule);
    final currentIndex = navItems.indexWhere(
      (item) => item.route.endsWith('/$currentMenu'),
    );

    return AppScaffold(
      roleLabel: roleLabel,
      menuTitle: currentMenu.toUpperCase(),
      accentColor: accentColor,
      navItems: navItems,
      currentNavIndex: currentIndex == -1 ? 0 : currentIndex,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Placeholder $roleLabel · Menu ${currentMenu.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menu ini akan aktif pada tahapan fitur berikutnya.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (role == 'manajer_sales') ...[
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Mode Sales',
                    isOutlined: true,
                    backgroundColor: AppColors.manajerBlue,
                    onPressed: () {
                      ref.read(authProvider.notifier).switchMode('sales');
                      context.go('/sales/mapping');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
