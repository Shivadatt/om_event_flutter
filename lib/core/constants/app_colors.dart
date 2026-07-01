import 'package:flutter/material.dart';

/// Centralized color palette constants extracted from AppTheme.
/// All widgets must reference these instead of inline Color literals.
class AppColors {
  AppColors._();

  // ── Light Theme ───────────────────────────────────────────────────────────
  static const Color lightCream = Color(0xFFF4F0E8);
  static const Color lightInk = Color(0xFF17201E);
  static const Color lightForest = Color(0xFF1E2B27);
  static const Color lightForestSecondary = Color(0xFF2F413B);
  static const Color lightPaper = Color(0xFFFBF9F4);
  static const Color lightGold = Color(0xFFAA7C4B);
  static const Color lightGoldSecondary = Color(0xFFD3AD7B);
  static const Color lightMuted = Color(0xFF6D746F);
  static const Color lightLine = Color(0x2317201E);

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static const Color darkCream = Color(0xFF141A18);
  static const Color darkInk = Color(0xFFF2EEE6);
  static const Color darkForest = Color(0xFFD8E3DC);
  static const Color darkForestSecondary = Color(0xFFB7C8BF);
  static const Color darkPaper = Color(0xFF1B2320);
  static const Color darkGold = Color(0xFFD1A875);
  static const Color darkGoldSecondary = Color(0xFFE3C89F);
  static const Color darkMuted = Color(0xFFAAB4AE);
  static const Color darkLine = Color(0x21FFFFFF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFB85952);
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
