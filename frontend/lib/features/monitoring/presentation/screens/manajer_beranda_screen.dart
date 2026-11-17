import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/monitoring_provider.dart';

/// Layar Beranda & Monitoring oleh Manajer Sales.
class ManajerBerandaScreen extends ConsumerWidget {
  const ManajerBerandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringProvider);
    final config = ref.watch(appConfigProvider);

    final navItems = [
      const RoleNavItem(
        label: 'Beranda',
        icon: Icons.home_outlined,
        route: '/manajer/beranda',
      ),
      if (config.enableReschedule)
        const RoleNavItem(
          label: 'Reschedule',
          icon: Icons.calendar_today_outlined,
          route: '/manajer/reschedule',
        ),
      const RoleNavItem(
        label: 'Kondite',
        icon: Icons.star_outline,
        route: '/manajer/kondite',
      ),
      const RoleNavItem(
        label: 'Laporan',
        icon: Icons.description_outlined,
        route: '/manajer/laporan',
      ),
    ];

    final ringkasan = state.ringkasan;
    final tanggalStr =
        AppFormat.formatTanggalHari(config.mockToday).replaceFirst(', ', ' ');

    return AppScaffold(
      roleLabel: 'Manajer Sales',
      menuTitle: 'Beranda',
      accentColor: AppColors.manajerBlue,
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
        isLoading: state.isLoading && ringkasan == null,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(monitoringProvider.notifier).loadMonitoring(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            const Text(
              'Beranda & monitoring',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ringkasan tim hari ini, $tanggalStr.',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // 3 Kartu Metrik Ringkasan Atas
            if (ringkasan != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Kunjungan',
                      value:
                          '${ringkasan.kunjungan}/${ringkasan.targetKunjungan}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Order',
                      value: '${ringkasan.order}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Reschedule',
                      value: '${ringkasan.rescheduleMenunggu}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Banner Peringatan 1 Baris
              if (ringkasan.peringatan.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusBelumBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ringkasan.peringatan.first,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningBannerText,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Realisasi Per Sales
              const Text(
                'REALISASI PER SALES',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              ...ringkasan.progresPerSales.asMap().entries.map((entry) {
                final idx = entry.key;
                final ps = entry.value;
                final isPrimary = idx == 0;
                final badgeBg = isPrimary
                    ? const Color(0xFFDBEAFE)
                    : AppColors.statusBelumBg;
                final badgeFg =
                    isPrimary ? AppColors.manajerBlue : AppColors.salesOrange;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
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
                            Text(
                              ps.salesNama,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${ps.realisasi} dari ${ps.target} toko',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${ps.persen}%',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: badgeFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),

              // Kartu Kepatuhan Mapping
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kepatuhan mapping',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (ringkasan.kepatuhanMapping / 100)
                            .clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.manajerBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${ringkasan.kepatuhanMapping}% jadwal sesuai mapping',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tombol Mode Sales di bawah
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
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
