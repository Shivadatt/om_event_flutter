import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/presentation/screens/customer/helpers/customer_dialog_helper.dart';
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
    final isWide = width >= 960;
    final double pH = width >= 1440 ? 48.0 : (width >= 1000 ? 36.0 : 20.0);
    final double titleSize = isWide
        ? (width * 0.038).clamp(42.0, 64.0)
        : (width * 0.08).clamp(28.0, 42.0);

    return Container(
      width: double.infinity,
      color: const Color(0xFF0D1915),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: GoldGlowPainter())),
          const Positioned.fill(child: CustomPaint(painter: GrainPainter())),
          Padding(
            padding: EdgeInsets.fromLTRB(pH, isWide ? 40.0 : 28.0, pH, isWide ? 28.0 : 20.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1440),
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

                  if (isWide) {
                    // Desktop Split Layout (Matching Option 2 in Reference Image 1)
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEyebrow(),
                              const SizedBox(height: 14),
                              _buildHeading(headingText, titleSize, isWide),
                              const SizedBox(height: 14),
                              _buildSubtitle(subText, isWide),
                              const SizedBox(height: 24),
                              _buildCtaButtons(isWide),
                              const SizedBox(height: 28),
                              _buildTrustStats(stats, isWide),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          flex: 5,
                          child: _buildVideoShowcase(isMobile: false),
                        ),
                      ],
                    );
                  } else {
                    // Mobile / Tablet Layout (Matching Reference Image 1 Mobile)
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildEyebrow(),
                        const SizedBox(height: 14),
                        _buildHeading(headingText, titleSize, isWide),
                        const SizedBox(height: 14),
                        _buildSubtitle(subText, isWide),
                        const SizedBox(height: 22),
                        _buildCtaButtons(isWide),
                        const SizedBox(height: 24),
                        _buildTrustStats(stats, isWide),
                        const SizedBox(height: 28),
                        _buildVideoShowcase(isMobile: true),
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

  Widget _buildEyebrow() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryAccent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "BESPOKE EVENT DESIGN • AHMEDABAD",
            style: AppTheme.sansBody(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 3.5,
              color: AppColors.secondaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String text, double titleSize, bool isWide) {
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

  Widget _buildSubtitle(String heroSubtitle, bool isWide) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Text(
          heroSubtitle,
          style: AppTheme.sansBody(
            fontSize: 15.0,
            color: Colors.white70,
            height: 1.65,
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCtaButtons(bool isWide) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final double slide = (1.0 - _slideController.value) * 24;
        return Opacity(
          opacity: _slideController.value,
          child: Transform.translate(offset: Offset(0, slide), child: child),
        );
      },
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
        children: [
          // Primary Button: EXPLORE OUR SERVICES ->
          CinematicButton(
            text: "Explore Our Services →",
            isPrimary: true,
            onPressed: () => widget.scaffoldKey.currentState?.openEndDrawer(),
          ),
          // Secondary Button: ▶ WATCH VIDEO
          CinematicButton(
            text: "▶ Watch Video",
            isPrimary: false,
            onPressed: () => CustomerDialogHelper.openLeadDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustStats(dynamic stats, bool isWide) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Wrap(
        spacing: 32,
        runSpacing: 16,
        alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildStatBadge(
            icon: Icons.star_rounded,
            count: "500+",
            label: "Happy Clients",
          ),
          _buildStatBadge(
            icon: Icons.celebration_rounded,
            count: "1000+",
            label: "Events Decorated",
          ),
          if (isWide)
            _buildStatBadge(
              icon: Icons.history_rounded,
              count: "5+",
              label: "Years Experience",
            ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC8A96E).withValues(alpha: 0.15),
            border: Border.all(color: const Color(0xFFC8A96E).withValues(alpha: 0.4), width: 1.2),
          ),
          child: Icon(icon, color: const Color(0xFFE8CC8A), size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: AppTheme.sansBody(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: AppTheme.sansBody(
                fontSize: 11,
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

  Widget _buildVideoShowcase({required bool isMobile}) {
    return Container(
      height: isMobile ? 240 : 420,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(22.5),
        child: const CinematicBackground(),
      ),
    );
  }
}
