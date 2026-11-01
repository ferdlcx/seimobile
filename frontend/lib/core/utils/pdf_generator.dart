import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/admin_data/data/models/master_models.dart';
import '../../features/monitoring/data/models/monitoring_models.dart';

/// Utilitas pembuatan dan pencetakan dokumen PDF resmi S.E.U.I Centre.
class PdfGenerator {
  /// Mencetak atau menyimpan dokumen PDF Lembar Penilaian Kondite Sales.
  static Future<void> cetakLembarKondite({
    required String salesNama,
    required int salesId,
    required String periode,
    required double nilaiAkhir,
    required String label,
    required List<Kriteria> kriteriaList,
    required Map<int, String> detailNilai,
    required Map<String, int> bobotNilai,
    required String tanggalCetak,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kop Dokumen
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PT. S.E.U.I CENTRE PURWOKERTO',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Distribusi Suku Cadang Motor · Purwokerto, Jawa Tengah',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(height: 1.5, color: PdfColors.blue900),
                    pw.SizedBox(height: 1.5),
                    pw.Container(height: 0.5, color: PdfColors.blue900),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Judul Dokumen
              pw.Center(
                child: pw.Text(
                  'LEMBAR PENILAIAN KONDITE SALES',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              // Metadata Identitas
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Nama Sales: $salesNama',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'ID / NIK: SLS-00$salesId',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Periode: $periode',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Tanggal Cetak: $tanggalCetak',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // Tabel 18 Kriteria
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(28),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(45),
                  3: pw.FixedColumnWidth(45),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPdfHeader('NO'),
                      _buildPdfHeader('KRITERIA PENILAIAN'),
                      _buildPdfHeader('NILAI'),
                      _buildPdfHeader('BOBOT'),
                    ],
                  ),
                  ...kriteriaList.map((k) {
                    final huruf = detailNilai[k.id] ?? 'B';
                    final skor = bobotNilai[huruf] ?? 100;
                    return pw.TableRow(
                      children: [
                        _buildPdfCell('${k.urutan}', align: pw.TextAlign.center),
                        _buildPdfCell(k.nama),
                        _buildPdfCell(huruf, align: pw.TextAlign.center, isBold: true),
                        _buildPdfCell('$skor', align: pw.TextAlign.center),
                      ],
                    );
                  }),
                  // Baris Nilai Akhir
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      pw.Container(),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'NILAI AKHIR',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          label,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          nilaiAkhir.toStringAsFixed(1),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Kolom Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Mengetahui (Sales),',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text(
                        '( $salesNama )',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Purwokerto, Tanggal Penilaian',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Manajer Sales,',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.blue900),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(3),
                          ),
                        ),
                        child: pw.Text(
                          'TTD DIGITAL VALID',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        '( Maya Kusuma )',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Lembar_Kondite_${salesNama.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Mencetak atau menyimpan dokumen PDF Laporan Rekap Wilayah.
  static Future<void> cetakLaporanRekap({
    required List<RekapWilayah> rekapList,
    required int totalTarget,
    required int totalReal,
    required int totalPersen,
    required String periode,
    required String waktuCetak,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kop Dokumen
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PT. S.E.U.I CENTRE PURWOKERTO',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Distribusi Suku Cadang Motor · Purwokerto, Jawa Tengah',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(height: 1.5, color: PdfColors.teal900),
                    pw.SizedBox(height: 1.5),
                    pw.Container(height: 0.5, color: PdfColors.teal900),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Judul Dokumen
              pw.Center(
                child: pw.Text(
                  'LAPORAN REKAP KUNJUNGAN TOKO PER WILAYAH',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Periode: $periode',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Waktu Cetak: $waktuCetak',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 14),

              // Tabel Rekap
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FixedColumnWidth(28),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(70),
                  3: pw.FixedColumnWidth(70),
                  4: pw.FixedColumnWidth(65),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildPdfHeader('NO'),
                      _buildPdfHeader('WILAYAH'),
                      _buildPdfHeader('TARGET'),
                      _buildPdfHeader('REALISASI'),
                      _buildPdfHeader('% PERSEN'),
                    ],
                  ),
                  ...rekapList.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        _buildPdfCell('$idx', align: pw.TextAlign.center),
                        _buildPdfCell(item.wilayah),
                        _buildPdfCell('${item.target}', align: pw.TextAlign.center),
                        _buildPdfCell('${item.real}', align: pw.TextAlign.center),
                        _buildPdfCell('${item.persen}%', align: pw.TextAlign.center),
                      ],
                    );
                  }),
                  // Baris Total
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      pw.Container(),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal900,
                          ),
                        ),
                      ),
                      _buildPdfCell('$totalTarget',
                          align: pw.TextAlign.center, isBold: true),
                      _buildPdfCell('$totalReal',
                          align: pw.TextAlign.center, isBold: true),
                      _buildPdfCell('$totalPersen%',
                          align: pw.TextAlign.center, isBold: true),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Tanda tangan Admin
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Purwokerto, Tanggal Cetak',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Petugas Admin Tagihan,',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 40),
                    pw.Text('( Andi Pratama )',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Laporan_Rekap_Wilayah_${periode.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildPdfHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildPdfCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isBold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: align == pw.TextAlign.center
          ? pw.Alignment.center
          : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
