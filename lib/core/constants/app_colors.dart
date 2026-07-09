import 'package:flutter/material.dart';

/// Centralized color palette constants extracted from AppTheme.
/// Customized for the OM Events & Decorators Gold Edition Brand Identity.
/// Rich, warm, editorial, and minimal luxury studio theme.
class AppColors {
  AppColors._();

  // ── Light Theme (Warm Ivory & Champagne Gold) ──────────────────────────────────────
  static const Color lightCream = Color(0xFFF7F2EA); // Warm Ivory
  static const Color lightInk = Color(0xFF0F0D0B);   // Matte Black
  static const Color lightForest = Color(0xFFFAF6EE); // Pearl White
  static const Color lightForestSecondary = Color(0xFFFAF6EE);
  static const Color lightPaper = Color(0xFFFFFFFF);  // Pure Pearl
  static const Color lightGold = Color(0xFFD4AF37);   // Metallic Luxury Gold
  static const Color lightGoldSecondary = Color(0xFFE6C98D); // Champagne Gold
  static const Color lightMuted = Color(0xFFB6ADA4);  // Muted Gray
  static const Color lightLine = Color(0x26D4AF37);   // Soft Gold Transparency Border

  // ── Dark Theme (OM Events Gold Edition Luxury Dark Theme) ──────────────────────────
  static const Color darkCream = Color(0xFF0F0D0B);  // Primary Background (Warm Black)
  static const Color darkInk = Color(0xFFF7F2EA);    // Text Primary (Warm Ivory)
  static const Color darkForest = Color(0xFF171411);  // Secondary Background (Graphite)
  static const Color darkForestSecondary = Color(0xFF211C18); // Card Background (Ebony)
  static const Color darkPaper = Color(0xFF2A241F);   // Luxury Surface / Floating
  static const Color darkGold = Color(0xFFD4AF37);    // Primary Metallic Gold Accent
  static const Color darkGoldSecondary = Color(0xFFE6C98D); // Champagne Gold Accent
  static const Color darkMuted = Color(0xFFB6ADA4);   // Text Secondary (Muted Gray)
  static const Color darkLine = Color(0x26D4AF37);    // Border (rgba 212, 175, 55, 0.15)

  // ── Semantic & Accents ─────────────────────────────────────────────
  static const Color primaryAccent = Color(0xFFD4AF37);    // Luxury Gold
  static const Color secondaryAccent = Color(0xFFE6C98D);  // Champagne Gold
  static const Color highlight = Color(0xFF9C7B45);        // Soft Bronze
  static const Color success = Color(0xFF7CA68E);          // Muted Sage Green
  static const Color warning = Color(0xFFE6C98D);          // Champagne Gold
  static const Color error = Color(0xFFC95C5C);            // Copper Muted Red
  static const Color danger = Color(0xFFC95C5C);
  static const Color muted = Color(0xFFB6ADA4);            // Muted Gray
  static const Color hover = Color(0xFF2A241F);

  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
