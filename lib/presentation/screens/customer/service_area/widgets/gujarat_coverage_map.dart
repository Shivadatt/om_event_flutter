import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';
import 'gujarat_map_marker.dart';
import 'gujarat_map_painter.dart';

class GujaratCoverageMap extends StatelessWidget {
  final Color goldColor;
  final ValueChanged<String> onCitySelected;

  const GujaratCoverageMap({
    super.key,
    required this.goldColor,
    required this.onCitySelected,
  });

  static const List<MapCity> cities = [
    MapCity(name: "Patan", x: 0.49, y: 0.18, level: MarkerLevel.extendedCoverage, labelOnRight: false),
    MapCity(name: "Mehsana", x: 0.58, y: 0.16, level: MarkerLevel.majorCoverage, labelOnRight: false),
    MapCity(name: "Kadi", x: 0.59, y: 0.23, level: MarkerLevel.primaryStudio, labelOnRight: false),
    MapCity(name: "Gandhinagar", x: 0.67, y: 0.21, level: MarkerLevel.majorCoverage, labelOnRight: true),
    MapCity(name: "Ahmedabad", x: 0.66, y: 0.27, level: MarkerLevel.majorCoverage, labelOnRight: true),
    MapCity(name: "Viramgam", x: 0.53, y: 0.26, level: MarkerLevel.extendedCoverage, labelOnRight: false),
    MapCity(name: "Surendranagar", x: 0.50, y: 0.34, level: MarkerLevel.majorCoverage, labelOnRight: false),
    MapCity(name: "Thangadh", x: 0.45, y: 0.41, level: MarkerLevel.primaryStudio, labelOnRight: false),
    MapCity(name: "Rajkot", x: 0.38, y: 0.53, level: MarkerLevel.majorCoverage, labelOnRight: false),
    MapCity(name: "Vadodara", x: 0.70, y: 0.40, level: MarkerLevel.extendedCoverage, labelOnRight: true),
    MapCity(name: "Surat", x: 0.68, y: 0.55, level: MarkerLevel.destinationEvents, labelOnRight: true),
  ];


  Widget _buildLegend(bool isSmallScreen) {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xE6060F0C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: goldColor.withValues(alpha: 0.2)),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _legendItem(const Icon(Icons.star, size: 10, color: Color(0xFFD4AF37)), "Studio Locations", isSmallScreen),
            _legendItem(Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD4AF37))), "Primary Coverage", isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Widget icon, String label, bool isSmall) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.sansBody(fontSize: isSmall ? 8.2 : 9, color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF091511),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldColor.withValues(alpha: 0.20)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 20 || constraints.maxHeight < 20) {
              return const SizedBox.shrink();
            }
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final isSmallScreen = w < 500;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: GujaratMapPainter(goldColor: goldColor)),
                ),
                ...cities.map((city) {
                  final markerSize = city.level == MarkerLevel.primaryStudio
                      ? (isSmallScreen ? 14.0 : 16.0)
                      : (isSmallScreen ? 9.0 : 11.0);
                  final pinX = w * city.x;
                  final pinY = h * city.y;

                  return Positioned(
                    left: pinX - (markerSize / 2),
                    top: pinY - (markerSize / 2),
                    child: GujaratMapMarker(
                      city: city,
                      goldColor: goldColor,
                      isSmallScreen: isSmallScreen,
                      onTap: () => onCitySelected(city.name),
                    ),
                  );
                }),
                _buildLegend(isSmallScreen),
              ],
            );
          },
        ),
      ),
    );
  }
}
