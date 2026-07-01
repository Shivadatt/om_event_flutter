import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Application theme configuration.
/// All color references delegate to [AppColors].
class AppTheme {
  // ── Deprecated direct color fields — use AppColors instead ────────────────
  static const Color lightCream = AppColors.lightCream;
  static const Color lightInk = AppColors.lightInk;
  static const Color lightForest = AppColors.lightForest;
  static const Color lightForestSecondary = AppColors.lightForestSecondary;
  static const Color lightPaper = AppColors.lightPaper;
  static const Color lightGold = AppColors.lightGold;
  static const Color lightGoldSecondary = AppColors.lightGoldSecondary;
  static const Color lightMuted = AppColors.lightMuted;
  static const Color lightLine = AppColors.lightLine;

  static const Color darkCream = AppColors.darkCream;
  static const Color darkInk = AppColors.darkInk;
  static const Color darkForest = AppColors.darkForest;
  static const Color darkForestSecondary = AppColors.darkForestSecondary;
  static const Color darkPaper = AppColors.darkPaper;
  static const Color darkGold = AppColors.darkGold;
  static const Color darkGoldSecondary = AppColors.darkGoldSecondary;
  static const Color darkMuted = AppColors.darkMuted;
  static const Color darkLine = AppColors.darkLine;

  // ── Typography ────────────────────────────────────────────────────────────

  /// Returns an Italiana serif header text style.
  static TextStyle serifHeader({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.italiana(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Returns a DM Sans body text style.
  static TextStyle sansBody({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────

  /// Returns the complete light theme configuration.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.lightGold,
      scaffoldBackgroundColor: AppColors.lightCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightGold,
        secondary: AppColors.lightGoldSecondary,
        surface: AppColors.lightPaper,
        onSurface: AppColors.lightInk,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: serifHeader(
          fontSize: 48,
          color: AppColors.lightInk,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
        titleLarge: serifHeader(fontSize: 24, color: AppColors.lightInk),
        bodyLarge: sansBody(fontSize: 16, color: AppColors.lightInk),
        bodyMedium: sansBody(fontSize: 14, color: AppColors.lightMuted),
        labelLarge: sansBody(
          fontSize: 12,
          color: AppColors.lightInk,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightForest,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      dividerColor: AppColors.lightLine,
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────

  /// Returns the complete dark theme configuration.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkGold,
      scaffoldBackgroundColor: AppColors.darkCream,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkGold,
        secondary: AppColors.darkGoldSecondary,
        surface: AppColors.darkPaper,
        onSurface: AppColors.darkInk,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: serifHeader(
          fontSize: 48,
          color: AppColors.darkInk,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
        titleLarge: serifHeader(fontSize: 24, color: AppColors.darkInk),
        bodyLarge: sansBody(fontSize: 16, color: AppColors.darkInk),
        bodyMedium: sansBody(fontSize: 14, color: AppColors.darkMuted),
        labelLarge: sansBody(
          fontSize: 12,
          color: AppColors.darkInk,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCream,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      dividerColor: AppColors.darkLine,
    );
  }
}
