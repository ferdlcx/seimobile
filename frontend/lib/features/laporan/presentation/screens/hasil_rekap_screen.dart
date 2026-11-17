import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/laporan_provider.dart';

/// Layar Hasil Cetak Laporan Rekap (Tabel Wilayah, Target, Real, Persen, dan Baris Total).
class HasilRekapScreen extends ConsumerWidget {
  final String backRoute;
  final String roleLabel;
  final Color accentColor;

  const HasilRekapScreen({
    super.key,
    this.backRoute = '/admin/laporan',
    this.roleLabel = 'Admin Tagihan',
    this.accentColor = AppColors.adminTeal,
  });

  List<RoleNavItem> _buildNavItems(bool enableReschedule) {
    if (backRoute.startsWith('/manajer')) {
      return [
        const RoleNavItem(
          label: 'Beranda',
          icon: Icons.home_outlined,
          route: '/manajer/beranda',
        ),
        if (enableReschedule)
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
    }

    return const [
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);
    final config = ref.watch(appConfigProvider);
    final rekap = state.rekap;
    final navItems = _buildNavItems(config.enableReschedule);

    return AppScaffold(
      roleLabel: roleLabel,
      menuTitle: 'Laporan',
      accentColor: accentColor,
      navItems: navItems,
      currentNavIndex: navItems.length - 1,
      onNavTap: (idx) => context.go(navItems[idx].route),
      onLogout: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/pilih-peran');
        }
      },
      body: StateView(
        isLoading: state.isLoading && rekap == null,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(laporanProvider.notifier).loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Kembali
              InkWell(
                onTap: () => context.go(backRoute),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: accentColor,
                      ),
                      Text(
                        'Laporan',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Hasil cetak laporan rekap',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              if (rekap != null) ...[
                // Lembar Dokumen Rekap
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'S.E.U.I CENTRE · LAPORAN REKAP',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyHeader,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Periode ${rekap.periodeLabel} · ${state.filterWilayahId == null ? "Semua wilayah" : "Filter wilayah"}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tabel Rekap dengan header Navy dan garis horizontal saja
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(3.2),
                            1: FlexColumnWidth(1.2),
                            2: FlexColumnWidth(1.1),
                            3: FlexColumnWidth(1.1),
                          },
                          children: [
                            // Header Tabel Navy
                            const TableRow(
                              decoration: BoxDecoration(
                                color: AppColors.navyHeader,
                              ),
                              children: [
                                _TableCell(text: 'Wilayah', isHeader: true),
                                _TableCell(text: 'Target', isHeader: true),
                                _TableCell(text: 'Real', isHeader: true),
                                _TableCell(text: '%', isHeader: true),
                              ],
                            ),
                            // Baris Data Wilayah
                            ...rekap.barisWilayah.map((b) {
                              return TableRow(
                                children: [
                                  _TableCell(text: b.wilayah),
                                  _TableCell(text: '${b.target}'),
                                  _TableCell(text: '${b.real}'),
                                  _TableCell(text: '${b.persen}%'),
                                ],
                              );
                            }),
                            // Baris TOTAL
                            TableRow(
                              children: [
                                const _TableCell(text: 'TOTAL', isBold: true),
                                _TableCell(
                                  text: '${rekap.totalTarget}',
                                  isBold: true,
                                ),
                                _TableCell(
                                  text: '${rekap.totalReal}',
                                  isBold: true,
                                ),
                                _TableCell(
                                  text: '${rekap.totalPersen}%',
                                  isBold: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Dicetak 30 Okt 2026, 19.57 WIB',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Cetak (Solid Aksen) & Simpan PDF (Soft Secondary)
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Cetak',
                        backgroundColor: accentColor,
                        onPressed: () async {
                          await PdfGenerator.cetakLaporanRekap(
                            rekapList: rekap.barisWilayah,
                            totalTarget: rekap.totalTarget,
                            totalReal: rekap.totalReal,
                            totalPersen: rekap.totalPersen,
                            periode: rekap.periodeLabel,
                            waktuCetak:
                                AppFormat.formatTanggalWaktu(rekap.waktuCetak),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Simpan PDF',
                        isSoftSecondary: true,
                        onPressed: () async {
                          await PdfGenerator.cetakLaporanRekap(
                            rekapList: rekap.barisWilayah,
                            totalTarget: rekap.totalTarget,
                            totalReal: rekap.totalReal,
                            totalPersen: rekap.totalPersen,
                            periode: rekap.periodeLabel,
                            waktuCetak:
                                AppFormat.formatTanggalWaktu(rekap.waktuCetak),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool isBold;

  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader || isBold ? FontWeight.w700 : FontWeight.w500,
          color: isHeader
              ? Colors.white
              : isBold
                  ? AppColors.textPrimary
                  : const Color(0xFF334155),
        ),
      ),
    );
  }
}
