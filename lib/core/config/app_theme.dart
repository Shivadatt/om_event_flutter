import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palettes
  static const Color lightCream = Color(0xFFF4F0E8);
  static const Color lightInk = Color(0xFF17201E);
  static const Color lightForest = Color(0xFF1E2B27);
  static const Color lightForestSecondary = Color(0xFF2F413B);
  static const Color lightPaper = Color(0xFFFBF9F4);
  static const Color lightGold = Color(0xFFAA7C4B);
  static const Color lightGoldSecondary = Color(0xFFD3AD7B);
  static const Color lightMuted = Color(0xFF6D746F);
  static const Color lightLine = Color(0x2317201E);

  static const Color darkCream = Color(0xFF141A18);
  static const Color darkInk = Color(0xFFF2EEE6);
  static const Color darkForest = Color(0xFFD8E3DC);
  static const Color darkForestSecondary = Color(0xFFB7C8BF);
  static const Color darkPaper = Color(0xFF1B2320);
  static const Color darkGold = Color(0xFFD1A875);
  static const Color darkGoldSecondary = Color(0xFFE3C89F);
  static const Color darkMuted = Color(0xFFAAB4AE);
  static const Color darkLine = Color(0x21FFFFFF);

  // Typography Styles
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

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightGold,
      scaffoldBackgroundColor: lightCream,
      colorScheme: const ColorScheme.light(
        primary: lightGold,
        secondary: lightGoldSecondary,
        surface: lightPaper,
        onSurface: lightInk,
        error: Color(0xFFB85952),
      ),
      textTheme: TextTheme(
        displayLarge: serifHeader(fontSize: 48, color: lightInk, fontWeight: FontWeight.w400, height: 1.0),
        titleLarge: serifHeader(fontSize: 24, color: lightInk),
        bodyLarge: sansBody(fontSize: 16, color: lightInk),
        bodyMedium: sansBody(fontSize: 14, color: lightMuted),
        labelLarge: sansBody(fontSize: 12, color: lightInk, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightForest,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dividerColor: lightLine,
    );
  }

  // Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkGold,
      scaffoldBackgroundColor: darkCream,
      colorScheme: const ColorScheme.dark(
        primary: darkGold,
        secondary: darkGoldSecondary,
        surface: darkPaper,
        onSurface: darkInk,
        error: Color(0xFFB85952),
      ),
      textTheme: TextTheme(
        displayLarge: serifHeader(fontSize: 48, color: darkInk, fontWeight: FontWeight.w400, height: 1.0),
        titleLarge: serifHeader(fontSize: 24, color: darkInk),
        bodyLarge: sansBody(fontSize: 16, color: darkInk),
        bodyMedium: sansBody(fontSize: 14, color: darkMuted),
        labelLarge: sansBody(fontSize: 12, color: darkInk, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCream,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dividerColor: darkLine,
    );
  }
}
