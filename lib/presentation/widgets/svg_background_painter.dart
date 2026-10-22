import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SvgBackgroundPainter extends CustomPainter {
  final Color a;
  final Color b;
  final Color c;

  SvgBackgroundPainter({required this.a, required this.b, required this.c});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 1200.0;
    final scaleY = size.height / 850.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Draw linear gradient background (0,0) to (1200,850)
    final bgPaint =
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, const Offset(1200, 850), [
            a,
            c,
          ]);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1200, 850), bgPaint);

    // 2. Draw grain pattern (simulated via dots grid)
    final grainPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (double x = 10; x < 1200; x += 80) {
      for (double y = 12; y < 850; y += 80) {
        canvas.drawCircle(Offset(x, y), 1.2, grainPaint);
      }
    }
    for (double x = 62; x < 1200; x += 80) {
      for (double y = 48; y < 850; y += 80) {
        canvas.drawCircle(Offset(x, y), 1.5, grainPaint);
      }
    }

    // 3. Draw radial gradient glow at (950, 170)
    final glowPaint =
        Paint()
          ..shader = ui.Gradient.radial(const Offset(950, 170), 330, [
            b.withValues(alpha: 0.92),
            b.withValues(alpha: 0.0),
          ]);
    canvas.drawCircle(const Offset(950, 170), 330, glowPaint);

    // 4. Draw wave path at bottom
    final wavePath =
        Path()
          ..moveTo(0, 650)
          ..quadraticBezierTo(230, 510, 450, 645)
          ..quadraticBezierTo(670, 780, 890, 620)
          ..quadraticBezierTo(1110, 460, 1200, 590)
          ..lineTo(1200, 850)
          ..lineTo(0, 850)
          ..close();

    final wavePaint =
        Paint()
          ..color = const Color(0xFF17221F).withValues(alpha: 0.58)
          ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, wavePaint);

    // 5. Draw arch shadow / fill
    final innerArchPath =
        Path()
          ..moveTo(435, 650)
          ..lineTo(435, 365)
          ..quadraticBezierTo(600, 240, 765, 365)
          ..lineTo(765, 650)
          ..close();
    final innerArchPaint =
        Paint()
          ..color = const Color(0xFFF8F0E6).withValues(alpha: 0.18)
          ..style = PaintingStyle.fill;
    canvas.drawPath(innerArchPath, innerArchPaint);

    // 6. Draw arch line
    final archPath =
        Path()
          ..moveTo(360, 650)
          ..lineTo(360, 330)
          ..quadraticBezierTo(600, 145, 840, 330)
          ..lineTo(840, 650);
    final archPaint =
        Paint()
          ..color = b.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22;
    canvas.drawPath(archPath, archPaint);

    // 7. Draw balloons of color 'b' (opacity 0.9)
    final balloonBPaint =
        Paint()
          ..color = b.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(350, 345), 56, balloonBPaint);
    canvas.drawCircle(const Offset(414, 285), 42, balloonBPaint);
    canvas.drawCircle(const Offset(480, 246), 52, balloonBPaint);
    canvas.drawCircle(const Offset(720, 246), 52, balloonBPaint);
    canvas.drawCircle(const Offset(786, 285), 42, balloonBPaint);
    canvas.drawCircle(const Offset(850, 345), 56, balloonBPaint);

    // 8. Draw balloons of color 'a' (opacity 0.8)
    final balloonAPaint =
        Paint()
          ..color = a.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(323, 410), 38, balloonAPaint);
    canvas.drawCircle(const Offset(877, 410), 38, balloonAPaint);
    canvas.drawCircle(const Offset(540, 220), 35, balloonAPaint);
    canvas.drawCircle(const Offset(660, 220), 35, balloonAPaint);

    // 9. Draw poles
    final polePaint =
        Paint()
          ..color = b.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawLine(const Offset(174, 560), const Offset(174, 300), polePaint);
    canvas.drawLine(
      const Offset(1026, 560),
      const Offset(1026, 300),
      polePaint,
    );

    // 10. Draw circles on top of poles
    final poleTopPaint =
        Paint()
          ..color = b
          ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(174, 290), 18, poleTopPaint);
    canvas.drawCircle(const Offset(1026, 290), 18, poleTopPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SvgBackgroundPainter oldDelegate) {
    return oldDelegate.a != a || oldDelegate.b != b || oldDelegate.c != c;
  }
}
