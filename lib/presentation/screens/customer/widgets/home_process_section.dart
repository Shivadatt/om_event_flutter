import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';
import 'package:om_event/domain/entities/review.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/widgets/app_page_container.dart';

// ─── Step data model ────────────────────────────────────────────────────────
class _StepData {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const _steps = [
  _StepData(
    number: "01",
    title: "Choose Your Canvas",
    description: "Browse our event collections and add the designs that speak to you.",
    icon: Icons.image_outlined,
  ),
  _StepData(
    number: "02",
    title: "Make It Personal",
    description: "Tune colors, themes and quantities. Tell us your custom wishes.",
    icon: Icons.palette_outlined,
  ),
  _StepData(
    number: "03",
    title: "Know Your Number",
    description: "See every cost itemized clearly and download your polished quotation.",
    icon: Icons.receipt_long_outlined,
  ),
  _StepData(
    number: "04",
    title: "We Bring The Wonder",
    description: "Our crew handles production and setup. You simply stay in the moment.",
    icon: Icons.celebration_outlined,
  ),
];

// ─── Main Unified Section ───────────────────────────────────────────────────
class ProcessSection extends StatelessWidget {
  final bool isDesktop;

  const ProcessSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Strict breakpoints matching responsive design specs
    final bool isDesktopLayout = width >= 1200;
    final bool isLaptopLayout = width >= 1024 && width < 1200;
    final bool isTabletLayout = width >= 600 && width < 1024;
    final bool isMobileLayout = width < 600;

    final double hPad = isMobileLayout
        ? (width < 380 ? 10.0 : 14.0)
        : AppPageContainer.horizontalPadding(context);
    final double vPad = isDesktopLayout
        ? 40.0
        : (isLaptopLayout ? 34.0 : (isTabletLayout ? 28.0 : 20.0));

    final double innerHPad = isDesktopLayout
        ? 36.0
        : (isLaptopLayout
            ? 26.0
            : (isTabletLayout ? 22.0 : (width < 380 ? 12.0 : 16.0)));
    final double innerVPad = isDesktopLayout
        ? 32.0
        : (isLaptopLayout
            ? 26.0
            : (isTabletLayout ? 22.0 : 16.0));

    return Container(
      width: double.infinity,
      color: const Color(0xFF152621), // Page background
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: vPad,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
          child: Container(
            decoration: BoxDecoration(
              // Near-black luxury base with deep subtle emerald undertone
              color: const Color(0xFF060907),
              borderRadius: BorderRadius.circular(isMobileLayout ? 16 : 22),
              border: Border.all(
                color: AppColors.secondaryAccent.withValues(alpha: 0.45),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.06),
                  blurRadius: 36,
                  spreadRadius: 1,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Top-right luminous golden ribbon waves and glowing dust
                Positioned(
                  top: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: Size(
                        isDesktopLayout
                            ? 620
                            : (isLaptopLayout
                                ? 500
                                : (isTabletLayout ? 400 : 280)),
                        250,
                      ),
                      painter: _GoldRibbonCurvesPainter(),
                    ),
                  ),
                ),

                // Ambient corner glows
                Positioned(
                  top: -70,
                  left: -70,
                  child: IgnorePointer(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondaryAccent.withValues(alpha: 0.09),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: innerHPad,
                    vertical: innerVPad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TOP: Eyebrow + Heading + Subtitle ─────────────────
                      _buildHeader(
                        isDesktop: isDesktopLayout,
                        isLaptop: isLaptopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
                        width: width,
                      ),
                      SizedBox(height: isMobileLayout ? 16 : 22),

                      // ── MIDDLE: 4 Process Cards ───────────────────────────
                      _buildProcessCards(
                        isDesktop: isDesktopLayout,
                        isLaptop: isLaptopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
                      ),
                      SizedBox(height: isMobileLayout ? 16 : 22),

                      // ── BELOW PROCESS: Compact Statistics Strip ───────────
                      _buildStatsBand(
                        isDesktop: isDesktopLayout,
                        isLaptop: isLaptopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
                      ),
                      SizedBox(height: isMobileLayout ? 20 : 26),

                      // ── BOTTOM: "WHAT OUR CUSTOMERS SAY." + Testimonials ─
                      _buildReviewsSection(
                        isDesktop: isDesktopLayout,
                        isLaptop: isLaptopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
                        availableWidth: width,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader({
    required bool isDesktop,
    required bool isLaptop,
    required bool isTablet,
    required bool isMobile,
    required double width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eyebrow
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 1.5,
              color: AppColors.secondaryAccent,
            ),
            const SizedBox(width: 8),
            Text(
              "EASY BY DESIGN",
              style: AppTheme.sansBody(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.2,
                color: AppColors.secondaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Main Editorial Heading in Champagne Gold Radiance
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFDF5),
              Color(0xFFFFEEAA),
              AppColors.secondaryAccent,
              Color(0xFFC6992E),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ).createShader(bounds),
          child: Text(
            "YOUR CELEBRATION,\nWITHOUT THE CHAOS.",
            style: GoogleFonts.italiana(
              fontSize: isDesktop
                  ? 34.0
                  : (isLaptop
                      ? 29.0
                      : (isTablet
                          ? 26.0
                          : (width < 360 ? 19.0 : 21.5))),
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.08,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          "Four seamless steps from vision to reality.",
          style: AppTheme.sansBody(
            fontSize: isDesktop ? 13.0 : (isMobile ? 11.5 : 12.0),
            color: const Color(0xFFBAC5C0),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── 4 PROCESS CARDS ────────────────────────────────────────────────────────
  Widget _buildProcessCards({
    required bool isDesktop,
    required bool isLaptop,
    required bool isTablet,
    required bool isMobile,
  }) {
    // Desktop and Laptop: 4 Cards in ONE horizontal row with connector arrows
    if (isDesktop || isLaptop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: _ProcessCard(
                  step: _steps[i],
                  isMobile: false,
                  isLaptop: isLaptop,
                ),
              ),
              if (i < _steps.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isLaptop ? 2.0 : 4.0),
                  child: Center(
                    child: _ConnectorArrow(color: AppColors.secondaryAccent),
                  ),
                ),
            ],
          ],
        ),
      );
    }

    // Tablet: 2x2 grid with connector arrows in each row
    if (isTablet) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ProcessCard(
                    step: _steps[0],
                    isMobile: false,
                    isLaptop: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Center(
                    child: _ConnectorArrow(color: AppColors.secondaryAccent),
                  ),
                ),
                Expanded(
                  child: _ProcessCard(
                    step: _steps[1],
                    isMobile: false,
                    isLaptop: false,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ProcessCard(
                    step: _steps[2],
                    isMobile: false,
                    isLaptop: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Center(
                    child: _ConnectorArrow(color: AppColors.secondaryAccent),
                  ),
                ),
                Expanded(
                  child: _ProcessCard(
                    step: _steps[3],
                    isMobile: false,
                    isLaptop: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile: Stacked vertically with full width cards and horizontal internal layout
    return Column(
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          _ProcessCard(
            step: _steps[i],
            isMobile: true,
            isLaptop: false,
          ),
          if (i < _steps.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  // ── STATS BAND ─────────────────────────────────────────────────────────────
  Widget _buildStatsBand({
    required bool isDesktop,
    required bool isLaptop,
    required bool isTablet,
    required bool isMobile,
  }) {
    return Obx(() {
      final rawStats = AppConfigService.to.rxStatisticsSettings.value;
      final defaults = StatisticsSettings.defaultVal();
      final stats = (rawStats.completedEvents == 0 &&
              rawStats.happyClients == 0 &&
              rawStats.cities == 0 &&
              rawStats.years == 0)
          ? defaults
          : rawStats;

      final statItems = [
        _StatModel(
          icon: Icons.celebration_outlined,
          number: "${stats.completedEvents} +",
          label: "COMPLETED EVENTS",
        ),
        _StatModel(
          icon: Icons.people_alt_outlined,
          number: "${stats.happyClients} +",
          label: "HAPPY CLIENTS",
        ),
        _StatModel(
          icon: Icons.location_on_outlined,
          number: "${stats.cities} +",
          label: "CITIES REACHED",
        ),
        _StatModel(
          icon: Icons.emoji_events_outlined,
          number: "${stats.years} +",
          label: "YEARS OF CURATION",
        ),
      ];

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: (isDesktop || isLaptop) ? (isLaptop ? 18.0 : 24.0) : 14.0,
          vertical: 14.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF060C0A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryAccent.withValues(alpha: 0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: AppColors.secondaryAccent.withValues(alpha: 0.08),
              blurRadius: 18,
              spreadRadius: 0,
            ),
          ],
        ),
        // Tablet & Mobile: 2x2 clean grid with dividers
        // Desktop & Laptop: 1 horizontal row with vertical dividers
        child: (isTablet || isMobile)
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCell(statItems[0], isMobile: isMobile)),
                      Container(
                        width: 1,
                        height: isMobile ? 30 : 34,
                        color: AppColors.secondaryAccent.withValues(alpha: 0.28),
                      ),
                      Expanded(child: _buildStatCell(statItems[1], isMobile: isMobile)),
                    ],
                  ),
                  Divider(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.18),
                    height: isMobile ? 14 : 18,
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildStatCell(statItems[2], isMobile: isMobile)),
                      Container(
                        width: 1,
                        height: isMobile ? 30 : 34,
                        color: AppColors.secondaryAccent.withValues(alpha: 0.28),
                      ),
                      Expanded(child: _buildStatCell(statItems[3], isMobile: isMobile)),
                    ],
                  ),
                ],
              )
            : Row(
                children: List.generate(statItems.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    return Container(
                      width: 1,
                      height: 32,
                      color: AppColors.secondaryAccent.withValues(alpha: 0.28),
                    );
                  }
                  final item = statItems[index ~/ 2];
                  return Expanded(
                    child: _buildStatCell(item, isMobile: false, isLaptop: isLaptop),
                  );
                }),
              ),
      );
    });
  }

  // Cell layout: Icon + Number on TOP, Label on BOTTOM
  Widget _buildStatCell(
    _StatModel s, {
    required bool isMobile,
    bool isLaptop = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              s.icon,
              size: isMobile ? 18 : (isLaptop ? 19 : 21),
              color: AppColors.secondaryAccent,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              s.number,
              style: GoogleFonts.italiana(
                fontSize: isMobile ? 18 : (isLaptop ? 19 : 21),
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryAccent,
                height: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          s.label,
          textAlign: TextAlign.center,
          style: AppTheme.sansBody(
            fontSize: isMobile ? 8.0 : (isLaptop ? 8.0 : 8.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }

  // ── REVIEWS SECTION ────────────────────────────────────────────────────────
  Widget _buildReviewsSection({
    required bool isDesktop,
    required bool isLaptop,
    required bool isTablet,
    required bool isMobile,
    required double availableWidth,
  }) {
    final controller = Get.isRegistered<CatalogController>()
        ? Get.find<CatalogController>()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section Header
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "HEARD FROM CLIENTS",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: AppColors.secondaryAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.2,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.italiana(
                    fontSize: isDesktop
                        ? 26.0
                        : (isLaptop
                            ? 24.0
                            : (isTablet
                                ? 22.0
                                : (availableWidth < 360 ? 17.5 : 19.5))),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(text: "WHAT ", style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: "OUR CUSTOMERS SAY.",
                      style: TextStyle(color: AppColors.secondaryAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Real experiences shared by our happy clients.",
                style: AppTheme.sansBody(
                  fontSize: isMobile ? 11.5 : 12.5,
                  color: const Color(0xFFBAC5C0),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),

        // Carousel of Testimonials
        if (controller != null)
          Obx(() {
            final reviews = controller.rxReviews.isNotEmpty
                ? controller.rxReviews
                : _defaultReviews;

            return _TestimonialCarousel(
              reviews: reviews,
              isDesktop: isDesktop,
              isLaptop: isLaptop,
              isTablet: isTablet,
              isMobile: isMobile,
              availableWidth: availableWidth,
            );
          })
        else
          _TestimonialCarousel(
            reviews: _defaultReviews,
            isDesktop: isDesktop,
            isLaptop: isLaptop,
            isTablet: isTablet,
            isMobile: isMobile,
            availableWidth: availableWidth,
          ),
      ],
    );
  }
}

// ─── Stat model helper ───────────────────────────────────────────────────────
class _StatModel {
  final IconData icon;
  final String number;
  final String label;

  const _StatModel({
    required this.icon,
    required this.number,
    required this.label,
  });
}

// ─── Default Sample Reviews Matching Target ──────────────────────────────────
final List<Review> _defaultReviews = [
  Review(
    id: "r1",
    customerName: "Meera Patel",
    eventName: "First Birthday",
    rating: 5,
    comment:
        "Beautiful execution, calm team, zero last-minute chaos. The pastel setup looked even better in person.",
    imageUrl: "",
    isVerified: true,
    isPublished: true,
    createdAt: DateTime.now(),
  ),
  Review(
    id: "r2",
    customerName: "Riya & Aakash",
    eventName: "Wedding",
    rating: 5,
    comment:
        "nice decoration and fantastic coordination. Everything was timely and seamlessly executed for our guests.",
    imageUrl: "",
    isVerified: true,
    isPublished: true,
    createdAt: DateTime.now(),
  ),
  Review(
    id: "r3",
    customerName: "Riya & Aakash",
    eventName: "Engagement",
    rating: 5,
    comment:
        "They understood the mood instantly. Every corner felt intentional and the quotation stayed completely transparent.",
    imageUrl: "",
    isVerified: true,
    isPublished: true,
    createdAt: DateTime.now(),
  ),
];

// ─── Process Card Widget with Cinematic Atmosphere ───────────────────────────
class _ProcessCard extends StatefulWidget {
  final _StepData step;
  final bool isMobile;
  final bool isLaptop;

  const _ProcessCard({
    required this.step,
    required this.isMobile,
    required this.isLaptop,
  });

  @override
  State<_ProcessCard> createState() => _ProcessCardState();
}

class _ProcessCardState extends State<_ProcessCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.step;
    final isMobile = widget.isMobile;
    final isLaptop = widget.isLaptop;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _hovered ? -3.0 : 0.0, 0.0),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : (isLaptop ? 12 : 16),
          vertical: isMobile ? 12 : (isLaptop ? 14 : 16),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Deep near-black base with subtle warm gold/amber atmospheric lighting
          gradient: RadialGradient(
            center: const Alignment(-0.45, -0.6),
            radius: 1.3,
            colors: _hovered
                ? [
                    const Color(0xFF281E12).withValues(alpha: 0.65),
                    const Color(0xFF131B16),
                    const Color(0xFF080C0A),
                  ]
                : [
                    const Color(0xFF20170D).withValues(alpha: 0.45),
                    const Color(0xFF0E1511),
                    const Color(0xFF060A08),
                  ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(
            color: _hovered
                ? AppColors.secondaryAccent.withValues(alpha: 0.75)
                : AppColors.secondaryAccent.withValues(alpha: 0.38),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.6 : 0.45),
              blurRadius: _hovered ? 20 : 14,
              offset: const Offset(0, 6),
            ),
            if (_hovered)
              BoxShadow(
                color: AppColors.secondaryAccent.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Soft warm gold ambient glow in upper area
            Positioned(
              top: -24,
              left: -24,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD56B).withValues(alpha: _hovered ? 0.16 : 0.09),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Card content: Horizontal for mobile, Vertical column for Desktop/Tablet
            if (isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Number badge on left
                  _buildNumberBadge(s.number, isCompact: true),
                  const SizedBox(width: 12),

                  // Title + Description in center
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.italiana(
                                  fontSize: 14.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              s.icon,
                              size: 14,
                              color: AppColors.secondaryAccent.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sansBody(
                            fontSize: 10.5,
                            color: const Color(0xFFBAC5C0),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Action arrow button on right
                  _buildArrowPill(isCompact: true),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Number badge + Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNumberBadge(s.number, isCompact: isLaptop),
                      _buildIconBox(s.icon, isCompact: isLaptop),
                    ],
                  ),
                  SizedBox(height: isLaptop ? 10 : 14),

                  // Title
                  Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.italiana(
                      fontSize: isLaptop ? 15.0 : 16.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.35,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Expanded(
                    child: Text(
                      s.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: isLaptop ? 10.5 : 11.5,
                        color: const Color(0xFFBAC5C0),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Right Arrow Pill
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildArrowPill(isCompact: isLaptop),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberBadge(String number, {required bool isCompact}) {
    final size = isCompact ? 32.0 : 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.85),
          width: 1.3,
        ),
        gradient: const RadialGradient(
          colors: [
            Color(0xFF261D12),
            Color(0xFF0C130E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.22),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: GoogleFonts.italiana(
          fontSize: isCompact ? 13.0 : 14.5,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryAccent,
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, {required bool isCompact}) {
    final size = isCompact ? 28.0 : 32.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF0B1410),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.10),
            blurRadius: 6,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: isCompact ? 14 : 16,
        color: AppColors.secondaryAccent,
      ),
    );
  }

  Widget _buildArrowPill({required bool isCompact}) {
    final size = isCompact ? 26.0 : 30.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [
            Color(0xFFFFF2B2),
            AppColors.secondaryAccent,
            Color(0xFFC4952B),
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.arrow_forward_rounded,
        size: isCompact ? 13 : 15,
        color: const Color(0xFF0B1410),
      ),
    );
  }
}

// ─── Testimonial Carousel ────────────────────────────────────────────────────
class _TestimonialCarousel extends StatefulWidget {
  final List<Review> reviews;
  final bool isDesktop;
  final bool isLaptop;
  final bool isTablet;
  final bool isMobile;
  final double availableWidth;

  const _TestimonialCarousel({
    required this.reviews,
    required this.isDesktop,
    required this.isLaptop,
    required this.isTablet,
    required this.isMobile,
    required this.availableWidth,
  });

  @override
  State<_TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<_TestimonialCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant _TestimonialCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pageCount = _getPageCount();
    if (_currentPage >= pageCount && pageCount > 0) {
      _currentPage = pageCount - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final pageCount = _getPageCount();
      if (pageCount <= 1) return;
      final nextPage = (_currentPage + 1) % pageCount;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  int _getItemsPerPage() {
    // 3 cards on desktop, laptop, and tablet >= 768px (matches tablet 4:3 reference)
    if (widget.availableWidth >= 768) return 3;
    // 2 cards on narrow tablet (600px - 767px)
    if (widget.availableWidth >= 600) return 2;
    // 1 card on mobile (< 600px)
    return 1;
  }

  int _getPageCount() {
    final itemsPerPage = _getItemsPerPage();
    if (widget.reviews.isEmpty) return 0;
    return (widget.reviews.length / itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) return const SizedBox.shrink();

    final itemsPerPage = _getItemsPerPage();
    final pageCount = _getPageCount();

    // Chunk reviews into pages
    final List<List<Review>> pages = [];
    for (var i = 0; i < widget.reviews.length; i += itemsPerPage) {
      final end = (i + itemsPerPage < widget.reviews.length)
          ? i + itemsPerPage
          : widget.reviews.length;
      pages.add(widget.reviews.sublist(i, end));
    }

    final double cardHeight = widget.isMobile ? 180.0 : (widget.isTablet ? 176.0 : 172.0);

    return Column(
      children: [
        Row(
          children: [
            // Left Chevron Button - always visible outside cards, disabled if pageCount <= 1
            Padding(
              padding: EdgeInsets.only(right: widget.isMobile ? 4.0 : 8.0),
              child: _arrowButton(
                icon: Icons.chevron_left_rounded,
                isMobile: widget.isMobile,
                onPressed: pageCount > 1
                    ? () {
                        _startAutoPlay();
                        final prevPage = (_currentPage - 1 + pageCount) % pageCount;
                        _pageController.animateToPage(
                          prevPage,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    : null,
              ),
            ),

            // PageView containing cards
            Expanded(
              child: SizedBox(
                height: cardHeight,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, pageIndex) {
                    final pageItems = pages[pageIndex];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(itemsPerPage, (index) {
                        if (index < pageItems.length) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.isMobile ? 0.0 : 6.0,
                              ),
                              child: _TestimonialCard(
                                review: pageItems[index],
                                isMobile: widget.isMobile,
                              ),
                            ),
                          );
                        } else {
                          return const Expanded(child: SizedBox());
                        }
                      }),
                    );
                  },
                ),
              ),
            ),

            // Right Chevron Button - always visible outside cards, disabled if pageCount <= 1
            Padding(
              padding: EdgeInsets.only(left: widget.isMobile ? 4.0 : 8.0),
              child: _arrowButton(
                icon: Icons.chevron_right_rounded,
                isMobile: widget.isMobile,
                onPressed: pageCount > 1
                    ? () {
                        _startAutoPlay();
                        final nextPage = (_currentPage + 1) % pageCount;
                        _pageController.animateToPage(
                          nextPage,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),

        // Indicator dots
        if (pageCount > 1)
          Padding(
            padding: const EdgeInsets.only(top: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pageCount, (index) {
                final isSelected = _currentPage == index;
                return GestureDetector(
                  onTap: () {
                    _startAutoPlay();
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isSelected
                          ? AppColors.secondaryAccent
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isMobile,
  }) {
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: isMobile ? 28 : 32,
          height: isMobile ? 28 : 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A1310),
            border: Border.all(
              color: isEnabled
                  ? AppColors.secondaryAccent.withValues(alpha: 0.52)
                  : AppColors.secondaryAccent.withValues(alpha: 0.22),
              width: 1.0,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: isMobile ? 16 : 18,
            color: isEnabled
                ? AppColors.secondaryAccent
                : AppColors.secondaryAccent.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

// ─── Testimonial Card Widget ─────────────────────────────────────────────────
class _TestimonialCard extends StatelessWidget {
  final Review review;
  final bool isMobile;

  const _TestimonialCard({
    required this.review,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final initials = review.customerName.isEmpty
        ? 'C'
        : review.customerName[0].toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF070D0A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars + Quote mark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(review.rating.clamp(1, 5), (index) {
                  return Icon(
                    Icons.star_rounded,
                    size: isMobile ? 13 : 14,
                    color: AppColors.secondaryAccent,
                  );
                }),
              ),
              Icon(
                Icons.format_quote_rounded,
                size: isMobile ? 20 : 22,
                color: AppColors.secondaryAccent.withValues(alpha: 0.45),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Comment
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                review.comment,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: isMobile ? 11.0 : 11.5,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Customer Profile Details
          Row(
            children: [
              // Avatar circle with initial
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryAccent,
                    width: 1.2,
                  ),
                  color: const Color(0xFF0F1E18),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (review.eventName.isNotEmpty)
                      Text(
                        review.eventName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.sansBody(
                          fontSize: 9.0,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Connector Arrow ─────────────────────────────────────────────────────────
class _ConnectorArrow extends StatelessWidget {
  final Color color;

  const _ConnectorArrow({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 32,
      child: Center(
        child: CustomPaint(
          painter: _DashArrowPainter(color: color),
          size: const Size(24, 2),
        ),
      ),
    );
  }
}

class _DashArrowPainter extends CustomPainter {
  final Color color;

  const _DashArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double x = 0;
    while (x < size.width - 5) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 3, size.height / 2), paint);
      x += 6;
    }

    final arrowPaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width - 5, size.height / 2 - 3.5),
      Offset(size.width, size.height / 2),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width - 5, size.height / 2 + 3.5),
      Offset(size.width, size.height / 2),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DashArrowPainter old) => old.color != color;
}

// ─── Top-Right Multi-Layered Luminous Gold Ribbon Curves Painter ───────────────
class _GoldRibbonCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Broad soft golden glow wave
    final glowPaint = Paint()
      ..color = AppColors.secondaryAccent.withValues(alpha: 0.10)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final glowPath = Path()
      ..moveTo(0, h * 0.92)
      ..cubicTo(w * 0.32, h * 0.22, w * 0.68, h * 0.82, w, h * 0.12);
    canvas.drawPath(glowPath, glowPaint);

    // 2. Primary crisp gold ribbon
    final p1 = Paint()
      ..color = AppColors.secondaryAccent.withValues(alpha: 0.42)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, h * 0.92)
      ..cubicTo(w * 0.32, h * 0.22, w * 0.68, h * 0.82, w, h * 0.12);
    canvas.drawPath(path1, p1);

    // 3. Secondary flowing ribbon
    final p2 = Paint()
      ..color = AppColors.secondaryAccent.withValues(alpha: 0.30)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final path2 = Path()
      ..moveTo(w * 0.08, h * 0.98)
      ..cubicTo(w * 0.38, h * 0.32, w * 0.74, h * 0.86, w, h * 0.24);
    canvas.drawPath(path2, p2);

    // 4. Tertiary delicate ribbon
    final p3 = Paint()
      ..color = AppColors.secondaryAccent.withValues(alpha: 0.20)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path3 = Path()
      ..moveTo(w * 0.18, h * 1.0)
      ..cubicTo(w * 0.46, h * 0.44, w * 0.80, h * 0.90, w, h * 0.36);
    canvas.drawPath(path3, p3);

    // 5. Higher accent ribbon
    final p4 = Paint()
      ..color = AppColors.secondaryAccent.withValues(alpha: 0.16)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final path4 = Path()
      ..moveTo(w * 0.25, h * 0.72)
      ..cubicTo(w * 0.52, h * 0.16, w * 0.82, h * 0.60, w, h * 0.05);
    canvas.drawPath(path4, p4);

    // 6. Lower whisper wave
    final p5 = Paint()
      ..color = AppColors.secondaryAccent.withValues(alpha: 0.10)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final path5 = Path()
      ..moveTo(w * 0.35, h * 1.0)
      ..cubicTo(w * 0.60, h * 0.58, w * 0.88, h * 0.94, w, h * 0.48);
    canvas.drawPath(path5, p5);

    // 7. Ambient luminous gold stardust sparkles along the ribbon flow
    final sparkPaint = Paint()..style = PaintingStyle.fill;

    final sparks = [
      Offset(w * 0.28, h * 0.32),
      Offset(w * 0.34, h * 0.26),
      Offset(w * 0.40, h * 0.38),
      Offset(w * 0.46, h * 0.46),
      Offset(w * 0.52, h * 0.54),
      Offset(w * 0.58, h * 0.64),
      Offset(w * 0.64, h * 0.74),
      Offset(w * 0.72, h * 0.78),
      Offset(w * 0.79, h * 0.66),
      Offset(w * 0.84, h * 0.50),
      Offset(w * 0.89, h * 0.34),
      Offset(w * 0.94, h * 0.20),
      Offset(w * 0.60, h * 0.42),
      Offset(w * 0.68, h * 0.52),
      Offset(w * 0.75, h * 0.38),
      Offset(w * 0.82, h * 0.25),
      Offset(w * 0.48, h * 0.30),
      Offset(w * 0.38, h * 0.50),
    ];

    for (int i = 0; i < sparks.length; i++) {
      final alpha = (i % 3 == 0) ? 0.55 : (i % 2 == 0 ? 0.38 : 0.25);
      final radius = (i % 4 == 0) ? 2.0 : (i % 2 == 0 ? 1.4 : 1.0);
      sparkPaint.color = AppColors.secondaryAccent.withValues(alpha: alpha);
      canvas.drawCircle(sparks[i], radius, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
