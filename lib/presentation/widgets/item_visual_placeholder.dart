import 'package:flutter/material.dart';
import '../../core/extensions/string_extension.dart';
import 'svg_background_painter.dart';

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

  @override
  Widget build(BuildContext context) {
    final palette =
        palettes[categorySlug.toLowerCase()] ??
        ['#bd976c', '#8ba4a0', '#303b38'];
    final colorA = palette[0].toColor();
    final colorB = palette[1].toColor();
    final colorC = palette[2].toColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Custom Painter for Vector Background and Geometry
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: SvgBackgroundPainter(
                    a: colorA,
                    b: colorB,
                    c: colorC,
                  ),
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
                      color: const Color(0xFFFFFAF2).withValues(alpha: 0.72),
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
