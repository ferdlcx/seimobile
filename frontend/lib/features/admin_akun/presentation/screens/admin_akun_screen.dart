import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/akun_provider.dart';

/// Layar Pengelolaan Akun & Hak Akses oleh Admin Tagihan.
class AdminAkunScreen extends ConsumerWidget {
  const AdminAkunScreen({super.key});

  Future<void> _handleToggleAktif(
    BuildContext context,
    WidgetRef ref,
    int id,
    String nama,
    bool currentValue,
  ) async {
    if (currentValue) {
      // Konfirmasi sebelum menonaktifkan akun
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nonaktifkan Akun?'),
          content: Text(
            'Pengguna "$nama" tidak akan bisa masuk ke aplikasi setelah dinonaktifkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusDitolakText,
                foregroundColor: Colors.white,
              ),
              child: const Text('Nonaktifkan'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await ref.read(akunProvider.notifier).setAktif(id, !currentValue);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(akunProvider);

    final navItems = const [
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

    return AppScaffold(
      roleLabel: 'Admin Tagihan',
      menuTitle: 'Akun',
      accentColor: AppColors.adminTeal,
      navItems: navItems,
      currentNavIndex: 0,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: StateView(
        isLoading: state.isLoading && state.akunList.isEmpty,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(akunProvider.notifier).loadAkun(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            const Text(
              'Akun & hak akses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Admin membuat akun karena pengguna tidak bisa mendaftar sendiri.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Banner Sukses jika baru tambah akun
            if (state.successBanner != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successBannerBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successBannerBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: AppColors.successBannerText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.successBanner!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.successBannerText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          ref.read(akunProvider.notifier).clearBanner(),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.successBannerText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Daftar Akun
            ...state.akunList.map((akun) {
              final statusText = akun.aktif ? 'aktif' : 'nonaktif';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  akun.nama,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (akun.isBaru) ...[
                                const SizedBox(width: 8),
                                const StatusBadge(
                                  text: 'BARU',
                                  type: StatusBadgeType.baru,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${akun.labelPeran} · $statusText',
                            style: TextStyle(
                              fontSize: 12,
                              color: akun.aktif
                                  ? AppColors.textSecondary
                                  : AppColors.statusDitolakText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: akun.aktif,
                      activeTrackColor: AppColors.adminTeal,
                      onChanged: (val) => _handleToggleAktif(
                        context,
                        ref,
                        akun.id,
                        akun.nama,
                        akun.aktif,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            PrimaryButton(
              label: '+ Tambah Akun',
              backgroundColor: AppColors.adminTeal,
              onPressed: () => context.go('/admin/akun/tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
