import 'dart:math';
import 'package:flutter/material.dart';

class DashboardLineChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;
  final Color lineColor;
  final Color gradientColor;

  const DashboardLineChart({
    super.key,
    required this.dataPoints,
    required this.labels,
    required this.lineColor,
    required this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _LineChartPainter(
              dataPoints: dataPoints,
              lineColor: lineColor,
              gradientColor: gradientColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              labels
                  .map(
                    (label) => Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFA4A9A7),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color gradientColor;

  _LineChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.gradientColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paintLine =
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final paintFill = Paint()..style = PaintingStyle.fill;

    final maxVal = dataPoints.reduce(max);
    final minVal = dataPoints.reduce(min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final widthStep = size.width / (dataPoints.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * widthStep;
      final y =
          size.height -
          ((dataPoints[i] - minVal) / range) * (size.height - 20) -
          10;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Draw gradient fill below path
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        gradientColor.withValues(alpha: 0.35),
        gradientColor.withValues(alpha: 0.0),
      ],
    );

    paintFill.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawPath(fillPath, paintFill);

    // Draw main line path
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
