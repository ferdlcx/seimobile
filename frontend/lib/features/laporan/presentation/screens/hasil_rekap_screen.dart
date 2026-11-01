import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_view.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);
    final rekap = state.rekap;

    return AppScaffold(
      roleLabel: roleLabel,
      menuTitle: 'Hasil Rekap',
      accentColor: accentColor,
      body: StateView(
        isLoading: state.isLoading && rekap == null,
        errorMessage: state.errorMessage,
        onRetry: () => ref.read(laporanProvider.notifier).loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Kembali
              InkWell(
                onTap: () => context.go(backRoute),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: Color(0xFF2563EB),
                      ),
                      Text(
                        'Laporan',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Hasil cetak laporan rekap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              if (rekap != null) ...[
                // Lembar Dokumen Rekap
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'S.E.U.I CENTRE – LAPORAN REKAP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyHeader,
                          letterSpacing: 0.4,
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
                      const SizedBox(height: 16),

                      // Tabel Rekap
                      Table(
                        border: TableBorder.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(3.0),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.2),
                        },
                        children: [
                          // Header Tabel
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                            ),
                            children: const [
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
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                            ),
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
                      const SizedBox(height: 14),

                      Text(
                        'Dicetak 30 Okt 2026, 19:57 WIB',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Cetak & Simpan PDF
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Cetak',
                        isOutlined: true,
                        backgroundColor: accentColor,
                        onPressed: () async {
                          await PdfGenerator.cetakLaporanRekap(
                            rekapList: rekap.barisWilayah,
                            totalTarget: rekap.totalTarget,
                            totalReal: rekap.totalReal,
                            totalPersen: rekap.totalPersen,
                            periode: rekap.periodeLabel,
                            waktuCetak: AppFormat.formatTanggalWaktu(rekap.waktuCetak),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Simpan PDF',
                        backgroundColor: accentColor,
                        onPressed: () async {
                          await PdfGenerator.cetakLaporanRekap(
                            rekapList: rekap.barisWilayah,
                            totalTarget: rekap.totalTarget,
                            totalReal: rekap.totalReal,
                            totalPersen: rekap.totalPersen,
                            periode: rekap.periodeLabel,
                            waktuCetak: AppFormat.formatTanggalWaktu(rekap.waktuCetak),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: isHeader || isBold ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader || isBold ? FontWeight.w700 : FontWeight.w500,
          color: isHeader
              ? AppColors.textSecondary
              : isBold
                  ? AppColors.textPrimary
                  : const Color(0xFF334155),
        ),
      ),
    );
  }
}
