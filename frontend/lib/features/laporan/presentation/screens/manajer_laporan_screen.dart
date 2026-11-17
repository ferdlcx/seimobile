import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/laporan_provider.dart';

/// Layar Laporan & Rekap seluruh wilayah oleh Manajer Sales.
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

    final tokoList = masterState.tokoList.where((t) {
      if (state.filterWilayahId != null &&
          t.wilayah.id != state.filterWilayahId) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (a.sudahDikunjungiBulanIni == b.sudahDikunjungiBulanIni) return 0;
        return a.sudahDikunjungiBulanIni ? 1 : -1;
      });

    final tokoBelum =
        tokoList.where((t) => !t.sudahDikunjungiBulanIni).length;
    final totalToko = tokoList.length;
    final tokoSudah = totalToko - tokoBelum;
    final kepatuhanPersen = state.filterWilayahId == null
        ? (state.monitoring?.kepatuhanMapping ?? 75)
        : (totalToko > 0 ? ((tokoSudah / totalToko) * 100).round() : 0);

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
        isLoading: state.isLoading && state.monitoring == null,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(laporanProvider.notifier).loadData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            const Text(
              'Laporan & rekap',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Rekap kunjungan seluruh wilayah sales.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Filter Wilayah (2 baris pill biru)
            WilayahFilterBar(
              wilayahList: masterState.wilayahList,
              selectedWilayahId: state.filterWilayahId,
              activeColor: AppColors.manajerBlue,
              onSelected: (wilayahId) {
                ref.read(laporanProvider.notifier).filterWilayah(wilayahId);
              },
            ),
            const SizedBox(height: 14),

            // Card Peringatan Hari Ini (Gelap Navy)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.navyHeader,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERINGATAN HARI INI',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$tokoBelum toko belum dikunjungi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tindak lanjuti sebelum akhir bulan.',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Toko (Belum di atas)
            ...tokoList.map((toko) {
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
            const SizedBox(height: 6),

            // Kartu Metrik Kepatuhan Tutup & Realisasi
            Row(
              children: [
                Expanded(
                  child: Container(
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
                          'Kepatuhan tutup',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$kepatuhanPersen%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
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
                          'Realisasi',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$tokoSudah / $totalToko',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tombol Cetak Laporan Rekap
            PrimaryButton(
              label: 'Cetak Laporan Rekap',
              backgroundColor: AppColors.manajerBlue,
              onPressed: () {
                context.push('/manajer/laporan/hasil-rekap');
              },
            ),
          ],
        ),
      ),
    );
  }
}
