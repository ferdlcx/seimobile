import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/monitoring_provider.dart';

class ManajerBerandaScreen extends ConsumerWidget {
  const ManajerBerandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringProvider);
    final auth = ref.watch(authProvider);
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

    final ringkasan = state.ringkasan;
    final tanggalStr = AppFormat.formatTanggalHari(config.mockToday);
    final manajerNama = auth.session?.user.nama ?? 'Maya Kusuma';

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
          padding: const EdgeInsets.all(16),
          children: [
            // Baris Judul & Tombol Beralih ke Mode Sales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monitoring Sales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$tanggalStr · $manajerNama',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.salesOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text(
                    'Mode Sales',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    // Pindah ke mode Sales tanpa logout
                    ref.read(authProvider.notifier).switchMode('sales');
                    context.go('/sales/mapping');
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Filter Wilayah Chips
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
                        ref.read(monitoringProvider.notifier).filterWilayah(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ...state.wilayahList.map((w) {
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
                              .read(monitoringProvider.notifier)
                              .filterWilayah(val ? w.id : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Peringatan Toko Lama Belum Dikunjungi
            if (ringkasan != null && ringkasan.peringatan.isNotEmpty)
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
                          'PERINGATAN MONITORING HARI INI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warningBannerText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...ringkasan.peringatan.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                  color: AppColors.warningBannerText,
                                  fontWeight: FontWeight.bold,
                                )),
                            Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warningBannerText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 3 Kartu Ringkasan Atas
            if (ringkasan != null)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Kunjungan',
                      value: '${ringkasan.kunjungan}/${ringkasan.targetKunjungan}',
                      icon: Icons.storefront_outlined,
                      color: AppColors.manajerBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Order',
                      value: '${ringkasan.order}',
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.salesOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Reschedule',
                      value: '${ringkasan.rescheduleMenunggu}',
                      icon: Icons.event_repeat_outlined,
                      color: AppColors.statusMenungguText,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Kartu Kepatuhan Mapping
            if (ringkasan != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kepatuhan Jadwal Mapping',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${ringkasan.kepatuhanMapping}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.manajerBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (ringkasan.kepatuhanMapping / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.manajerBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tingkat kunjungan sesuai jadwal mapping bulan ini.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Progres Realisasi Per Sales
            const Text(
              'Realisasi Kunjungan Per Sales',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            if (ringkasan != null)
              ...ringkasan.progresPerSales.map((ps) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ps.salesNama,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${ps.realisasi} / ${ps.target} toko (${ps.persen}%)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.manajerBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ps.target > 0
                              ? (ps.realisasi / ps.target).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.salesOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
