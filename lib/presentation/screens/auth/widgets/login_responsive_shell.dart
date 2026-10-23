import 'package:flutter/material.dart';
import 'login_constants.dart';
import 'login_hero_panel.dart';

/// Ambient circular background glow with soft radial gradient.
class LoginAmbientGlow extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;
  final double opacity;
  final double size;

  const LoginAmbientGlow({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.color,
    required this.opacity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

/// Luxury card shell container with responsive constraints, border, and shadows.
class LoginCardShell extends StatelessWidget {
  final double maxWidth;
  final double? maxHeight;
  final Widget child;
  final double blurRadius;

  const LoginCardShell({
    super.key,
    required this.maxWidth,
    this.maxHeight,
    required this.child,
    this.blurRadius = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LoginConstants.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LoginConstants.goldColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: blurRadius,
              offset: const Offset(0, 10),
            ),
            if (blurRadius > 28)
              BoxShadow(
                color: LoginConstants.goldColor.withValues(alpha: 0.06),
                blurRadius: 30,
                spreadRadius: -2,
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Responsive Two-Column Shell for Desktop, Laptop, and Tablet.
class LoginTwoColumnShell extends StatelessWidget {
  final LoginDeviceTier tier;
  final double width;
  final double height;
  final Widget formWidget;

  const LoginTwoColumnShell({
    super.key,
    required this.tier,
    required this.width,
    required this.height,
    required this.formWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = tier == LoginDeviceTier.desktop;
    final isTablet = tier == LoginDeviceTier.tablet;

    final cardWidth = isDesktop
        ? (width * 0.56).clamp(980.0, 1060.0)
        : (isTablet ? (width - 48).clamp(660.0, 730.0) : (width * 0.68).clamp(880.0, 960.0));
    final cardHeight = isDesktop
        ? (height * 0.58).clamp(560.0, 610.0)
        : (isTablet ? (height * 0.58).clamp(540.0, 595.0) : (height * 0.72).clamp(500.0, 535.0));

    return LoginCardShell(
      maxWidth: cardWidth,
      maxHeight: cardHeight,
      child: Row(
        children: [
          Expanded(
            flex: isTablet ? 9 : 11,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: LoginHeroPanel(
                isMobile: false,
                isTablet: isTablet,
                isDesktop: isDesktop,
                horizontalPadding: isDesktop ? 32 : (isTablet ? 20 : 26),
                verticalPadding: isDesktop ? 26 : 20,
                quoteFontSize: isDesktop ? 26 : (isTablet ? 20.0 : 23),
                waveWidth: isTablet ? 200 : 260,
                waveHeight: isTablet ? 100 : 130,
              ),
            ),
          ),
          Expanded(
            flex: isTablet ? 11 : 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              child: Container(
                color: LoginConstants.cardBg,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36 : (isTablet ? 20 : 28),
                  vertical: isDesktop ? 24 : (isTablet ? 18 : 16),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: formWidget,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive Single-Column Stacked Shell for Mobile devices.
class LoginMobileShell extends StatelessWidget {
  final double width;
  final double height;
  final Widget formWidget;

  const LoginMobileShell({
    super.key,
    required this.width,
    required this.height,
    required this.formWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (width - 32).clamp(280.0, 390.0);
    final heroHeight = (height * 0.27).clamp(195.0, 230.0);

    return LoginCardShell(
      maxWidth: cardWidth,
      blurRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: LoginHeroPanel(
                isMobile: true,
                horizontalPadding: 16,
                verticalPadding: 12,
                quoteFontSize: 16,
                waveWidth: 140,
                waveHeight: 70,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: formWidget,
          ),
        ],
      ),
    );
  }
}
