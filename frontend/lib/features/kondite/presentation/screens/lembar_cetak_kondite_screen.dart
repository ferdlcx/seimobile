import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/manajer_kondite_provider.dart';

class LembarCetakKonditeScreen extends ConsumerWidget {
  const LembarCetakKonditeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manajerKonditeProvider);
    final config = ref.watch(appConfigProvider);

    final periodeStr = AppFormat.formatPeriodeBulanString(state.periode);
    final salesNama = state.selectedSales?.nama ?? 'Budi Santoso';
    final salesId = state.selectedSales?.id ?? 2;
    final tanggalCetak = AppFormat.formatTanggalHari(config.mockToday);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        title: const Text(
          'Lembar Cetak Kondite',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kertas Dokumen Formal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kop Dokumen
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'PT. S.E.U.I CENTRE PURWOKERTO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyHeader,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Distribusi Suku Cadang Motor · Purwokerto, Jawa Tengah',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        color: AppColors.navyHeader,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: 0.8,
                        color: AppColors.navyHeader,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Judul Dokumen
                const Center(
                  child: Text(
                    'LEMBAR PENILAIAN KONDITE SALES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Metadata Sales & Periode
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(110),
                    1: FixedColumnWidth(14),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        const Text(
                          'Nama Sales',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const Text(':', style: TextStyle(fontSize: 11)),
                        Text(
                          salesNama,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          'ID / NIK Sales',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const Text(':', style: TextStyle(fontSize: 11)),
                        Text(
                          'SLS-00$salesId',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          'Periode Penilaian',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const Text(':', style: TextStyle(fontSize: 11)),
                        Text(
                          periodeStr,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          'Tanggal Cetak',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const Text(':', style: TextStyle(fontSize: 11)),
                        Text(
                          tanggalCetak,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tabel 18 Kriteria
                Table(
                  border: TableBorder.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(30),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(45),
                    3: FixedColumnWidth(45),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                      ),
                      children: [
                        _buildTableHeader('NO'),
                        _buildTableHeader('KRITERIA PENILAIAN'),
                        _buildTableHeader('NILAI'),
                        _buildTableHeader('SKOR'),
                      ],
                    ),
                    ...state.kriteriaList.map((kriteria) {
                      final nilaiHuruf = state.detailNilai[kriteria.id] ?? 'B';
                      final bobot = config.bobotNilai[nilaiHuruf] ?? 100;

                      return TableRow(
                        children: [
                          _buildTableCell('${kriteria.urutan}', align: TextAlign.center),
                          _buildTableCell(kriteria.nama),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: NilaiKonditeBadge(nilai: nilaiHuruf),
                          ),
                          _buildTableCell('$bobot', align: TextAlign.center),
                        ],
                      );
                    }),
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.manajerBlue.withValues(alpha: 0.08),
                      ),
                      children: [
                        const SizedBox(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerRight,
                          child: const Text(
                            'NILAI AKHIR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.manajerBlue,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(
                            state.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.manajerBlue,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(
                            state.nilaiAkhir.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.manajerBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Kolom Tanda Tangan Digital
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mengetahui (Sales),',
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          '( $salesNama )',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Purwokerto, Tanggal Penilaian',
                          style: TextStyle(fontSize: 11),
                        ),
                        const Text(
                          'Manajer Sales,',
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.manajerBlue),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '✓ TTD DIGITAL VALID',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.manajerBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '( Maya Kusuma )',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Tombol Cetak & Simpan PDF
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Cetak Dokumen',
                  icon: Icons.print_outlined,
                  backgroundColor: AppColors.manajerBlue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mengirim perintah cetak ke printer...'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Simpan PDF',
                  icon: Icons.download_outlined,
                  isOutlined: true,
                  backgroundColor: AppColors.manajerBlue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dokumen lembar kondite berhasil disimpan sebagai PDF.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {TextAlign align = TextAlign.left}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      alignment: align == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
