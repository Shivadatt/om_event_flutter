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
  bool _isHovered = false;

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
    final height = MediaQuery.of(context).size.height;
    final double pH = widget.isDesktop ? 80.0 : 24.0;
    final double titleSize = width >= 700 ? (width * 0.055).clamp(42.0, 76.0) : 34.0;
    final double heroHeight = height.clamp(660.0, 920.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: heroHeight),
        color: const Color(0xFF0D1915),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: CinematicBackground(isHovered: _isHovered)),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
            Positioned.fill(child: _buildGradientOverlay()),
            const Positioned.fill(child: CustomPaint(painter: GoldGlowPainter())),
            const Positioned.fill(child: CustomPaint(painter: GrainPainter())),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pH),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Obx(() {
                      final homepage = AppConfigService.to.rxHomepageSettings.value;
                      final stats = AppConfigService.to.rxStatisticsSettings.value;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: widget.isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 72),
                          _buildEyebrow(),
                          const SizedBox(height: 18),
                          _buildHeading(titleSize),
                          const SizedBox(height: 14),
                          _buildSubtitle(homepage.heroSubtitle),
                          const SizedBox(height: 38),
                          _buildCtaButtons(),
                          const SizedBox(height: 60),
                          _buildTrustStats(stats),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF080A08).withValues(alpha: 0.88),
            const Color(0xFF0A120E).withValues(alpha: 0.65),
            const Color(0xFF000000).withValues(alpha: 0.20),
          ],
          stops: const [0.0, 0.40, 1.0],
        ),
      ),
    );
  }

  Widget _buildEyebrow() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Text(
        "BESPOKE EVENT DESIGN • AHMEDABAD",
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 4.0,
          color: AppColors.secondaryAccent,
        ),
      ),
    );
  }

  Widget _buildHeading(double titleSize) {
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
          "CELEBRATIONS,\nTHOUGHTFULLY\nCOMPOSED.",
          style: GoogleFonts.italiana(
            fontSize: titleSize,
            color: Colors.white,
            height: 0.96,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.5,
          ),
          textAlign: widget.isDesktop ? TextAlign.start : TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSubtitle(String heroSubtitle) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Text(
          heroSubtitle,
          style: AppTheme.sansBody(fontSize: 15.5, color: AppColors.muted.withValues(alpha: 0.85), height: 1.7),
          textAlign: widget.isDesktop ? TextAlign.start : TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCtaButtons() {
    final primaryBtn = CinematicButton(
      text: "Design Your Event",
      isPrimary: true,
      onPressed: () => widget.scaffoldKey.currentState?.openEndDrawer(),
    );
    final secondaryBtn = CinematicButton(
      text: "Plan With An Expert",
      isPrimary: false,
      onPressed: () => CustomerDialogHelper.openLeadDialog(context),
    );

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final double slide = (1.0 - _slideController.value) * 24;
        return Opacity(
          opacity: _slideController.value,
          child: Transform.translate(offset: Offset(0, slide), child: child),
        );
      },
      child: widget.isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                primaryBtn,
                const SizedBox(width: 16),
                secondaryBtn,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                primaryBtn,
                const SizedBox(height: 12),
                secondaryBtn,
              ],
            ),
    );
  }

  Widget _buildTrustStats(dynamic stats) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) => Opacity(opacity: _fadeController.value, child: child),
      child: Container(
        width: double.infinity,
        alignment: widget.isDesktop ? Alignment.centerLeft : Alignment.center,
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _statItem("4.9 Google Rating"),
            _dotSeparator(),
            _statItem("${stats.completedEvents}+ Celebrations"),
            _dotSeparator(),
            _statItem("${stats.years} Years Experience"),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label) => Text(label.toUpperCase(), style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.muted.withValues(alpha: 0.65), letterSpacing: 2.0));
  Widget _dotSeparator() => Text("•", style: TextStyle(color: AppColors.secondaryAccent.withValues(alpha: 0.4), fontSize: 12));
}
