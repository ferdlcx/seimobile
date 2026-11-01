import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reschedule_provider.dart';

class ManajerApprovalScreen extends ConsumerWidget {
  const ManajerApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rescheduleProvider);
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

    final menungguList =
        state.items.where((i) => i.status.toLowerCase() == 'menunggu').toList();
    final diprosesList =
        state.items.where((i) => i.status.toLowerCase() != 'menunggu').toList();

    return AppScaffold(
      roleLabel: 'Manajer Sales',
      menuTitle: 'Reschedule',
      accentColor: AppColors.manajerBlue,
      navItems: navItems,
      currentNavIndex: 1,
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
        onRetry: () => ref.read(rescheduleProvider.notifier).loadReschedule(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Approval Reschedule Kunjungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Persetujuan perubahan jadwal rute sales',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 1: Pengajuan Menunggu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menunggu Persetujuan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusMenungguBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${menungguList.length} pengajuan',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusMenungguText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (menungguList.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Tidak ada pengajuan yang menunggu persetujuan.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...menungguList.map((item) {
                final lamaStr = AppFormat.formatTanggalSingkat(item.jadwalLama);
                final baruStr = AppFormat.formatTanggalSingkat(item.jadwalBaru);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.statusMenungguText,
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.namaToko,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            StatusBadge.reschedule(item.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sales: ${item.salesNama} · No JO: ${item.noJo}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$lamaStr  →  $baruStr',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Alasan: ${item.alasan}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.statusDitolakText,
                                  side: const BorderSide(
                                    color: AppColors.statusDitolakText,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final ok = await ref
                                      .read(rescheduleProvider.notifier)
                                      .prosesPersetujuan(
                                        id: item.id,
                                        disetujui: false,
                                      );
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Reschedule ditolak.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Tolak',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusSudahText,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final ok = await ref
                                      .read(rescheduleProvider.notifier)
                                      .prosesPersetujuan(
                                        id: item.id,
                                        disetujui: true,
                                      );
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Reschedule disetujui. Jadwal sales diperbarui.',
                                        ),
                                        backgroundColor:
                                            AppColors.statusSudahText,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Setujui',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),

            // Bagian 2: Sudah Diproses
            const Text(
              'Sudah Diproses',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            if (diprosesList.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Belum ada riwayat pengajuan yang diproses.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...diprosesList.map((item) {
                final lamaStr = AppFormat.formatTanggalSingkat(item.jadwalLama);
                final baruStr = AppFormat.formatTanggalSingkat(item.jadwalBaru);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.namaToko,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            StatusBadge.reschedule(item.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sales: ${item.salesNama} · $lamaStr → $baruStr',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
