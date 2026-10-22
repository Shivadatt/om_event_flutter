import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MarkerLevel {
  primaryStudio,
  majorCoverage,
  extendedCoverage,
  destinationEvents,
}

class MapCity {
  final String name;
  final double x;
  final double y;
  final MarkerLevel level;
  final bool labelOnRight;

  const MapCity({
    required this.name,
    required this.x,
    required this.y,
    required this.level,
    required this.labelOnRight,
  });
}

class GujaratMapMarker extends StatelessWidget {
  final MapCity city;
  final Color goldColor;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const GujaratMapMarker({
    super.key,
    required this.city,
    required this.goldColor,
    required this.isSmallScreen,
    required this.onTap,
  });

  Widget _buildMarker(MarkerLevel level, double size) {
    if (level == MarkerLevel.primaryStudio) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: goldColor,
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.7),
              blurRadius: 7,
              spreadRadius: 1.5,
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.star, size: size * 0.55, color: const Color(0xFF091210)),
        ),
      );
    }
    if (level == MarkerLevel.majorCoverage) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: goldColor.withValues(alpha: 0.30),
          border: Border.all(color: goldColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.65),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.38,
            height: size * 0.38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5C378),
            ),
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: goldColor.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildCityPill() {
    final isStudio = city.level == MarkerLevel.primaryStudio;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 5 : 7,
        vertical: isSmallScreen ? 1.5 : 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF07120E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isStudio ? goldColor : goldColor.withValues(alpha: 0.75),
          width: 1.0,
        ),
      ),
      child: Text(
        city.name,
        style: GoogleFonts.montserrat(
          fontSize: isSmallScreen ? 8.5 : 9.5,
          fontWeight: FontWeight.bold,
          color: isStudio ? const Color(0xFFE5C378) : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markerSize = city.level == MarkerLevel.primaryStudio
        ? (isSmallScreen ? 14.0 : 16.0)
        : (isSmallScreen ? 9.0 : 11.0);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMarker(city.level, markerSize),
          const SizedBox(width: 3),
          _buildCityPill(),
        ],
      ),
    );
  }
}
