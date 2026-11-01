import 'package:intl/intl.dart';

/// Utilitas pemformatan tanggal dan angka Bahasa Indonesia.
class AppFormat {
  static const List<String> _hari = [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _bulanSingkat = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _bulanLengkap = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> bulanGridHeaders = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  /// Format tanggal menjadi `Jumat, 30 Okt 2026`.
  static String formatTanggalHari(DateTime date) {
    final namaHari = _hari[date.weekday];
    final namaBulan = _bulanSingkat[date.month];
    final hariStr = date.day.toString().padLeft(2, '0');
    return '$namaHari, $hariStr $namaBulan ${date.year}';
  }

  /// Format tanggal singkat menjadi `Sab, 03 Nov 2026`.
  static String formatTanggalHariSingkat(DateTime date) {
    final namaHari = _hari[date.weekday].substring(0, 3);
    final namaBulan = _bulanSingkat[date.month];
    final hariStr = date.day.toString().padLeft(2, '0');
    return '$namaHari, $hariStr $namaBulan ${date.year}';
  }

  /// Format tanggal menjadi `30 Okt 2026`.
  static String formatTanggalSingkat(DateTime date) {
    final namaBulan = _bulanSingkat[date.month];
    final hariStr = date.day.toString().padLeft(2, '0');
    return '$hariStr $namaBulan ${date.year}';
  }

  /// Format tanggal dan waktu menjadi `30 Okt 2026, 10:24`.
  static String formatTanggalWaktu(DateTime date) {
    final tgl = formatTanggalSingkat(date);
    final jam = DateFormat('HH:mm').format(date);
    return '$tgl, $jam';
  }

  /// Format periode menjadi `Oktober 2026`.
  static String formatPeriodeBulan(DateTime date) {
    return '${_bulanLengkap[date.month]} ${date.year}';
  }

  /// Format angka desimal 1 digit (misal 88.9).
  static String formatSatuDesimal(double val) {
    return val.toStringAsFixed(1);
  }
}
