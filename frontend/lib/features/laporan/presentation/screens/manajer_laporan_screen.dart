import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/progress_card.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/laporan_provider.dart';

class ManajerLaporanScreen extends ConsumerWidget {
  const ManajerLaporanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);
    final masterState = ref.watch(masterDataProvider);
    final config = ref.watch(appConfigProvider);

    final navItems = [
      const RoleNavItem(
        label: 'Beranda',
        icon: Icons.dashboard_outlined,
        route: '/manajer/beranda',
      ),
      if (config.enableReschedule)
        const RoleNavItem(
          label: 'Reschedule',
          icon: Icons.approval_outlined,
          route: '/manajer/reschedule',
        ),
      const RoleNavItem(
        label: 'Kondite',
        icon: Icons.star_outline,
        route: '/manajer/kondite',
      ),
      const RoleNavItem(
        label: 'Laporan',
        icon: Icons.bar_chart_outlined,
        route: '/manajer/laporan',
      ),
    ];

    final monitoring = state.monitoring;
    final tanggalStr = AppFormat.formatTanggalHari(config.mockToday);

    return AppScaffold(
      roleLabel: 'Manajer Sales',
      menuTitle: 'Laporan',
      accentColor: AppColors.manajerBlue,
      navItems: navItems,
      currentNavIndex: config.enableReschedule ? 3 : 2,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: StateView(
        isLoading: state.isLoading && monitoring == null,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(laporanProvider.notifier).loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Monitoring & Laporan Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Update realisasi per $tanggalStr',
              style: const TextStyle(
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
                    label: const Text('Semua Wilayah'),
                    selected: state.filterWilayahId == null,
                    selectedColor: AppColors.manajerBlue,
                    labelStyle: TextStyle(
                      color: state.filterWilayahId == null
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) {
                        ref.read(laporanProvider.notifier).filterWilayah(null);
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
                        selectedColor: AppColors.manajerBlue,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          ref
                              .read(laporanProvider.notifier)
                              .filterWilayah(val ? w.id : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Peringatan Toko Lama Belum Dikunjungi
            if (monitoring != null && monitoring.peringatan.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBannerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warningBannerBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warningBannerText,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PERINGATAN HARI INI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warningBannerText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...monitoring.peringatan.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '• $p',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.warningBannerText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Progress Card Kepatuhan & Realisasi
            if (monitoring != null) ...[
              ProgressCard(
                title: 'KEPATUHAN JADWAL MAPPING',
                mainValue: '${monitoring.kepatuhanMapping}%',
                subtitle:
                    'Realisasi kunjungan sesuai jadwal mapping bulan berjalan',
                progress: monitoring.kepatuhanMapping / 100,
                progressColor: AppColors.manajerBlue,
              ),
              const SizedBox(height: 12),
              ProgressCard(
                title: 'REALISASI KUNJUNGAN TOKO',
                mainValue:
                    '${monitoring.kunjungan} / ${monitoring.targetKunjungan}',
                subtitle:
                    'Target kunjungan bulanan (${monitoring.order} order diperoleh)',
                progress: monitoring.targetKunjungan > 0
                    ? monitoring.kunjungan / monitoring.targetKunjungan
                    : 0.0,
                progressColor: AppColors.manajerBlue,
              ),
            ],
            const SizedBox(height: 20),

            // Tombol Cetak Laporan Rekap
            PrimaryButton(
              label: 'Cetak Laporan Rekap',
              icon: Icons.print_outlined,
              backgroundColor: AppColors.manajerBlue,
              onPressed: () {
                context.push('/manajer/laporan/hasil-rekap');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
