import 'package:flutter/material.dart';

/// Palet warna dan tema S.E.U.I Centre berdasarkan desain visual mockup Figma.
class AppColors {
  static const Color navyHeader = Color(0xFF0B1B3A);
  static const Color background = Color(0xFFFFFFFF);
  static const Color softSurface = Color(0xFFF8FAFC);
  static const Color softSlate = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);
  static const Color textPrimary = Color(0xFF0B1B3A);
  static const Color textSecondary = Color(0xFF64748B);

  // Warna aksen per peran (sesuai reference/*.md)
  static const Color adminTeal = Color(0xFF0F7B6C);
  static const Color salesOrange = Color(0xFFC2540A);
  static const Color manajerBlue = Color(0xFF1D4ED8);

  // Badge status
  static const Color statusSudahBg = Color(0xFFDCFCE7);
  static const Color statusSudahText = Color(0xFF15803D);

  static const Color statusBelumBg = Color(0xFFFFEDD5);
  static const Color statusBelumText = Color(0xFFC2540A);

  static const Color statusMenungguBg = Color(0xFFFEF3C7);
  static const Color statusMenungguText = Color(0xFFB45309);

  static const Color statusDisetujuiBg = Color(0xFFDCFCE7);
  static const Color statusDisetujuiText = Color(0xFF15803D);

  static const Color statusDitolakBg = Color(0xFFFEE2E2);
  static const Color statusDitolakText = Color(0xFFB91C1C);

  static const Color warningBannerBg = Color(0xFFFFF7ED);
  static const Color warningBannerBorder = Color(0xFFFED7AA);
  static const Color warningBannerText = Color(0xFFB45309);

  static const Color successBannerBg = Color(0xFFDCFCE7);
  static const Color successBannerBorder = Color(0xFFA7F3D0);
  static const Color successBannerText = Color(0xFF15803D);

  static Color accentForRole(String? role, {String? mode}) {
    if (role == 'admin_tagihan') return adminTeal;
    if (role == 'manajer_sales') {
      return mode == 'sales' ? salesOrange : manajerBlue;
    }
    return salesOrange;
  }
}

class AppTheme {
  static ThemeData lightTheme({Color primaryColor = AppColors.navyHeader}) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: AppColors.cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.statusDitolakText),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}
