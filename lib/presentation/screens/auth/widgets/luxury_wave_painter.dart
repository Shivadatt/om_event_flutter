import 'package:flutter/material.dart';

/// Custom painter for the Option 1 flowing gold guilloche wave ribbons.
class LuxuryWavePainter extends CustomPainter {
  final Color color;

  const LuxuryWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 18; i++) {
      final path = Path();
      final t = i / 18.0;
      final startY = size.height - (i * 2.8);
      path.moveTo(0, startY);
      path.cubicTo(
        size.width * (0.15 + t * 0.1),
        size.height - 15 - (i * 4.5),
        size.width * (0.45 + t * 0.1),
        size.height + 25 - (i * 3.0),
        size.width,
        size.height - 35 - (i * 4.5),
      );
      paint.color = color.withValues(alpha: 0.08 + (t * 0.22));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
