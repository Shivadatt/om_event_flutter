import 'dart:math' as math;
import 'package:flutter/material.dart';

class GujaratMapPainter extends CustomPainter {
  final Color goldColor;

  GujaratMapPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 20 || size.height < 20) return;
    final w = size.width;
    final h = size.height;

    // 1. Ambient Background Radial Glow
    final radialPaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.2, -0.1),
            radius: 0.9,
            colors: [
              goldColor.withValues(alpha: 0.12),
              const Color(0xFF102820).withValues(alpha: 0.35),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), radialPaint);

    // 2. Halos around Studios and Major Hubs
    final kadiCenter = Offset(w * 0.59, h * 0.23);
    final kadiGlow =
        Paint()
          ..shader = RadialGradient(
            colors: [goldColor.withValues(alpha: 0.24), Colors.transparent],
          ).createShader(Rect.fromCircle(center: kadiCenter, radius: 55));
    canvas.drawCircle(kadiCenter, 55, kadiGlow);

    final thangadhCenter = Offset(w * 0.45, h * 0.41);
    final thangadhGlow =
        Paint()
          ..shader = RadialGradient(
            colors: [goldColor.withValues(alpha: 0.24), Colors.transparent],
          ).createShader(Rect.fromCircle(center: thangadhCenter, radius: 55));
    canvas.drawCircle(thangadhCenter, 55, thangadhGlow);

    // 3. Golden Highway Rays Linking Hubs
    final highwayGlow =
        Paint()
          ..color = goldColor.withValues(alpha: 0.14)
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke;

    final highwayCore =
        Paint()
          ..color = goldColor.withValues(alpha: 0.50)
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke;

    final connections = [
      (
        Offset(w * 0.49, h * 0.18),
        Offset(w * 0.58, h * 0.16),
      ), // Patan - Mehsana
      (
        Offset(w * 0.58, h * 0.16),
        Offset(w * 0.59, h * 0.23),
      ), // Mehsana - Kadi
      (
        Offset(w * 0.59, h * 0.23),
        Offset(w * 0.67, h * 0.21),
      ), // Kadi - Gandhinagar
      (
        Offset(w * 0.59, h * 0.23),
        Offset(w * 0.66, h * 0.27),
      ), // Kadi - Ahmedabad
      (
        Offset(w * 0.67, h * 0.21),
        Offset(w * 0.66, h * 0.27),
      ), // Gandhinagar - Ahmedabad
      (
        Offset(w * 0.59, h * 0.23),
        Offset(w * 0.53, h * 0.26),
      ), // Kadi - Viramgam
      (
        Offset(w * 0.53, h * 0.26),
        Offset(w * 0.50, h * 0.34),
      ), // Viramgam - Surendranagar
      (
        Offset(w * 0.50, h * 0.34),
        Offset(w * 0.45, h * 0.41),
      ), // Surendranagar - Thangadh
      (
        Offset(w * 0.45, h * 0.41),
        Offset(w * 0.38, h * 0.53),
      ), // Thangadh - Rajkot
      (
        Offset(w * 0.66, h * 0.27),
        Offset(w * 0.70, h * 0.40),
      ), // Ahmedabad - Vadodara
      (
        Offset(w * 0.70, h * 0.40),
        Offset(w * 0.68, h * 0.55),
      ), // Vadodara - Surat
    ];

    for (final conn in connections) {
      canvas.drawLine(conn.$1, conn.$2, highwayGlow);
      canvas.drawLine(conn.$1, conn.$2, highwayCore);
    }

    // Fine Ambient Network Lines from Kadi Studio
    final webPaint =
        Paint()
          ..color = goldColor.withValues(alpha: 0.08)
          ..strokeWidth = 0.6
          ..style = PaintingStyle.stroke;

    final hub = Offset(w * 0.59, h * 0.23);
    for (int i = 0; i < 6; i++) {
      final rad = (i * 60) * math.pi / 180.0;
      final end = Offset(
        hub.dx + 240 * math.cos(rad),
        hub.dy + 240 * math.sin(rad),
      );
      canvas.drawLine(hub, end, webPaint);
    }

    // 4. Stylized Gujarat Geographic Silhouette Path
    final path = Path();
    path.moveTo(w * 0.38, h * 0.22);
    path.quadraticBezierTo(w * 0.46, h * 0.16, w * 0.54, h * 0.14);
    path.quadraticBezierTo(w * 0.62, h * 0.12, w * 0.68, h * 0.14);
    path.quadraticBezierTo(w * 0.74, h * 0.18, w * 0.78, h * 0.26);
    path.quadraticBezierTo(w * 0.80, h * 0.34, w * 0.78, h * 0.44);
    path.quadraticBezierTo(w * 0.76, h * 0.52, w * 0.73, h * 0.60);
    path.quadraticBezierTo(w * 0.71, h * 0.68, w * 0.69, h * 0.76);
    path.quadraticBezierTo(w * 0.67, h * 0.78, w * 0.65, h * 0.76);
    path.quadraticBezierTo(w * 0.63, h * 0.68, w * 0.61, h * 0.58);
    path.quadraticBezierTo(w * 0.59, h * 0.48, w * 0.56, h * 0.47);
    path.quadraticBezierTo(w * 0.54, h * 0.52, w * 0.52, h * 0.60);
    path.quadraticBezierTo(w * 0.47, h * 0.68, w * 0.38, h * 0.68);
    path.quadraticBezierTo(w * 0.30, h * 0.64, w * 0.26, h * 0.54);
    path.quadraticBezierTo(w * 0.24, h * 0.45, w * 0.28, h * 0.38);
    path.quadraticBezierTo(w * 0.34, h * 0.36, w * 0.42, h * 0.35);
    path.quadraticBezierTo(w * 0.46, h * 0.33, w * 0.46, h * 0.30);
    path.quadraticBezierTo(w * 0.40, h * 0.29, w * 0.34, h * 0.27);
    path.quadraticBezierTo(w * 0.30, h * 0.25, w * 0.38, h * 0.22);
    path.close();

    // 5. Interior Fill of Gujarat Path
    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F261F).withValues(alpha: 0.38),
              const Color(0xFF091410).withValues(alpha: 0.20),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h))
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 6. Layered Pure-Vector Gold Glow Strokes
    final glowPaint1 =
        Paint()
          ..color = goldColor.withValues(alpha: 0.10)
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint1);

    final glowPaint2 =
        Paint()
          ..color = goldColor.withValues(alpha: 0.22)
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint2);

    // 7. Crisp Champagne Gold Inner Stroke
    final strokePaint =
        Paint()
          ..color = const Color(0xFFE2C074)
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
