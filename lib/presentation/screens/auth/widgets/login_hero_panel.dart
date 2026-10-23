import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import 'login_brand_header.dart';
import 'login_constants.dart';
import 'luxury_wave_painter.dart';

/// Left-side (desktop/tablet) or top (mobile) hero visual panel.
class LoginHeroPanel extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final double horizontalPadding;
  final double verticalPadding;
  final double quoteFontSize;
  final double waveWidth;
  final double waveHeight;
  final bool isDesktop;

  const LoginHeroPanel({
    super.key,
    required this.isMobile,
    this.isTablet = false,
    this.isDesktop = false,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.quoteFontSize,
    required this.waveWidth,
    required this.waveHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildHeroImage(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isMobile
                  ? [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.85),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.52),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.82),
                    ],
              stops: isMobile ? null : const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: waveWidth,
          height: waveHeight,
          child: IgnorePointer(
            child: CustomPaint(
              painter: LuxuryWavePainter(color: LoginConstants.goldColor),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoginBrandHeader(
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
                isCompact: isMobile || isTablet,
              ),
              const Spacer(),
              Text(
                "Beautiful work\nbegins with a\nclear view.",
                style: GoogleFonts.italiana(
                  fontSize: quoteFontSize,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: 0.5,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(height: 8),
                Text(
                  "Om Events · Celebration Studio Management",
                  style: GoogleFonts.dmSans(
                    fontSize: isTablet ? 8.5 : 9.5,
                    color: Colors.white60,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    Widget buildNetworkCandidate(String url, Widget? nextFallback) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) =>
            nextFallback ??
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF141F18),
                    Color(0xFF09120E),
                  ],
                ),
              ),
            ),
      );
    }

    final fallbackWebChain = buildNetworkCandidate(
      'images/luxury-evening-decor.jpg',
      buildNetworkCandidate(
        'assets/images/luxury-evening-decor.jpg',
        buildNetworkCandidate(
          'assets/assets/images/luxury-evening-decor.jpg',
          null,
        ),
      ),
    );

    return Image.asset(
      AppAssets.imageLuxuryEveningDecor,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => fallbackWebChain,
    );
  }
}
