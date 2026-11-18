import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/progress_card.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/mapping_hari_ini_provider.dart';

/// Layar Mapping Hari Ini untuk peran Sales.
class SalesMappingScreen extends ConsumerWidget {
  const SalesMappingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mappingHariIniProvider);
    final masterState = ref.watch(masterDataProvider);
    final auth = ref.watch(authProvider);
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

    final salesNama = auth.session?.user.nama ?? 'Budi Santoso';
    final tanggalStr = AppFormat.formatTanggalHari(config.mockToday);

    final data = state.data;
    final total = data?.totalTarget ?? 6;
    final sudah = data?.sudahDikunjungi ?? 4;
    final progress = total > 0 ? (sudah / total) : 0.0;

    return AppScaffold(
      roleLabel: 'Sales',
      menuTitle: 'Mapping',
      accentColor: AppColors.salesOrange,
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
        isLoading: state.isLoading && data == null,
        errorMessage: state.errorMessage,
        onRetry: () =>
            ref.read(mappingHariIniProvider.notifier).loadMappingHariIni(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            const Text(
              'Mapping hari ini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$tanggalStr · $salesNama',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Filter Wilayah (2 baris pill)
            WilayahFilterBar(
              wilayahList: masterState.wilayahList,
              selectedWilayahId: state.filterWilayahId,
              activeColor: AppColors.salesOrange,
              onSelected: (wilayahId) {
                ref
                    .read(mappingHariIniProvider.notifier)
                    .filterWilayah(wilayahId);
              },
            ),
            const SizedBox(height: 12),

            // Kartu Progres Rute Hari Ini
            ProgressCard(
              title: 'PROGRESS RUTE HARI INI',
              mainValue: '$sudah / $total',
              subtitle: '$sudah dari $total toko sudah dikunjungi',
              progress: progress,
              progressColor: Colors.white,
            ),
            const SizedBox(height: 12),

            // Daftar Toko
            if (data != null) ...[
              ...data.daftarToko.map((toko) {
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
                              toko.nama,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${toko.noJo} · ${toko.wilayah.nama}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.kunjungan(toko.sudahDikunjungiBulanIni),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Mulai Check-in',
              backgroundColor: AppColors.salesOrange,
              onPressed: () => context.go('/sales/kunjungan'),
            ),
            if (auth.role == 'manajer_sales') ...[
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Kembali ke Mode Manajer',
                isOutlined: true,
                backgroundColor: AppColors.manajerBlue,
                onPressed: () {
                  ref.read(authProvider.notifier).switchMode('manajer');
                  context.go('/manajer/beranda');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
