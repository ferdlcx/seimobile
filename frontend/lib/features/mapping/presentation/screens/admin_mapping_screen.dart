import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/mapping_admin_provider.dart';
import '../widgets/excel_mapping_grid.dart';

/// Layar Penyusunan Mapping Tahunan oleh Admin Tagihan dengan Grid mirip Excel.
class AdminMappingScreen extends ConsumerWidget {
  const AdminMappingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mappingAdminProvider);
    final masterState = ref.watch(masterDataProvider);

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Susun mapping toko',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sales: Budi Santoso · Tahun 2026. Ketuk kotak untuk menandai bulan kunjungan.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Filter Wilayah
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: state.filterWilayahId == null,
                      selectedColor: AppColors.adminTeal,
                      labelStyle: TextStyle(
                        color: state.filterWilayahId == null
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) {
                          ref
                              .read(mappingAdminProvider.notifier)
                              .filterWilayah(null);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ...masterState.wilayahList.map((w) {
                      final isSelected = state.filterWilayahId == w.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(w.nama),
                          selected: isSelected,
                          selectedColor: AppColors.adminTeal,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            ref
                                .read(mappingAdminProvider.notifier)
                                .filterWilayah(val ? w.id : null);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Grid Excel
              ExcelMappingGrid(
                items: state.items,
                onToggleCell: (r, c) {
                  ref.read(mappingAdminProvider.notifier).toggleCell(r, c);
                },
              ),
              const SizedBox(height: 16),

              // Banner Berhasil Simpan
              if (state.isSavedSuccess) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.successBannerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.successBannerBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.successBannerText,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Mapping berhasil disimpan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successBannerText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mapping tersimpan. Sales melihatnya di menu Mapping.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.successBannerText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Disimpan 30 Okt 2026, 10:24. Sales Budi Santoso, ${state.items.length} toko, 12 bulan.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF065F46),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Lihat laporan',
                        backgroundColor: AppColors.adminTeal,
                        onPressed: () => context.go('/admin/laporan'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tombol Simpan Mapping
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
