import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Luxury Gold Waves CustomPainter matching Reference Option 4 Premium Detailed Style:
/// Renders delicate, flowing champagne gold contour ribbons and ambient radial
/// lighting across the background of the Categories management screen.
class LuxuryGoldWavesPainter extends CustomPainter {
  const LuxuryGoldWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;
    const goldColor = Color(0xFFD4AF37);

    // ── 1. Ambient Radial Glow (Top-Right) ──────────────────────────────────
    final topGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(w * 0.78, h * 0.12),
        w * 0.38,
        [
          goldColor.withValues(alpha: 0.09),
          goldColor.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), topGlowPaint);

    // ── 2. Ambient Radial Glow (Bottom-Right) ───────────────────────────────
    final bottomGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(w * 0.65, h * 0.88),
        w * 0.42,
        [
          goldColor.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomGlowPaint);

    // ── 3. Flowing Top-Right Ribbon Lines (Concentric Beziers) ──────────────
    const int topRibbonCount = 18;
    for (int i = 0; i < topRibbonCount; i++) {
      final double progress = i / topRibbonCount;
      final double alpha = (0.05 + 0.18 * (1.0 - (progress - 0.5).abs() * 2))
          .clamp(0.04, 0.26);

      final linePaint = Paint()
        ..color = goldColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85 + (i % 3 == 0 ? 0.35 : 0.0);

      final path = Path();
      // Start in upper-middle area
      final startX = w * (0.32 + progress * 0.18);
      final startY = -10.0 + i * 2.5;

      // Control point 1: curves downward and right
      final cp1X = w * (0.58 + progress * 0.12);
      final cp1Y = h * (0.08 + progress * 0.08);

      // Control point 2: sweeps outward
      final cp2X = w * (0.82 + progress * 0.08);
      final cp2Y = h * (0.04 + progress * 0.16);

      // End point: off the right edge or down
      final endX = w * (1.05 + progress * 0.05);
      final endY = h * (0.24 + progress * 0.22);

      path.moveTo(startX, startY);
      path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, endX, endY);

      canvas.drawPath(path, linePaint);
    }

    // ── 4. Flowing Bottom Ribbon Lines (Ascending Beziers) ──────────────────
    const int bottomRibbonCount = 14;
    for (int i = 0; i < bottomRibbonCount; i++) {
      final double progress = i / bottomRibbonCount;
      final double alpha = (0.04 + 0.15 * (1.0 - (progress - 0.5).abs() * 2))
          .clamp(0.03, 0.22);

      final linePaint = Paint()
        ..color = goldColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      final path = Path();
      final startX = w * (0.18 + progress * 0.22);
      final startY = h + 15.0 - i * 3.0;

      final cp1X = w * (0.45 + progress * 0.15);
      final cp1Y = h * (0.92 - progress * 0.12);

      final cp2X = w * (0.74 + progress * 0.10);
      final cp2Y = h * (0.86 - progress * 0.18);

      final endX = w * (1.02 + progress * 0.04);
      final endY = h * (0.70 - progress * 0.15);

      path.moveTo(startX, startY);
      path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, endX, endY);

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LuxuryGoldWavesPainter oldDelegate) => false;
}
