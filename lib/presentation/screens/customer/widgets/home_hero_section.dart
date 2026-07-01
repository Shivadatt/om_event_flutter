import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/core/widgets/custom_button.dart';
import 'package:om_event/presentation/screens/customer/helpers/customer_dialog_helper.dart';

class _HeroBackgroundPainter extends CustomPainter {
  final bool isDark;
  const _HeroBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint =
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(size.width, size.height),
            isDark
                ? [
                  const Color(0xFF101C18),
                  const Color(0xFF273A34),
                  const Color(0xFF755F49),
                ]
                : [const Color(0xFFFAF8F5), const Color(0xFFEBE6DD)],
            [0.0, 0.52, 1.0],
          );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (isDark) {
      final orb1Paint =
          Paint()
            ..color = const Color(0xFFC3925D).withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
      canvas.drawCircle(Offset(size.width + 100, 240), 240, orb1Paint);

      final orb2Paint =
          Paint()
            ..color = const Color(0xFFD0AE84).withValues(alpha: 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
      canvas.drawCircle(
        Offset(size.width * 0.35, size.height + 30),
        150,
        orb2Paint,
      );
    }

    final dotPaint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04)
          ..style = PaintingStyle.fill;

    const double spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeroSection extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;

  const HeroSection({
    super.key,
    required this.scaffoldKey,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HeroBackgroundPainter(isDark: isDark)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 24,
              vertical: isDesktop ? 100 : 60,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child:
                    isDesktop
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _HeroContent(scaffoldKey: scaffoldKey),
                            ),
                            const SizedBox(width: 64),
                            const Expanded(flex: 9, child: HeroStageArch()),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroContent(scaffoldKey: scaffoldKey),
                            const SizedBox(height: 48),
                            const HeroStageArch(),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _HeroContent({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;
    final double titleSize =
        width >= 700 ? (width * 0.065).clamp(60.0, 108.0) : 48.0;

    return Obx(() {
      final homepage = AppConfigService.to.rxHomepageSettings.value;
      final stats = AppConfigService.to.rxStatisticsSettings.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            homepage.heroEyebrow.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 10,
              color: goldColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: GoogleFonts.italiana(
                fontSize: titleSize,
                color: isDark ? Colors.white : const Color(0xFF17201E),
                height: 0.92,
              ),
              children: [TextSpan(text: homepage.heroTitle)],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            homepage.heroSubtitle,
            style: AppTheme.sansBody(
              fontSize: 17,
              color: isDark ? Colors.white70 : const Color(0xFF2F413B),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomButton(
                text: "Design your event ↗",
                onPressed: () {
                  scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              CustomButton(
                text: "Plan with an expert",
                isPrimary: false,
                onPressed: () => CustomerDialogHelper.openLeadDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 38),
          Row(
            children: [
              _trustLabel("4.9 ★ Google Rating", isDark),
              _divider(isDark),
              _trustLabel("${stats.completedEvents}+ Celebrations", isDark),
              _divider(isDark),
              _trustLabel("${stats.years} Years of Wonder", isDark),
            ],
          ),
        ],
      );
    });
  }

  Widget _trustLabel(String text, bool isDark) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.sansBody(
        fontSize: 10,
        color: isDark ? Colors.white54 : const Color(0x9917201E),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        "•",
        style: TextStyle(
          color: isDark ? Colors.white30 : const Color(0x3D17201E),
        ),
      ),
    );
  }
}

class HeroStageArch extends StatelessWidget {
  const HeroStageArch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final homepage = AppConfigService.to.rxHomepageSettings.value;

      return Container(
        height: 500,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        child: ClipRRect(
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: StageArchPainter()),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "FEATURED STORY",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homepage.heroBadge,
                      style: GoogleFonts.italiana(
                        fontSize: 45,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "AHMEDABAD · 2026",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 45,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  width: 170,
                  decoration: const BoxDecoration(color: Color(0xEBF4F0E8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HANDCRAFTED",
                        style: AppTheme.sansBody(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8C623B),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Every detail, yours.",
                        style: GoogleFonts.italiana(
                          fontSize: 17,
                          color: const Color(0xFF1B2723),
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class StageArchPainter extends CustomPainter {
  const StageArchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint =
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(size.width, size.height),
            [
              Colors.white.withValues(alpha: 0.09),
              Colors.black.withValues(alpha: 0.14),
            ],
          );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final outlinePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final path1 = Path();
    final double radius = size.width / 2;
    path1.moveTo(0, size.height);
    path1.lineTo(0, radius);
    path1.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path1.lineTo(size.width, size.height);
    canvas.drawPath(path1, outlinePaint);

    final path2 = Path();
    const double inset = 16.0;
    final double innerRadius = (size.width - inset * 2) / 2;
    path2.moveTo(inset, size.height);
    path2.lineTo(inset, radius);
    path2.arcToPoint(
      Offset(size.width - inset, radius),
      radius: Radius.circular(innerRadius),
      clockwise: true,
    );
    path2.lineTo(size.width - inset, size.height);
    canvas.drawPath(path2, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
