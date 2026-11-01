import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin_data/presentation/providers/master_data_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/laporan_provider.dart';

/// Layar Monitoring & Laporan oleh Admin Tagihan.
class AdminLaporanScreen extends ConsumerWidget {
  const AdminLaporanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);
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

    final tokoList = masterState.tokoList.where((t) {
      if (state.filterWilayahId != null &&
          t.wilayah.id != state.filterWilayahId) {
        return false;
      }
      return true;
    }).toList();

    final tokoBelum =
        tokoList.where((t) => !t.sudahDikunjungiBulanIni).length;
    final totalToko = tokoList.length;
    final tokoSudah = totalToko - tokoBelum;
    final kepatuhanPersen = totalToko > 0
        ? ((tokoSudah / totalToko) * 100).round()
        : 0;

    return AppScaffold(
      roleLabel: 'Admin Tagihan',
      menuTitle: 'Laporan',
      accentColor: AppColors.adminTeal,
      navItems: navItems,
      currentNavIndex: 3,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            const Text(
              'Monitoring & laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Memastikan data tidak ada yang terlewat.',
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$tokoBelum toko belum dikunjungi bulan ini',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tindak lanjuti sebelum akhir bulan.',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Daftar Toko
            ...tokoList.map((toko) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                          Text(
                            toko.nama,
                            style: const TextStyle(
                              fontSize: 13,
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
            const SizedBox(height: 14),

            // Kartu Metrik Kepatuhan Tutup & Realisasi
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: (kepatuhanPersen / 100).clamp(0.0, 1.0),
                            minHeight: 4,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.adminTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Tombol Cetak Laporan Rekap
            PrimaryButton(
              label: 'Cetak Laporan Rekap',
              backgroundColor: AppColors.adminTeal,
              onPressed: () => context.go('/admin/laporan/hasil-rekap'),
            ),
          ],
        ),
      ),
    );
  }
}
