import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/manajer_kondite_provider.dart';

/// Layar Hasil Cetak Lembar Kondite Sales (pratinjau dokumen + tanda tangan digital).
class LembarCetakKonditeScreen extends ConsumerWidget {
  const LembarCetakKonditeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final periodeStr = AppFormat.formatPeriodeBulanString(state.periode);
    final salesNama = state.selectedSales?.nama ?? 'Budi Santoso';
    final salesId = state.selectedSales?.id ?? 2;
    final tanggalSingkat = AppFormat.formatTanggalSingkat(config.mockToday);
    final tanggalCetakPdf = AppFormat.formatTanggalHari(config.mockToday);

    // 6 kriteria utama ditampilkan ringkas di pratinjau agar proporsional dengan mockup
    final previewKriteria = state.kriteriaList.take(6).toList();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Kembali "< Penilaian"
            InkWell(
              onTap: () => context.go('/manajer/kondite'),
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: AppColors.manajerBlue,
                    ),
                    Text(
                      'Penilaian',
                      style: TextStyle(
                        color: AppColors.manajerBlue,
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
              'Hasil cetak lembar kondite',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Kartu Dokumen Lembar Kondite
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
                    'S.E.U.I CENTRE · LEMBAR KONDITE',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyHeader,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$salesNama · Periode $periodeStr',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tabel 2 Kolom (Kriteria | Nilai) dengan header Navy
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Table(
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          color: AppColors.border,
                          width: 0.8,
                        ),
                        bottom: BorderSide(
                          color: AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(3.4),
                        1: FlexColumnWidth(1.4),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.navyHeader,
                          ),
                          children: [
                            _DocCell(text: 'Kriteria', isHeader: true),
                            _DocCell(text: 'Nilai', isHeader: true),
                          ],
                        ),
                        ...previewKriteria.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final k = entry.value;
                          final nilaiHuruf = state.detailNilai[k.id] ?? 'B';
                          final bgColor = idx.isEven
                              ? AppColors.softSurface
                              : Colors.white;

                          return TableRow(
                            decoration: BoxDecoration(color: bgColor),
                            children: [
                              _DocCell(text: k.nama),
                              _DocCell(text: nilaiHuruf),
                            ],
                          );
                        }),
                        TableRow(
                          decoration: const BoxDecoration(
                            color: AppColors.softSurface,
                          ),
                          children: [
                            const _DocCell(text: 'NILAI AKHIR', isBold: true),
                            _DocCell(
                              text:
                                  '${state.nilaiAkhir.toStringAsFixed(1)} · ${state.label}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Tanda tangan digital Manajer Sales',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Goresan Tanda Tangan Digital
                  SizedBox(
                    width: 110,
                    height: 30,
                    child: CustomPaint(
                      painter: _SignaturePainter(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Maya Kusuma · $tanggalSingkat',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tombol Cetak (Biru Solid) & Simpan PDF (Soft Secondary)
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Cetak',
                    backgroundColor: AppColors.manajerBlue,
                    onPressed: () async {
                      await PdfGenerator.cetakLembarKondite(
                        salesNama: salesNama,
                        salesId: salesId,
                        periode: periodeStr,
                        nilaiAkhir: state.nilaiAkhir,
                        label: state.label,
                        kriteriaList: state.kriteriaList,
                        detailNilai: state.detailNilai,
                        bobotNilai: config.bobotNilai,
                        tanggalCetak: tanggalCetakPdf,
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
                      await PdfGenerator.cetakLembarKondite(
                        salesNama: salesNama,
                        salesId: salesId,
                        periode: periodeStr,
                        nilaiAkhir: state.nilaiAkhir,
                        label: state.label,
                        kriteriaList: state.kriteriaList,
                        detailNilai: state.detailNilai,
                        bobotNilai: config.bobotNilai,
                        tanggalCetak: tanggalCetakPdf,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DocCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool isBold;

  const _DocCell({
    required this.text,
    this.isHeader = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
      child: Text(
        text,
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

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navyHeader
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(4, 24)
      ..cubicTo(10, 4, 15, 4, 16, 20)
      ..cubicTo(18, 28, 25, 10, 32, 12)
      ..cubicTo(36, 13, 35, 22, 41, 21)
      ..cubicTo(46, 20, 50, 12, 57, 13)
      ..cubicTo(66, 14, 78, 17, 96, 18);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
