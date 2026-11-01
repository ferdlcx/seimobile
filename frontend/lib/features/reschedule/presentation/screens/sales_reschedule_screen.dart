import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reschedule_provider.dart';

class SalesRescheduleScreen extends ConsumerWidget {
  const SalesRescheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rescheduleProvider);
    final config = ref.watch(appConfigProvider);

    final navItems = [
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
      if (config.enableReschedule)
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

    return AppScaffold(
      roleLabel: 'Sales',
      menuTitle: 'Reschedule',
      accentColor: AppColors.salesOrange,
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
        onRetry: () => ref.read(rescheduleProvider.notifier).loadReschedule(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner Info Desain PNG
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jadwal berubah, toko tidak bisa dikunjungi sesuai mapping.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Baris Judul & Tombol Pengajuan Baru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Pengajuan Reschedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Perubahan jadwal kunjungan toko',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  label: '+ Pengajuan Baru',
                  width: 150,
                  backgroundColor: AppColors.salesOrange,
                  onPressed: () => context.push('/sales/reschedule/tambah'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state.items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: const Text(
                  'Belum ada pengajuan reschedule.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...state.items.map((item) {
                final lamaStr = AppFormat.formatTanggalSingkat(item.jadwalLama);
                final baruStr = AppFormat.formatTanggalSingkat(item.jadwalBaru);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
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
                          'No JO: ${item.noJo}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
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
