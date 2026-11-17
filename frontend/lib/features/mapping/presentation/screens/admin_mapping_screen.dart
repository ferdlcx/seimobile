import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/mapping_admin_provider.dart';
import '../widgets/excel_mapping_grid.dart';

/// Layar Penyusunan Mapping Tahunan oleh Admin Tagihan dengan Grid bergaya GitHub.
class AdminMappingScreen extends ConsumerWidget {
  const AdminMappingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mappingAdminProvider);
    final masterState = ref.watch(masterDataProvider);

    const navItems = [
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
      menuTitle: 'Mapping',
      accentColor: AppColors.adminTeal,
      navItems: navItems,
      currentNavIndex: 2,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: StateView(
        isLoading: state.isLoading && state.items.isEmpty,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(mappingAdminProvider.notifier).loadMapping(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.isSavedSuccess
                    ? 'Mapping berhasil disimpan'
                    : 'Susun mapping toko',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (!state.isSavedSuccess) ...[
                const Text(
                  'Sales: Budi Santoso · Tahun 2026. Ketuk kotak untuk menandai bulan kunjungan.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Wilayah (2 baris pill)
                WilayahFilterBar(
                  wilayahList: masterState.wilayahList,
                  selectedWilayahId: state.filterWilayahId,
                  activeColor: AppColors.adminTeal,
                  onSelected: (wilayahId) {
                    ref
                        .read(mappingAdminProvider.notifier)
                        .filterWilayah(wilayahId);
                  },
                ),
                const SizedBox(height: 12),
              ] else ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBannerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Mapping tersimpan. Sales melihatnya di menu Mapping.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.successBannerText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Grid GitHub 12 Bulan
              ExcelMappingGrid(
                items: state.items,
                onToggleCell: (r, c) {
                  ref.read(mappingAdminProvider.notifier).toggleCell(r, c);
                },
              ),
              const SizedBox(height: 14),

              if (state.isSavedSuccess) ...[
                Text(
                  'Disimpan 30 Okt 2026, 10.24. Sales Budi Santoso, ${state.items.length} toko, 12 bulan.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Lihat laporan',
                  backgroundColor: AppColors.adminTeal,
                  onPressed: () => context.go('/admin/laporan'),
                ),
              ] else
                PrimaryButton(
                  label: 'Simpan Mapping',
                  backgroundColor: AppColors.adminTeal,
                  isLoading: state.isLoading,
                  onPressed: () {
                    ref.read(mappingAdminProvider.notifier).saveMapping();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
