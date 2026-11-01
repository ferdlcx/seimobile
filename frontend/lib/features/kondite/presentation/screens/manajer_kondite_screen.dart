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
import '../providers/manajer_kondite_provider.dart';

class ManajerKonditeScreen extends ConsumerWidget {
  const ManajerKonditeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manajerKonditeProvider);
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

    final periodeStr = AppFormat.formatPeriodeBulanString(state.periode);
    final selectedSalesNama = state.selectedSales?.nama ?? 'Budi Santoso';

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
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Penilaian Kondite Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Periode: $periodeStr · Evaluasi 18 Kriteria',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Pilihan Sales
            const Text(
              'Pilih Sales yang Dinilai:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: state.salesList.map((sales) {
                  final isSelected = sales.id == state.selectedSalesId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(sales.nama),
                      selected: isSelected,
                      selectedColor: AppColors.manajerBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) {
                          ref
                              .read(manajerKonditeProvider.notifier)
                              .loadPenilaianSales(sales.id);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Kartu Ringkasan Nilai Akhir
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyHeader, Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NILAI KONDITE · $selectedSalesNama',
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        periodeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        state.nilaiAkhir.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.manajerBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bobot: B=100 · C=75 · K=50 · SK=25 (Rata-rata 18 Kriteria)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 18 Kriteria Penilaian
            const Row(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 6),
                Text(
                  'Form Penilaian 18 Kriteria',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...state.kriteriaList.map((kriteria) {
              final nilaiSekarang = state.detailNilai[kriteria.id] ?? 'B';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${kriteria.urutan}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            kriteria.nama,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Segmented Button 4 Pilihan Nilai: B, C, K, SK
                    Row(
                      children: ['B', 'C', 'K', 'SK'].map((opsi) {
                        final isSelected = nilaiSekarang == opsi;

                        Color activeBg = AppColors.manajerBlue;
                        if (opsi == 'B') activeBg = AppColors.statusSudahText;
                        if (opsi == 'C') activeBg = AppColors.manajerBlue;
                        if (opsi == 'K') activeBg = AppColors.statusMenungguText;
                        if (opsi == 'SK') activeBg = AppColors.statusDitolakText;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: InkWell(
                              onTap: () {
                                ref
                                    .read(manajerKonditeProvider.notifier)
                                    .updateNilaiKriteria(kriteria.id, opsi);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeBg
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? activeBg
                                        : AppColors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Text(
                                  opsi,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
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
            const SizedBox(height: 16),

            // Tombol Simpan Penilaian
            PrimaryButton(
              label: 'Simpan Penilaian Kondite',
              backgroundColor: AppColors.manajerBlue,
              isLoading: state.isSaving,
              onPressed: () async {
                final ok = await ref
                    .read(manajerKonditeProvider.notifier)
                    .simpanPenilaian();
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Penilaian kondite berhasil disimpan.',
                      ),
                      backgroundColor: AppColors.manajerBlue,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Tombol Cetak PDF
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.manajerBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.manajerBlue,
                size: 20,
              ),
              label: const Text(
                'Cetak Lembar Kondite (PDF)',
                style: TextStyle(
                  color: AppColors.manajerBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                context.push('/manajer/kondite/cetak');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
