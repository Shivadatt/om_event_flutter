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
    final width = MediaQuery.of(context).size.width;
    final bool isDesktopLayout = width >= 1024 && isDesktop;
    final bool isTabletLayout = width >= 650 && width < 1024;
    final bool isMobileLayout = width < 650;

    return Container(
      width: double.infinity,
      color: const Color(0xFF152621), // Page background
      padding: EdgeInsets.symmetric(
        horizontal: AppPageContainer.horizontalPadding(context),
        vertical: isDesktopLayout ? 40.0 : 28.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
          child: Container(
            decoration: BoxDecoration(
              // Near-black luxury base with deep subtle emerald undertone
              color: const Color(0xFF060907),
              borderRadius: BorderRadius.circular(22),
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
                      size: Size(isDesktopLayout ? 620 : (isTabletLayout ? 420 : 300), 250),
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
                    horizontal: isDesktopLayout ? 36.0 : (isTabletLayout ? 24.0 : 18.0),
                    vertical: isDesktopLayout ? 32.0 : (isTabletLayout ? 24.0 : 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TOP: Eyebrow + Heading + Subtitle ─────────────────
                      _buildHeader(isDesktop: isDesktopLayout, isTablet: isTabletLayout),
                      const SizedBox(height: 22),

                      // ── MIDDLE: 4 Process Cards in ONE Row ───────────────
                      _buildProcessCards(
                        isDesktop: isDesktopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
                      ),
                      const SizedBox(height: 22),

                      // ── BELOW PROCESS: Compact Statistics Strip ───────────
                      _buildStatsBand(
                        isDesktop: isDesktopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
                      ),
                      const SizedBox(height: 26),

                      // ── BOTTOM: "WHAT OUR CUSTOMERS SAY." + Testimonials ─
                      _buildReviewsSection(
                        isDesktop: isDesktopLayout,
                        isTablet: isTabletLayout,
                        isMobile: isMobileLayout,
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
  Widget _buildHeader({required bool isDesktop, required bool isTablet}) {
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
              fontSize: isDesktop ? 34.0 : (isTablet ? 28.0 : 23.0),
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
            fontSize: isDesktop ? 13.0 : 12.0,
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
    required bool isTablet,
    required bool isMobile,
  }) {
    if (isDesktop) {
      // 4 Cards in ONE horizontal row on desktop with connector arrows
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            Expanded(
              child: _ProcessCard(
                step: _steps[i],
              ),
            ),
            if (i < _steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _ConnectorArrow(color: AppColors.secondaryAccent),
              ),
          ],
        ],
      );
    }

    if (isTablet) {
      // 2x2 grid on tablet
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _ProcessCard(step: _steps[0])),
              const SizedBox(width: 12),
              Expanded(child: _ProcessCard(step: _steps[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ProcessCard(step: _steps[2])),
              const SizedBox(width: 12),
              Expanded(child: _ProcessCard(step: _steps[3])),
            ],
          ),
        ],
      );
    }

    // Mobile: horizontally scrollable cards so they never wrap into huge vertical cards
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_steps.length, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < _steps.length - 1 ? 12.0 : 0.0),
            child: SizedBox(
              width: 220,
              child: _ProcessCard(step: _steps[i]),
            ),
          );
        }),
      ),
    );
  }

  // ── STATS BAND (MATCHING SECOND IMAGE) ─────────────────────────────────────
  Widget _buildStatsBand({
    required bool isDesktop,
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
          horizontal: isDesktop ? 24.0 : 16.0,
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
        child: isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCell(statItems[0])),
                      Container(width: 1, height: 32, color: AppColors.secondaryAccent.withValues(alpha: 0.28)),
                      Expanded(child: _buildStatCell(statItems[1])),
                    ],
                  ),
                  Divider(color: AppColors.secondaryAccent.withValues(alpha: 0.18), height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCell(statItems[2])),
                      Container(width: 1, height: 32, color: AppColors.secondaryAccent.withValues(alpha: 0.28)),
                      Expanded(child: _buildStatCell(statItems[3])),
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
                  return Expanded(child: _buildStatCell(item));
                }),
              ),
      );
    });
  }

  // Cell layout in Image 2: Icon + Number on TOP, Label on BOTTOM
  Widget _buildStatCell(_StatModel s) {
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
              size: 21,
              color: AppColors.secondaryAccent,
            ),
            const SizedBox(width: 8),
            Text(
              s.number,
              style: GoogleFonts.italiana(
                fontSize: 21,
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
            fontSize: 8.5,
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
    required bool isTablet,
    required bool isMobile,
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
                    fontSize: isDesktop ? 26.0 : 21.0,
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
                  fontSize: 12.5,
                  color: const Color(0xFFBAC5C0),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Carousel of Testimonials
        if (controller != null)
          Obx(() {
            final reviews = controller.rxReviews.isNotEmpty
                ? controller.rxReviews
                : _defaultReviews;

            return _TestimonialCarousel(
              reviews: reviews,
              isDesktop: isDesktop,
              isTablet: isTablet,
              isMobile: isMobile,
            );
          })
        else
          _TestimonialCarousel(
            reviews: _defaultReviews,
            isDesktop: isDesktop,
            isTablet: isTablet,
            isMobile: isMobile,
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

  const _ProcessCard({required this.step});

  @override
  State<_ProcessCard> createState() => _ProcessCardState();
}

class _ProcessCardState extends State<_ProcessCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.step;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _hovered ? -4.0 : 0.0, 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            // Soft warm gold ambient glow in upper area matching Image 2
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Number badge + Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Number badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryAccent.withValues(alpha: 0.85),
                          width: 1.4,
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
                        s.number,
                        style: GoogleFonts.italiana(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryAccent,
                        ),
                      ),
                    ),
                    // Icon in compact rounded square container
                    Container(
                      width: 32,
                      height: 32,
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
                        s.icon,
                        size: 16,
                        color: AppColors.secondaryAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  s.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.italiana(
                    fontSize: 16.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                SizedBox(
                  height: 48,
                  child: Text(
                    s.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sansBody(
                      fontSize: 11.5,
                      color: const Color(0xFFBAC5C0),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom Right Arrow Pill
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 30,
                    height: 30,
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
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Color(0xFF0B1410),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Testimonial Carousel ────────────────────────────────────────────────────
class _TestimonialCarousel extends StatefulWidget {
  final List<Review> reviews;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;

  const _TestimonialCarousel({
    required this.reviews,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
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
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      final pageCount = _getPageCount();
      if (pageCount <= 1) return;
      final nextPage = (_currentPage + 1) % pageCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  int _getItemsPerPage() {
    if (widget.isDesktop) return 3;
    if (widget.isTablet) return 2;
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

    return Column(
      children: [
        Row(
          children: [
            // Left Chevron Button
            if (pageCount > 1)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _arrowButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: () {
                    _startAutoPlay();
                    final prevPage = (_currentPage - 1 + pageCount) % pageCount;
                    _pageController.animateToPage(
                      prevPage,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                ),
              ),

            // PageView
            Expanded(
              child: SizedBox(
                height: 172,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, pageIndex) {
                    final pageItems = pages[pageIndex];
                    return Row(
                      children: List.generate(itemsPerPage, (index) {
                        if (index < pageItems.length) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _TestimonialCard(review: pageItems[index]),
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

            // Right Chevron Button
            if (pageCount > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _arrowButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed: () {
                    _startAutoPlay();
                    final nextPage = (_currentPage + 1) % pageCount;
                    _pageController.animateToPage(
                      nextPage,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Indicator dots
        if (pageCount > 1)
          Row(
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
      ],
    );
  }

  Widget _arrowButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A1310),
            border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.52),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryAccent.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.secondaryAccent,
          ),
        ),
      ),
    );
  }
}

// ─── Testimonial Card Widget ─────────────────────────────────────────────────
class _TestimonialCard extends StatelessWidget {
  final Review review;

  const _TestimonialCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final initials = review.customerName.isEmpty
        ? 'C'
        : review.customerName[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                children: List.generate(5, (index) {
                  return const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.secondaryAccent,
                  );
                }),
              ),
              Icon(
                Icons.format_quote_rounded,
                size: 22,
                color: AppColors.secondaryAccent.withValues(alpha: 0.45),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Comment
          Expanded(
            child: Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sansBody(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Customer Profile Details
          Row(
            children: [
              // Avatar circle with initial
              Container(
                width: 28,
                height: 28,
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
                    fontSize: 11,
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
                    Text(
                      review.eventName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 9.5,
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
