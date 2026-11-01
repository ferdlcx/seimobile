import 'package:flutter/material.dart';

/// Palet warna dan tema S.E.U.I Centre berdasarkan desain visual.
class AppColors {
  static const Color navyHeader = Color(0xFF0F1B3D);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Warna aksen per peran
  static const Color adminTeal = Color(0xFF0E7C66);
  static const Color salesOrange = Color(0xFFC2570C);
  static const Color manajerBlue = Color(0xFF1D4ED8);

  // Badge status
  static const Color statusSudahBg = Color(0xFFDCFCE7);
  static const Color statusSudahText = Color(0xFF15803D);

  static const Color statusBelumBg = Color(0xFFFFEDD5);
  static const Color statusBelumText = Color(0xFFC2410C);

  static const Color statusMenungguBg = Color(0xFFFEF3C7);
  static const Color statusMenungguText = Color(0xFFB45309);

  static const Color statusDisetujuiBg = Color(0xFFDCFCE7);
  static const Color statusDisetujuiText = Color(0xFF15803D);

  static const Color statusDitolakBg = Color(0xFFFEE2E2);
  static const Color statusDitolakText = Color(0xFFB91C1C);

  static const Color warningBannerBg = Color(0xFFFFFBEB);
  static const Color warningBannerBorder = Color(0xFFFDE68A);
  static const Color warningBannerText = Color(0xFFB45309);

  static const Color successBannerBg = Color(0xFFECFDF5);
  static const Color successBannerBorder = Color(0xFFA7F3D0);
  static const Color successBannerText = Color(0xFF047857);

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
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
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
