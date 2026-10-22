import 'package:flutter/material.dart';

class AtmosphericGoldenSwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const goldColor = Color(0xFFD4AF37);

    // Soft Ambient Top-Right Radial Glow
    final glowPaintRight =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.75, -0.7),
            radius: 0.9,
            colors: [
              goldColor.withValues(alpha: 0.08),
              goldColor.withValues(alpha: 0.02),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaintRight,
    );

    // Soft Ambient Bottom-Left Radial Glow
    final glowPaintLeft =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.85, 0.3),
            radius: 0.8,
            colors: [goldColor.withValues(alpha: 0.05), Colors.transparent],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaintLeft,
    );

    // Delicate Golden Fluid Ribbon Path 1
    final strokePaint1 =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.transparent,
              goldColor.withValues(alpha: 0.22),
              goldColor.withValues(alpha: 0.35),
              goldColor.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.22, 0.52, 0.82, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path();
    path1.moveTo(-60, size.height * 0.28);
    path1.cubicTo(
      size.width * 0.28,
      size.height * 0.75,
      size.width * 0.68,
      size.height * -0.15,
      size.width + 60,
      size.height * 0.42,
    );
    canvas.drawPath(path1, strokePaint1);

    // Delicate Golden Fluid Ribbon Path 2
    final strokePaint2 =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              goldColor.withValues(alpha: 0.12),
              goldColor.withValues(alpha: 0.25),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.75, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(-40, size.height * 0.58);
    path2.cubicTo(
      size.width * 0.32,
      size.height * 0.88,
      size.width * 0.78,
      size.height * 0.12,
      size.width + 50,
      size.height * 0.62,
    );
    canvas.drawPath(path2, strokePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
