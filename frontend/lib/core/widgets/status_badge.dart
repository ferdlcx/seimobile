import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Jenis badge status sesuai spesifikasi desain.
enum StatusBadgeType {
  sudah,
  belum,
  menunggu,
  disetujui,
  ditolak,
  baru,
  info,
}

/// Komponen badge status (Sudah, Belum, Menunggu, Disetujui, Ditolak, BARU)
/// serta badge kotak kecil untuk nilai kondite (B, C, K, SK).
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusBadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
  });

  factory StatusBadge.kunjungan(bool sudah) {
    return StatusBadge(
      text: sudah ? 'Sudah' : 'Belum',
      type: sudah ? StatusBadgeType.sudah : StatusBadgeType.belum,
    );
  }

  factory StatusBadge.reschedule(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return const StatusBadge(
          text: 'Disetujui',
          type: StatusBadgeType.disetujui,
        );
      case 'ditolak':
        return const StatusBadge(
          text: 'Ditolak',
          type: StatusBadgeType.ditolak,
        );
      case 'menunggu':
      default:
        return const StatusBadge(
          text: 'Menunggu',
          type: StatusBadgeType.menunggu,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;

    switch (type) {
      case StatusBadgeType.sudah:
      case StatusBadgeType.disetujui:
        bg = AppColors.statusSudahBg;
        fg = AppColors.statusSudahText;
        break;
      case StatusBadgeType.belum:
        bg = AppColors.statusBelumBg;
        fg = AppColors.statusBelumText;
        break;
      case StatusBadgeType.menunggu:
        bg = AppColors.statusMenungguBg;
        fg = AppColors.statusMenungguText;
        break;
      case StatusBadgeType.ditolak:
        bg = AppColors.statusDitolakBg;
        fg = AppColors.statusDitolakText;
        break;
      case StatusBadgeType.baru:
        bg = const Color(0xFFDBEAFE);
        fg = AppColors.manajerBlue;
        break;
      case StatusBadgeType.info:
        bg = const Color(0xFFE0E7FF);
        fg = AppColors.manajerBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge kotak kecil nilai kriteria kondite (B / C / K / SK).
class NilaiKonditeBadge extends StatelessWidget {
  final String nilai; // 'B' | 'C' | 'K' | 'SK'

  const NilaiKonditeBadge({super.key, required this.nilai});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (nilai) {
      case 'B':
        bg = AppColors.statusSudahBg;
        fg = AppColors.statusSudahText;
        break;
      case 'C':
        bg = const Color(0xFFDBEAFE);
        fg = AppColors.manajerBlue;
        break;
      case 'K':
        bg = AppColors.statusMenungguBg;
        fg = AppColors.statusMenungguText;
        break;
      case 'SK':
      default:
        bg = AppColors.statusDitolakBg;
        fg = AppColors.statusDitolakText;
        break;
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        nilai,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
