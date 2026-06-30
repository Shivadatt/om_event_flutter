import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ItemVisualPlaceholder extends StatelessWidget {
  final String title;
  final String categorySlug;
  final String categoryName;

  const ItemVisualPlaceholder({
    super.key,
    required this.title,
    required this.categorySlug,
    required this.categoryName,
  });

  static const Map<String, List<String>> palettes = {
    'birthday': ['#f0b3be', '#8bc1c5', '#f9dd9a'],
    'wedding': ['#c39463', '#f1e3cf', '#7c493d'],
    'baby': ['#a7c8c5', '#eee1cf', '#d8a7ac'],
    'corporate': ['#7782ad', '#c5a96e', '#232d35'],
    'proposal': ['#b96362', '#e9b8a5', '#48343f'],
    'entries': ['#9b81af', '#d4ad63', '#303344'],
  };

  Color _parseHex(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final palette = palettes[categorySlug.toLowerCase()] ?? ['#bd976c', '#8ba4a0', '#303b38'];
    final colorA = _parseHex(palette[0]);
    final colorB = _parseHex(palette[1]);
    final colorC = _parseHex(palette[2]);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Custom Painter for Vector Background and Geometry
            Positioned.fill(
              child: CustomPaint(
                painter: SvgBackgroundPainter(
                  a: colorA,
                  b: colorB,
                  c: colorC,
                ),
              ),
            ),
            // Text Overlays styled precisely like original SVG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      height: 1.2,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFFFFAF2),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    categoryName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFFAF2).withOpacity(0.72),
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SvgBackgroundPainter extends CustomPainter {
  final Color a;
  final Color b;
  final Color c;

  SvgBackgroundPainter({
    required this.a,
    required this.b,
    required this.c,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 1200.0;
    final scaleY = size.height / 850.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Draw linear gradient background (0,0) to (1200,850)
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(1200, 850),
        [a, c],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1200, 850), bgPaint);

    // 2. Draw grain pattern (simulated via dots grid)
    final grainPaint = Paint()..color = Colors.white.withOpacity(0.08);
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
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(950, 170),
        330,
        [b.withOpacity(0.92), b.withOpacity(0.0)],
      );
    canvas.drawCircle(const Offset(950, 170), 330, glowPaint);

    // 4. Draw wave path at bottom: M0 650 Q230 510 450 645 T890 620 T1200 590 V850 H0Z fill #17221f opacity .58
    final wavePath = Path()
      ..moveTo(0, 650)
      ..quadraticBezierTo(230, 510, 450, 645)
      ..quadraticBezierTo(670, 780, 890, 620)
      ..quadraticBezierTo(1110, 460, 1200, 590)
      ..lineTo(1200, 850)
      ..lineTo(0, 850)
      ..close();

    final wavePaint = Paint()
      ..color = const Color(0xFF17221F).withOpacity(0.58)
      ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, wavePaint);

    // 5. Draw arch shadow / fill: M435 650 V365 Q600 240 765 365 V650 fill #f8f0e6 opacity .18
    final innerArchPath = Path()
      ..moveTo(435, 650)
      ..lineTo(435, 365)
      ..quadraticBezierTo(600, 240, 765, 365)
      ..lineTo(765, 650)
      ..close();
    final innerArchPaint = Paint()
      ..color = const Color(0xFFF8F0E6).withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerArchPath, innerArchPaint);

    // 6. Draw arch line: M360 650 V330 Q600 145 840 330 V650 stroke 'b' stroke-width 22 opacity .85
    final archPath = Path()
      ..moveTo(360, 650)
      ..lineTo(360, 330)
      ..quadraticBezierTo(600, 145, 840, 330)
      ..lineTo(840, 650);
    final archPaint = Paint()
      ..color = b.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    canvas.drawPath(archPath, archPaint);

    // 7. Draw balloons of color 'b' (opacity 0.9)
    final balloonBPaint = Paint()
      ..color = b.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(350, 345), 56, balloonBPaint);
    canvas.drawCircle(const Offset(414, 285), 42, balloonBPaint);
    canvas.drawCircle(const Offset(480, 246), 52, balloonBPaint);
    canvas.drawCircle(const Offset(720, 246), 52, balloonBPaint);
    canvas.drawCircle(const Offset(786, 285), 42, balloonBPaint);
    canvas.drawCircle(const Offset(850, 345), 56, balloonBPaint);

    // 8. Draw balloons of color 'a' (opacity 0.8)
    final balloonAPaint = Paint()
      ..color = a.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(323, 410), 38, balloonAPaint);
    canvas.drawCircle(const Offset(877, 410), 38, balloonAPaint);
    canvas.drawCircle(const Offset(540, 220), 35, balloonAPaint);
    canvas.drawCircle(const Offset(660, 220), 35, balloonAPaint);

    // 9. Draw poles: stroke 'b' stroke-width 4 opacity .8
    final polePaint = Paint()
      ..color = b.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(const Offset(174, 560), const Offset(174, 300), polePaint);
    canvas.drawLine(const Offset(1026, 560), const Offset(1026, 300), polePaint);

    // 10. Draw circles on top of poles
    final poleTopPaint = Paint()
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
