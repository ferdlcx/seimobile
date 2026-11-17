import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/pill_filter_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/manajer_kondite_provider.dart';

/// Layar Penilaian Kondite 18 Kriteria oleh Manajer Sales.
class ManajerKonditeScreen extends ConsumerStatefulWidget {
  const ManajerKonditeScreen({super.key});

  @override
  ConsumerState<ManajerKonditeScreen> createState() =>
      _ManajerKonditeScreenState();
}

class _ManajerKonditeScreenState extends ConsumerState<ManajerKonditeScreen> {
  bool _showAllCriteria = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manajerKonditeProvider);
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

    final displayedKriteria = _showAllCriteria
        ? state.kriteriaList
        : state.kriteriaList.take(6).toList();

    return AppScaffold(
      roleLabel: 'Manajer Sales',
      menuTitle: 'Kondite',
      accentColor: AppColors.manajerBlue,
      navItems: navItems,
      currentNavIndex: config.enableReschedule ? 2 : 1,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: StateView(
        isLoading: state.isLoading && state.salesList.isEmpty,
        errorMessage: state.errorMessage,
        onRetry: () =>
            ref.read(manajerKonditeProvider.notifier).loadInitialData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            const Text(
              'Nilai kondite',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Penilaian bulanan 18 kriteria. Pilih nilai B, C, K, atau SK.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Pilihan Sales (Pill Chips)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: state.salesList.map((sales) {
                return PillChip(
                  label: sales.nama,
                  selected: sales.id == state.selectedSalesId,
                  activeColor: AppColors.manajerBlue,
                  onTap: () {
                    ref
                        .read(manajerKonditeProvider.notifier)
                        .loadPenilaianSales(sales.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Kartu Gelap Navy Nilai Akhir
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
                    'NILAI AKHIR',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.nilaiAkhir.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Kriteria (Baris Horizontal Ringkas B / C / K / SK)
            ...displayedKriteria.map((kriteria) {
              final nilaiSekarang = state.detailNilai[kriteria.id] ?? 'B';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        kriteria.nama,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['B', 'C', 'K', 'SK'].map((opsi) {
                        final isSelected = nilaiSekarang == opsi;

                        Color activeBg = AppColors.manajerBlue;
                        if (opsi == 'B') activeBg = AppColors.adminTeal;
                        if (opsi == 'C') activeBg = AppColors.manajerBlue;
                        if (opsi == 'K') activeBg = AppColors.statusMenungguText;
                        if (opsi == 'SK') activeBg = AppColors.statusDitolakText;

                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(manajerKonditeProvider.notifier)
                                  .updateNilaiKriteria(kriteria.id, opsi);
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? activeBg : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? activeBg
                                      : AppColors.borderStrong,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                opsi,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),

            if (state.kriteriaList.length > 6)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() => _showAllCriteria = !_showAllCriteria);
                  },
                  child: Text(
                    _showAllCriteria
                        ? 'Ringkas 6 kriteria'
                        : 'Lihat semua ${state.kriteriaList.length} kriteria',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.manajerBlue,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // Tombol Cetak Lembar Kondite (PDF) — Simpan otomatis lalu buka pratinjau
            PrimaryButton(
              label: 'Cetak Lembar Kondite (PDF)',
              backgroundColor: AppColors.manajerBlue,
              isLoading: state.isSaving,
              onPressed: () async {
                final ok = await ref
                    .read(manajerKonditeProvider.notifier)
                    .simpanPenilaian();
                if (ok && context.mounted) {
                  context.push('/manajer/kondite/cetak');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
