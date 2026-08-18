// ===================================================================
// FILE: app_theme.dart
// PHỤ TRÁCH: Nguyễn Lê Chí Khải
// TASK GỐC: các task "Thiết kế UI ..." tuần 1 — dùng chung 1 design system
// cho toàn bộ màn hình (đúng theo mockup Figma: nền trắng, xanh dương chủ đạo).
// ===================================================================

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF3B5BFE);
  static const Color darkNavy = Color(0xFF1A2B6B);
  static const Color background = Color(0xFFF6F7FB);
  static const Color cardSurface = Colors.white;
  static const Color success = Color(0xFF1FAA59);
  static const Color danger = Color(0xFFE5484D);
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF8A8FA3);
  static const Color divider = Color(0xFFE7E9F1);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        background: AppColors.background,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}
