import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/presentation/screens/customer/helpers/customer_dialog_helper.dart';
import 'package:om_event/presentation/widgets/app_page_container.dart';
import 'home_hero_helpers.dart';

class HeroSection extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;

  const HeroSection({
    super.key,
    required this.scaffoldKey,
    required this.isDesktop,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTwoColumn = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final isMobile = width < 600;
    final isIntermediate = width >= 1024 && width < 1140;
    final isNarrowMobile = width <= 370;
    final isUltraNarrow = width < 340;

    final double pH = isMobile
        ? (isUltraNarrow ? 10.0 : (isNarrowMobile ? 12.0 : 16.0))
        : (isTablet
            ? 28.0
            : (isIntermediate ? 24.0 : (width < 1280 ? 36.0 : 48.0)));
    final double topPad = isTwoColumn
        ? (width >= 1440 ? 44.0 : (isIntermediate ? 30.0 : 36.0))
        : (isTablet ? 32.0 : (isNarrowMobile ? 20.0 : 24.0));
    final double bottomPad = isTwoColumn
        ? (width >= 1440 ? 32.0 : (isIntermediate ? 20.0 : 24.0))
        : (isTablet ? 24.0 : (isNarrowMobile ? 16.0 : 18.0));

    final double titleSize = isTwoColumn
        ? (width >= 1440
            ? (width * 0.038).clamp(46.0, 58.0)
            : (isIntermediate
                ? (width * 0.032).clamp(32.0, 38.0)
                : (width * 0.034).clamp(38.0, 48.0)))
        : (isTablet
            ? (width * 0.048).clamp(32.0, 40.0)
            : (isNarrowMobile
                ? (width * 0.070).clamp(21.0, 25.0)
                : (width * 0.076).clamp(26.0, 32.0)));

    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1915),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: GoldGlowPainter())),
          const Positioned.fill(child: CustomPaint(painter: GrainPainter())),
          Padding(
            padding: EdgeInsets.fromLTRB(pH, topPad, pH, bottomPad),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
                child: Obx(() {
                  final homepage = AppConfigService.to.rxHomepageSettings.value;
                  final stats = AppConfigService.to.rxStatisticsSettings.value;

                  final String headingText = (homepage.heroTitle.isEmpty ||
                          homepage.heroTitle == "Celebrations,\nthoughtfully composed.")
                      ? "TURN MOMENTS\nINTO BEAUTIFUL\nMEMORIES."
                      : homepage.heroTitle.toUpperCase();

                  final String subText = (homepage.heroSubtitle.isEmpty ||
                          homepage.heroSubtitle.startsWith("From the first sketch"))
                      ? "Creative decorations for every occasion, designed with love, detail and perfection."
                      : homepage.heroSubtitle;

                  if (isTwoColumn) {
                    // Desktop & Laptop Split Layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEyebrow(width),
                              const SizedBox(height: 14),
                              _buildHeading(headingText, titleSize, isWide: true),
                              const SizedBox(height: 14),
                              _buildSubtitle(subText, isWide: true, width: width),
                              const SizedBox(height: 24),
                              _buildCtaButtons(isTwoColumn: true, isMobile: false, isIntermediate: isIntermediate),
                              const SizedBox(height: 28),
                              _buildTrustStats(stats, isTwoColumn: true, isMobile: false, isIntermediate: isIntermediate),
                            ],
                          ),
                        ),
                        SizedBox(width: isIntermediate ? 22 : (width < 1280 ? 32 : 48)),
                        Expanded(
                          flex: 5,
                          child: _buildVideoShowcase(
                            isTwoColumn: true,
                            isMobile: false,
                            width: width,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Tablet & Mobile Centered Layout
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildEyebrow(width),
                        const SizedBox(height: 14),
                        _buildHeading(headingText, titleSize, isWide: false),
                        const SizedBox(height: 14),
                        _buildSubtitle(subText, isWide: false, width: width),
                        const SizedBox(height: 22),
                        _buildCtaButtons(isTwoColumn: false, isMobile: isMobile),
                        const SizedBox(height: 24),
                        _buildTrustStats(stats, isTwoColumn: false, isMobile: isMobile),
                        const SizedBox(height: 28),
                        _buildVideoShowcase(
                          isTwoColumn: false,
                          isMobile: isMobile,
                          width: width,
                        ),
                      ],
                    );
                  }
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyebrow(double width) {
    final isNarrow = width <= 370;
    final isUltraNarrow = width < 340;
    final double dotSize = isNarrow ? 6.0 : 8.0;
    final double dotGap = isNarrow ? 6.0 : 8.0;
    final double fontSize = isUltraNarrow ? 8.2 : (isNarrow ? 9.0 : 10.5);
    final double letterSpacing = isUltraNarrow ? 1.0 : (isNarrow ? 1.8 : 3.5);

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryAccent,
            ),
          ),
          SizedBox(width: dotGap),
          Flexible(
            child: Text(
              "BESPOKE EVENT DESIGN • AHMEDABAD",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sansBody(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: letterSpacing,
                color: AppColors.secondaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String text, double titleSize, {required bool isWide}) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final double slide = (1.0 - _slideController.value) * 36;
        return Opacity(
          opacity: _slideController.value,
          child: Transform.translate(offset: Offset(0, slide), child: child),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFAF8F3), Color(0xFFFFE8A3), Color(0xFFF3D37A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          text,
          style: GoogleFonts.italiana(
            fontSize: titleSize,
            color: Colors.white,
            height: 1.05,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.2,
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String heroSubtitle, {required bool isWide, required double width}) {
    final double maxW = isWide ? 540.0 : (width >= 600 ? 580.0 : 380.0);
    final double fSize = isWide
        ? (width < 1280 ? 14.0 : 15.0)
        : (width <= 370 ? (width < 340 ? 12.0 : 12.8) : (width < 600 ? 13.5 : 14.5));

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Text(
          heroSubtitle,
          style: AppTheme.sansBody(
            fontSize: fSize,
            color: Colors.white70,
            height: 1.65,
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCtaButtons({
    required bool isTwoColumn,
    required bool isMobile,
    bool isIntermediate = false,
  }) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final double slide = (1.0 - _slideController.value) * 24;
        return Opacity(
          opacity: _slideController.value,
          child: Transform.translate(offset: Offset(0, slide), child: child),
        );
      },
      child: isMobile
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CinematicButton(
                    text: "Explore Our Services →",
                    isPrimary: true,
                    isFullWidth: true,
                    onPressed: () => widget.scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  const SizedBox(height: 12),
                  CinematicButton(
                    text: "▶ Watch Video",
                    isPrimary: false,
                    isFullWidth: true,
                    onPressed: () => CustomerDialogHelper.openLeadDialog(context),
                  ),
                ],
              ),
            )
          : Wrap(
              spacing: isIntermediate ? 12 : 16,
              runSpacing: 10,
              alignment: isTwoColumn ? WrapAlignment.start : WrapAlignment.center,
              children: [
                CinematicButton(
                  text: "Explore Our Services →",
                  isPrimary: true,
                  isFullWidth: false,
                  onPressed: () => widget.scaffoldKey.currentState?.openEndDrawer(),
                ),
                CinematicButton(
                  text: "▶ Watch Video",
                  isPrimary: false,
                  isFullWidth: false,
                  onPressed: () => CustomerDialogHelper.openLeadDialog(context),
                ),
              ],
            ),
    );
  }

  Widget _buildTrustStats(
    dynamic stats, {
    required bool isTwoColumn,
    required bool isMobile,
    bool isIntermediate = false,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = !isTwoColumn && width <= 370;
    final double iconBoxSize = isMobile ? (isNarrow ? 24 : 26) : 30;
    final double iconSize = isMobile ? (isNarrow ? 13 : 14) : 16;
    final double countFontSize = isMobile ? (isNarrow ? 12 : 13) : 15;
    final double labelFontSize = isMobile ? (isNarrow ? 8.8 : 9.5) : 11;
    final double spacing = isMobile
        ? (isNarrow ? 10 : 14)
        : (isIntermediate ? 18 : (isTwoColumn ? 30 : 24));

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Wrap(
        spacing: spacing,
        runSpacing: 12,
        alignment: isTwoColumn ? WrapAlignment.start : WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildStatBadge(
            icon: Icons.star_rounded,
            count: "500+",
            label: "Happy Clients",
            boxSize: iconBoxSize,
            iconSize: iconSize,
            countFontSize: countFontSize,
            labelFontSize: labelFontSize,
          ),
          _buildStatBadge(
            icon: Icons.celebration_rounded,
            count: "1000+",
            label: "Events Decorated",
            boxSize: iconBoxSize,
            iconSize: iconSize,
            countFontSize: countFontSize,
            labelFontSize: labelFontSize,
          ),
          _buildStatBadge(
            icon: Icons.history_rounded,
            count: "5+",
            label: "Years Experience",
            boxSize: iconBoxSize,
            iconSize: iconSize,
            countFontSize: countFontSize,
            labelFontSize: labelFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String count,
    required String label,
    required double boxSize,
    required double iconSize,
    required double countFontSize,
    required double labelFontSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC8A96E).withValues(alpha: 0.15),
            border: Border.all(color: const Color(0xFFC8A96E).withValues(alpha: 0.4), width: 1.2),
          ),
          child: Icon(icon, color: const Color(0xFFE8CC8A), size: iconSize),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: AppTheme.sansBody(
                fontSize: countFontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: AppTheme.sansBody(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoShowcase({
    required bool isTwoColumn,
    required bool isMobile,
    required double width,
  }) {
    final double maxW = isTwoColumn ? double.infinity : (isMobile ? 480.0 : 720.0);
    final double aspectRatio = isTwoColumn
        ? (width >= 1440 ? (16 / 10) : (16 / 10.5))
        : (isMobile ? (16 / 9.5) : (16 / 9));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
              border: Border.all(
                color: const Color(0xFFC8A96E).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC8A96E).withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 16.5 : 22.5),
              child: const CinematicBackground(),
            ),
          ),
        ),
      ),
    );
  }
}
