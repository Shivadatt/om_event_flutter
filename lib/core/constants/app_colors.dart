import 'package:flutter/material.dart';

/// Centralized color palette constants extracted from AppTheme.
/// Customized for the OM Events & Decorators Luxury Emerald & Champagne Gold Theme.
class AppColors {
  AppColors._();

  // ── Light Theme (Luxury Emerald & Champagne Gold) ───────────────────────────────────
  static const Color lightCream = Color(0xFF0F1B18);   // Primary Background
  static const Color lightInk = Color(0xFFFAF8F3);     // Primary Text
  static const Color lightForest = Color(0xFF152621);  // Secondary Background
  static const Color lightForestSecondary = Color(0xFF183129); // Section Background
  static const Color lightPaper = Color(0xFF1B2D27);   // Card Background
  static const Color lightGold = Color(0xFFD4AF37);    // Primary Gold
  static const Color lightGoldSecondary = Color(0xFFF3D37A); // Champagne Gold
  static const Color lightMuted = Color(0xFFD8D6CF);   // Secondary Text
  static const Color lightLine = Color(0x2ED4AF37);    // Border (rgba 212,175,55,0.18)

  // ── Dark Theme (Luxury Emerald & Champagne Gold) ──────────────────────────────────────
  static const Color darkCream = Color(0xFF0F1B18);    // Primary Background
  static const Color darkInk = Color(0xFFFAF8F3);      // Primary Text
  static const Color darkForest = Color(0xFF152621);   // Secondary Background
  static const Color darkForestSecondary = Color(0xFF183129); // Section Background
  static const Color darkPaper = Color(0xFF1B2D27);    // Card Background
  static const Color darkGold = Color(0xFFD4AF37);     // Primary Gold
  static const Color darkGoldSecondary = Color(0xFFF3D37A); // Champagne Gold
  static const Color darkMuted = Color(0xFFD8D6CF);    // Secondary Text
  static const Color darkLine = Color(0x2ED4AF37);     // Border (rgba 212,175,55,0.18)

  // ── Semantic & Accents ─────────────────────────────────────────────
  static const Color primaryAccent = Color(0xFFD4AF37);    // Primary Gold
  static const Color secondaryAccent = Color(0xFFF3D37A);  // Champagne Gold
  static const Color highlight = Color(0xFFFFE8A3);        // Soft Gold
  static const Color success = Color(0xFF7CA68E);          // sage green (semantic)
  static const Color warning = Color(0xFFF3D37A);
  static const Color error = Color(0xFFC95C5C);
  static const Color danger = Color(0xFFC95C5C);
  static const Color muted = Color(0xFFD8D6CF);
  static const Color hover = Color(0xFF213830);            // Elevated Card

  // ── Premium Ambient Mesh Lighting Accents ──────────────────────────
  static const Color royalPurple = Color(0xFF2C103D);
  static const Color deepEmerald = Color(0xFF183129);
  static const Color midnightBlue = Color(0xFF0C192E);
  static const Color luxuryBronze = Color(0xFF573E18);
  static const Color warmAmber = Color(0xFF6E4A15);
  
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
