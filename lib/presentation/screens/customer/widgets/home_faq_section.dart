import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/constants/app_images.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/core/services/business_details_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';
import 'package:om_event/domain/entities/business_details_entity.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/screens/customer/helpers/customer_dialog_helper.dart';
import 'package:om_event/core/utils/booking_communication_helper.dart';
import 'booking_tracker_dialog.dart';
import 'package:om_event/presentation/widgets/app_page_container.dart';

// ─── Main Unified FAQ Section with Separated Premium Footer ───────────────────
class FAQSection extends StatefulWidget {
  final bool isDesktop;
  final CatalogController? controller;
  final GlobalKey? contactKey;
  final GlobalKey? categoriesKey;
  final GlobalKey? catalogKey;
  final GlobalKey? storiesKey;

  const FAQSection({
    super.key,
    required this.isDesktop,
    this.controller,
    this.contactKey,
    this.categoriesKey,
    this.catalogKey,
    this.storiesKey,
  });

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  final Set<int> _expandedIndices = {};

  final List<String> _categories = [
    'ALL',
    'BOOKING',
    'PACKAGES',
    'LOCATION',
    'CANCELLATION',
    'DECORATION',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktopLayout = width >= 1024 && widget.isDesktop;
    final bool isTabletLayout = width >= 650 && width < 1024;
    final bool isMobileLayout = width < 650;

    return Container(
      width: double.infinity,
      color: const Color(0xFF152621), // Page background
      padding: EdgeInsets.symmetric(
        horizontal: AppPageContainer.horizontalPadding(context),
        vertical: isDesktopLayout ? 44.0 : 28.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppPageContainer.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SECTION 1: FAQ MAIN SHOWCASE (Target First Image) ─────────
              _buildFaqMainShowcase(
                context,
                isDesktop: isDesktopLayout,
                isTablet: isTabletLayout,
                isMobile: isMobileLayout,
              ),

              // ── VERTICAL GAP BETWEEN SECTIONS (40–64px desktop / 40px mobile)
              SizedBox(height: isDesktopLayout ? 56.0 : 40.0),

              // ── SECTION 2: PREMIUM FOOTER PANEL (Target Reference Image) ──
              _buildSeparateFooter(
                context,
                isDesktop: isDesktopLayout,
                isTablet: isTabletLayout,
                isMobile: isMobileLayout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: FAQ MAIN SHOWCASE (FIRST REFERENCE IMAGE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFaqMainShowcase(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
    required bool isMobile,
  }) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.08),
            blurRadius: 36,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background subtle gold flowing wave lines and sparkles
          Positioned.fill(
            child: CustomPaint(
              painter: _GoldWavesBackgroundPainter(),
            ),
          ),

          // Main Foreground Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32.0 : (isTablet ? 24.0 : 18.0),
              vertical: isDesktop ? 30.0 : (isTablet ? 24.0 : 20.0),
            ),
            child: Obx(() {
              final homepage = AppConfigService.to.rxHomepageSettings.value;
              final rawFaqs = homepage.faqs.isNotEmpty
                  ? homepage.faqs
                  : HomepageSettings.defaultVal().faqs;

              // Filter by category and search text
              final filteredFaqs = rawFaqs.where((faq) {
                final map = Map<String, dynamic>.from(faq);
                final q = (map['question'] ?? '').toString().toLowerCase();
                final a = (map['answer'] ?? '').toString().toLowerCase();
                final cat = (map['category'] ?? '').toString().toUpperCase();

                final matchesCategory = _selectedCategory == 'ALL' ||
                    cat == _selectedCategory ||
                    q.contains(_selectedCategory.toLowerCase());

                final matchesQuery = _searchQuery.isEmpty ||
                    q.contains(_searchQuery.toLowerCase()) ||
                    a.contains(_searchQuery.toLowerCase());

                return matchesCategory && matchesQuery;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP: Left Expanded Intro Content + Right 2-Col Grid ───
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: FAQ eyebrow, title, description, search, filters, support cards
                        Expanded(
                          flex: 48,
                          child: _buildLeftIntroColumn(isDesktop: true),
                        ),
                        const SizedBox(width: 32),

                        // Right: 2-Column Grid of FAQ cards matching First Image
                        Expanded(
                          flex: 52,
                          child: _buildRightFaqGrid(filteredFaqs, isDesktop: true),
                        ),
                      ],
                    )
                  else
                    // Mobile / Tablet Stacked Layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftIntroColumn(isDesktop: false),
                        const SizedBox(height: 26),
                        _buildRightFaqGrid(filteredFaqs, isDesktop: false),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // ── BOTTOM OF SECTION 1: Full-Width CTA Conversation Banner ──
                  _buildCtaBanner(context, isDesktop: isDesktop),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── LEFT INTRO COLUMN (WIDER & EXPANDED) ───────────────────────────────────
  Widget _buildLeftIntroColumn({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eyebrow badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.65),
              width: 1.0,
            ),
            color: const Color(0xFF0C1612),
          ),
          child: Text(
            "FAQ",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.2,
              color: AppColors.secondaryAccent,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Main Editorial Heading
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: isDesktop ? 36.0 : 26.0,
              fontWeight: FontWeight.w400,
              height: 1.08,
              letterSpacing: 0.6,
            ),
            children: [
              const TextSpan(
                text: "YOUR QUESTIONS,\n",
                style: TextStyle(color: Color(0xFFFAF7F0)),
              ),
              TextSpan(
                text: "OUR HONEST ANSWERS.",
                style: TextStyle(
                  color: AppColors.secondaryAccent,
                  shadows: [
                    Shadow(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          "Clear information so you can plan your celebration with confidence.",
          style: AppTheme.sansBody(
            fontSize: 12.5,
            color: const Color(0xFFBAC5C0),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),

        // Search Input (Wide, Clean, Elegant)
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1310),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.secondaryAccent.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Search questions...",
              hintStyle: AppTheme.sansBody(
                fontSize: 12.5,
                color: const Color(0xFF75857F),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 17,
                color: AppColors.secondaryAccent.withValues(alpha: 0.8),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: AppColors.secondaryAccent.withValues(alpha: 0.6),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category Filter Pills
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondaryAccent
                      : const Color(0xFF0C1612),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryAccent
                        : AppColors.secondaryAccent.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 0.8,
                    color: isSelected
                        ? const Color(0xFF060907)
                        : const Color(0xFFBAC5C0),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Support / Trust Feature Cards (4 Cards in a horizontal row on Desktop)
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildSupportCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: "Quick Answers",
                  description: "Get instant clarity for your doubts.",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSupportCard(
                  icon: Icons.settings_outlined,
                  title: "Plan Confidently",
                  description: "Know every detail before you book.",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSupportCard(
                  icon: Icons.shield_outlined,
                  title: "Transparent",
                  description: "No hidden terms or charges.",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSupportCard(
                  icon: Icons.headset_mic_outlined,
                  title: "Dedicated Support",
                  description: "We're here to help you anytime.",
                ),
              ),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSupportCard(
                icon: Icons.lightbulb_outline_rounded,
                title: "Quick Answers",
                description: "Get instant clarity for your doubts.",
                width: 140,
              ),
              _buildSupportCard(
                icon: Icons.settings_outlined,
                title: "Plan Confidently",
                description: "Know every detail before you book.",
                width: 140,
              ),
              _buildSupportCard(
                icon: Icons.shield_outlined,
                title: "Transparent",
                description: "No hidden terms or charges.",
                width: 140,
              ),
              _buildSupportCard(
                icon: Icons.headset_mic_outlined,
                title: "Dedicated Support",
                description: "We're here to help you anytime.",
                width: 140,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String description,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF09120E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondaryAccent.withValues(alpha: 0.6),
                width: 1.0,
              ),
              color: const Color(0xFF0F1E18),
            ),
            child: Icon(icon, size: 14, color: AppColors.secondaryAccent),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.sansBody(
              fontSize: 8.5,
              color: const Color(0xFF8E9E97),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── RIGHT FAQ AREA: 2-COLUMN GRID ──────────────────────────────────────────
  Widget _buildRightFaqGrid(List<dynamic> filteredFaqs, {required bool isDesktop}) {
    if (filteredFaqs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF09120E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.secondaryAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 34,
                color: AppColors.secondaryAccent.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 10),
              Text(
                "No questions match your search",
                style: GoogleFonts.italiana(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Try searching with different keywords or reset category filters.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 11.5,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'ALL';
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 15, color: AppColors.secondaryAccent),
                label: Text(
                  "Reset Filters",
                  style: AppTheme.sansBody(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      // 2-Column Responsive Layout matching First Reference Image
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < filteredFaqs.length; i += 2)
                  _buildFaqCard(filteredFaqs[i], i),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right Column
          Expanded(
            child: Column(
              children: [
                for (int i = 1; i < filteredFaqs.length; i += 2)
                  _buildFaqCard(filteredFaqs[i], i),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile / Tablet 1-Column Layout
    return Column(
      children: [
        for (int i = 0; i < filteredFaqs.length; i++)
          _buildFaqCard(filteredFaqs[i], i),
      ],
    );
  }

  // ── FAQ CARD ───────────────────────────────────────────────────────────────
  Widget _buildFaqCard(dynamic faq, int index) {
    final map = Map<String, dynamic>.from(faq);
    final question = (map['question'] ?? '').toString();
    final answer = (map['answer'] ?? '').toString();
    final category = map['category']?.toString();
    final isExpanded = _expandedIndices.contains(index);
    final icon = _getFaqIcon(question, category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF09120E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? AppColors.secondaryAccent.withValues(alpha: 0.6)
              : AppColors.secondaryAccent.withValues(alpha: 0.28),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedIndices.remove(index);
              } else {
                _expandedIndices.add(index);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Icon Badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryAccent.withValues(alpha: 0.6),
                          width: 1.1,
                        ),
                        color: const Color(0xFF0F1E18),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 15,
                        color: AppColors.secondaryAccent,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Question Text
                    Expanded(
                      child: Text(
                        question,
                        maxLines: isExpanded ? null : 2,
                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: AppTheme.sansBody(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Chevron Indicator
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                        color: AppColors.secondaryAccent,
                      ),
                    ),
                  ],
                ),

                // Expanded Answer Content
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: AppColors.secondaryAccent.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    answer,
                    style: AppTheme.sansBody(
                      fontSize: 11.5,
                      color: const Color(0xFFC0CAC5),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper mapping semantic questions to appropriate gold icons matching First Image
  IconData _getFaqIcon(String question, String? category) {
    final q = question.toLowerCase();

    // Contextual matching for the target questions from First Reference Image
    if (q.contains('advance')) return Icons.calendar_month_outlined;
    if (q.contains('24 hour') || q.contains('within 24')) return Icons.access_time_rounded;
    if (q.contains('handle per day') || q.contains('many events')) return Icons.people_outline_rounded;
    if (q.contains('date availability') || q.contains('check date')) return Icons.event_available_outlined;
    if (q.contains('basic, premium') || q.contains('luxury packages')) return Icons.inventory_2_outlined;
    if (q.contains('customize an existing') || q.contains('customize')) return Icons.settings_outlined;
    if (q.contains('reference image') || q.contains('send a reference')) return Icons.image_outlined;
    if (q.contains('which areas') || q.contains('areas do you serve')) return Icons.place_outlined;
    if (q.contains('travel charges') || q.contains('outstation')) return Icons.pin_drop_outlined;
    if (q.contains('how can i cancel') || q.contains('cancel a booking')) return Icons.cancel_outlined;
    if (q.contains('when can i request cancellation')) return Icons.event_busy_outlined;
    if (q.contains('what happens after i submit')) return Icons.description_outlined;
    if (q.contains('how do i track')) return Icons.calendar_today_outlined;
    if (q.contains('booking id')) return Icons.badge_outlined;
    if (q.contains('how will i know if my booking is accepted')) return Icons.check_circle_outline_rounded;
    if (q.contains('decoration only') || q.contains('complete event')) return Icons.celebration_outlined;
    if (q.contains('specific colors') || q.contains('thematic materials') || q.contains('colors')) return Icons.palette_outlined;

    // Fallbacks
    final cat = (category ?? '').toLowerCase();
    if (cat.contains('book')) return Icons.calendar_today_outlined;
    if (cat.contains('cancel')) return Icons.cancel_outlined;
    if (cat.contains('location')) return Icons.place_outlined;
    if (cat.contains('package')) return Icons.inventory_2_outlined;
    if (cat.contains('decor')) return Icons.celebration_outlined;
    return Icons.help_outline_rounded;
  }

  // ── COMPACT CTA BANNER (INSIDE SECTION 1) ──────────────────────────────────
  Widget _buildCtaBanner(BuildContext context, {required bool isDesktop}) {
    return Container(
      key: widget.contactKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.35),
          width: 1.1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Celebration Image
          Positioned.fill(
            child: Image.asset(
              AppImages.luxuryReception,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF050907).withValues(alpha: 0.95),
                    const Color(0xFF07100D).withValues(alpha: 0.88),
                    const Color(0xFF091410).withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),

          // Banner Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 30 : 18,
              vertical: isDesktop ? 20 : 16,
            ),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "PLANNING SOMETHING SPECIAL?",
                              style: AppTheme.sansBody(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.2,
                                color: AppColors.secondaryAccent,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Let’s make room for the unexpected.",
                              style: GoogleFonts.italiana(
                                fontSize: 23,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Tell us the dream, the venue, and the budget outline. We’ll compose a signature celebration together.",
                              style: AppTheme.sansBody(
                                fontSize: 11.5,
                                color: const Color(0xFFBAC5C0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Pill Button with Chevron matching First Image
                      InkWell(
                        onTap: () => CustomerDialogHelper.openLeadDialog(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryAccent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryAccent.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "START A CONVERSATION",
                                style: AppTheme.sansBody(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFF070C0A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFF070C0A),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PLANNING SOMETHING SPECIAL?",
                        style: AppTheme.sansBody(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.2,
                          color: AppColors.secondaryAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Let’s make room for the unexpected.",
                        style: GoogleFonts.italiana(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Tell us the dream, the venue, and the budget outline. We’ll compose a signature celebration together.",
                        style: AppTheme.sansBody(
                          fontSize: 11.0,
                          color: const Color(0xFFBAC5C0),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () => CustomerDialogHelper.openLeadDialog(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryAccent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "START A CONVERSATION",
                                style: AppTheme.sansBody(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFF070C0A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFF070C0A),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: SEPARATE PREMIUM FOOTER (TARGET FIRST REFERENCE IMAGE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSeparateFooter(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
    required bool isMobile,
  }) {
    final originalDetails = BusinessDetailsService.to.rxDetails.value;
    final contactSettings = AppConfigService.to.rxContactSettings.value;
    final businessProfile = AppConfigService.to.rxBusinessProfile.value;

    // Resolve branch addresses dynamically from canonical settings/business_info
    final List<String> branchLines = [];
    if (originalDetails.branches.isNotEmpty) {
      for (final b in originalDetails.branches) {
        if (b.branchName.isNotEmpty) {
          final addr = b.fullAddress.isNotEmpty ? b.fullAddress.split(',').first.trim() : '';
          branchLines.add(addr.isNotEmpty ? "${b.branchName} – $addr" : b.branchName);
        }
      }
    } else if (businessProfile.officeBranches.isNotEmpty) {
      for (final b in businessProfile.officeBranches) {
        if (b.branchName.isNotEmpty) {
          final addr = b.address.isNotEmpty ? b.address.split(',').first.trim() : '';
          branchLines.add(addr.isNotEmpty ? "${b.branchName} – $addr" : b.branchName);
        }
      }
    }
    if (branchLines.isEmpty) {
      branchLines.add("Kadi (Medha) – Medha (kadi-kalyanpura road)");
      branchLines.add("Thangadh – Thangadh (Surendranagar)");
      branchLines.add("Gujarat, India 382715");
    } else if (branchLines.length == 2) {
      branchLines.add("Gujarat, India 382715");
    }

    // Resolve phone numbers dynamically from canonical settings/business_info
    final List<String> candidatePhones = [];
    for (final p in originalDetails.contacts.phones) {
      if (p.value.trim().isNotEmpty) candidatePhones.add(p.value.trim());
    }
    for (final c in businessProfile.contactNumbers) {
      if (c.number.trim().isNotEmpty) candidatePhones.add(c.number.trim());
    }
    for (final b in originalDetails.branches) {
      if (b.phoneNumber.trim().isNotEmpty) candidatePhones.add(b.phoneNumber.trim());
    }
    for (final b in businessProfile.officeBranches) {
      if (b.phone1.trim().isNotEmpty) candidatePhones.add(b.phone1.trim());
      if (b.phone2.trim().isNotEmpty) candidatePhones.add(b.phone2.trim());
    }
    if (contactSettings.phone.isNotEmpty) {
      for (final p in contactSettings.phone.split(',')) {
        if (p.trim().isNotEmpty) candidatePhones.add(p.trim());
      }
    }

    final uniqueClean = <String>{};
    final uniqueRaw = <String>[];
    for (final p in candidatePhones) {
      final clean = p.replaceAll(RegExp(r'\D'), '');
      final ten = (clean.length == 12 && clean.startsWith('91')) ? clean.substring(2) : clean;
      if (ten.isNotEmpty && !uniqueClean.contains(ten)) {
        uniqueClean.add(ten);
        uniqueRaw.add(p);
      }
    }

    String rawPrimaryPhone = '';
    String rawSecondaryPhone = '';
    if (uniqueRaw.isNotEmpty) {
      final kadiIndex = uniqueRaw.indexWhere((p) => p.contains('93135'));
      if (kadiIndex != -1) {
        rawPrimaryPhone = uniqueRaw[kadiIndex];
        if (uniqueRaw.length > 1) {
          rawSecondaryPhone = uniqueRaw.firstWhere((p) => !p.contains('93135'));
        } else {
          rawSecondaryPhone = '+91 95121 49944';
        }
      } else {
        final thangadhIndex = uniqueRaw.indexWhere((p) => p.contains('95121'));
        if (thangadhIndex != -1) {
          rawSecondaryPhone = uniqueRaw[thangadhIndex];
          if (uniqueRaw.length > 1) {
            rawPrimaryPhone = uniqueRaw.firstWhere((p) => !p.contains('95121'));
          } else {
            rawPrimaryPhone = '+91 93135 13156';
          }
        } else {
          rawPrimaryPhone = uniqueRaw.first;
          rawSecondaryPhone = uniqueRaw.length > 1 ? uniqueRaw[1] : '+91 95121 49944';
        }
      }
    } else {
      rawPrimaryPhone = '+91 93135 13156';
      rawSecondaryPhone = '+91 95121 49944';
    }

    final String primaryPhone = BookingCommunicationHelper.formatDisplayPhone(rawPrimaryPhone);
    final String secondaryPhone = BookingCommunicationHelper.formatDisplayPhone(rawSecondaryPhone);

    // Resolve email dynamically from settings/business_info
    String primaryEmail = '';
    if (originalDetails.contacts.emails.isNotEmpty) {
      primaryEmail = originalDetails.contacts.emails.first.value.trim();
    } else if (businessProfile.email.isNotEmpty) {
      primaryEmail = businessProfile.email.trim();
    } else if (contactSettings.email.isNotEmpty) {
      primaryEmail = contactSettings.email.trim();
    }
    if (primaryEmail.isEmpty) {
      primaryEmail = 'omeventsanddecorators@gmail.com';
    }

    // Resolve location-specific Instagram URLs dynamically from settings/business_info
    String instagramKadi = originalDetails.social.instagramKadi.trim().isNotEmpty
        ? originalDetails.social.instagramKadi.trim()
        : (businessProfile.socialLinks['instagram_kadi']?.trim() ?? '');

    String instagramThangadh = originalDetails.social.instagramThangadh.trim().isNotEmpty
        ? originalDetails.social.instagramThangadh.trim()
        : (businessProfile.socialLinks['instagram_thangadh']?.trim() ?? '');

    if (instagramKadi.isEmpty || instagramThangadh.isEmpty) {
      for (final b in originalDetails.branches) {
        final lower = b.branchName.toLowerCase();
        if (b.instagram.trim().isNotEmpty) {
          if (lower.contains('kadi') && instagramKadi.isEmpty) {
            instagramKadi = b.instagram.trim();
          } else if (lower.contains('thangadh') && instagramThangadh.isEmpty) {
            instagramThangadh = b.instagram.trim();
          }
        }
      }
    }

    if (instagramKadi.isEmpty) {
      instagramKadi = originalDetails.social.instagram.trim().isNotEmpty
          ? originalDetails.social.instagram.trim()
          : "https://instagram.com/omevents_kadi";
    }
    if (instagramThangadh.isEmpty) {
      instagramThangadh = originalDetails.social.instagram.trim().isNotEmpty
          ? originalDetails.social.instagram.trim()
          : "https://instagram.com/omevents_thangadh";
    }

    final String generalInstaUrl = instagramKadi.isNotEmpty
        ? instagramKadi
        : (instagramThangadh.isNotEmpty
            ? instagramThangadh
            : (originalDetails.social.instagram.trim().isNotEmpty
                ? originalDetails.social.instagram.trim()
                : "https://instagram.com"));

    void safeLaunch(String url) async {
      if (url.isEmpty) return;
      try {
        final target = (url.startsWith('http://') ||
                url.startsWith('https://') ||
                url.startsWith('tel:') ||
                url.startsWith('mailto:'))
            ? url
            : 'https://$url';
        await launchUrlString(target, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    // Enclosed premium panel container matching Second Reference Image (Option 2 Modern Card Style)
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060907),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Foreground Content Columns (flex controlled) ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22.0, 16.0, 12.0, 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. BRAND (flex: 32)
                          Expanded(
                            flex: 32,
                            child: _buildBrandBlock(
                              context,
                              originalDetails,
                              businessProfile,
                              contactSettings,
                              generalInstaUrl,
                              safeLaunch,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 2. EXPLORE (flex: 12)
                          Expanded(
                            flex: 12,
                            child: _buildExploreColumn(),
                          ),
                          const SizedBox(width: 12),

                          // 3. HELP (flex: 12)
                          Expanded(
                            flex: 12,
                            child: _buildHelpColumn(context),
                          ),
                          const SizedBox(width: 12),

                          // Subtle Vertical Divider 1
                          _buildVerticalDivider(),
                          const SizedBox(width: 12),

                          // 4. VISIT US (flex: 20)
                          Expanded(
                            flex: 20,
                            child: _buildVisitUsColumn(branchLines),
                          ),
                          const SizedBox(width: 12),

                          // Subtle Vertical Divider 2
                          _buildVerticalDivider(),
                          const SizedBox(width: 12),

                          // 5. GET IN TOUCH (flex: 24)
                          Expanded(
                            flex: 24,
                            child: _buildGetInTouchColumn(
                              primaryPhone,
                              secondaryPhone,
                              primaryEmail,
                              instagramKadi,
                              instagramThangadh,
                              safeLaunch,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Integrated Far-Right Decorative Event Image (~140px, ~12% width) ──
                  SizedBox(
                    width: 140,
                    child: _buildDecorativeImageLayer(width: 140),
                  ),
                ],
              ),
            )
          : isTablet
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandBlock(
                        context,
                        originalDetails,
                        businessProfile,
                        contactSettings,
                        generalInstaUrl,
                        safeLaunch,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        height: 1,
                        color: AppColors.secondaryAccent.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 12, child: _buildExploreColumn()),
                          const SizedBox(width: 10),
                          Expanded(flex: 12, child: _buildHelpColumn(context)),
                          const SizedBox(width: 12),
                          _buildVerticalDivider(),
                          const SizedBox(width: 12),
                          Expanded(flex: 22, child: _buildVisitUsColumn(branchLines)),
                          const SizedBox(width: 12),
                          _buildVerticalDivider(),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 26,
                            child: _buildGetInTouchColumn(
                              primaryPhone,
                              secondaryPhone,
                              primaryEmail,
                              instagramKadi,
                              instagramThangadh,
                              safeLaunch,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            height: 140,
                            child: _buildDecorativeImageLayer(width: 120),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBrandBlock(
                            context,
                            originalDetails,
                            businessProfile,
                            contactSettings,
                            generalInstaUrl,
                            safeLaunch,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1,
                            color: AppColors.secondaryAccent.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 24,
                            runSpacing: 20,
                            children: [
                              SizedBox(width: 140, child: _buildExploreColumn()),
                              SizedBox(width: 140, child: _buildHelpColumn(context)),
                              SizedBox(width: double.infinity, child: _buildVisitUsColumn(branchLines)),
                              SizedBox(
                                width: double.infinity,
                                child: _buildGetInTouchColumn(
                                  primaryPhone,
                                  secondaryPhone,
                                  primaryEmail,
                                  instagramKadi,
                                  instagramThangadh,
                                  safeLaunch,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Decorative image as a separate visual block at the bottom on mobile
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                      child: SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              AppImages.luxuryEveningDecor,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF060907),
                                    const Color(0xFF060907).withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.40, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // ── INTEGRATED DECORATIVE EVENT IMAGE (OPTION 2 STYLE) ─────────────────────
  Widget _buildDecorativeImageLayer({double width = 250}) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Luxury Evening Decor Photo (Warm candlelit floral canopy setup at night)
            Image.asset(
              AppImages.luxuryEveningDecor,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            // Smooth Vignette & Gradient Mask on Left Edge
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF060907),
                    const Color(0xFF060907).withValues(alpha: 0.85),
                    const Color(0xFF060907).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.28, 0.60, 0.90],
                ),
              ),
            ),
            // Sweeping Champagne-Gold Curved Lines
            CustomPaint(
              painter: _RightImageGoldCurvePainter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 105,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: AppColors.secondaryAccent.withValues(alpha: 0.16),
    );
  }

  // ── BRAND BLOCK (COLUMN 1) ──────────────────────────────────────────────────
  Widget _buildBrandBlock(
    BuildContext context,
    BusinessDetailsEntity originalDetails,
    BusinessProfile businessProfile,
    ContactSettings contactSettings,
    String generalInstaUrl,
    void Function(String) safeLaunch,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LET'S CREATE SOMETHING EXTRAORDINARY",
          style: AppTheme.sansBody(
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8,
            color: AppColors.secondaryAccent,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
            children: [
              const TextSpan(
                text: "Moments pass.\n",
                style: TextStyle(color: Color(0xFFFAF7F0)),
              ),
              TextSpan(
                text: "Beautiful ones echo.",
                style: TextStyle(
                  color: AppColors.secondaryAccent,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "From intimate gatherings to grand celebrations, we turn your vision into unforgettable experiences.",
          style: AppTheme.sansBody(
            fontSize: 10.0,
            color: const Color(0xFFBAC5C0),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        // CTA Button & Social Icons on the exact same row (matching Image 2)
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Start a Conversation CTA
              InkWell(
                onTap: () => CustomerDialogHelper.openLeadDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.30),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "START A CONVERSATION",
                        style: AppTheme.sansBody(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: const Color(0xFF070C0A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 11,
                        color: Color(0xFF070C0A),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Social Icons Row (Matching Image 2)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _socialIconButton(
                    icon: Icons.camera_alt_outlined,
                    onTap: () => safeLaunch(generalInstaUrl),
                  ),
                  const SizedBox(width: 4),
                  _socialIconButton(
                    icon: Icons.facebook_rounded,
                    onTap: () => safeLaunch(
                      originalDetails.social.facebook.isNotEmpty
                          ? originalDetails.social.facebook
                          : "https://facebook.com",
                    ),
                  ),
                  const SizedBox(width: 4),
                  _socialIconButton(
                    icon: Icons.play_arrow_rounded,
                    onTap: () => safeLaunch(
                      originalDetails.social.youtube.isNotEmpty
                          ? originalDetails.social.youtube
                          : "https://youtube.com",
                    ),
                  ),
                  const SizedBox(width: 4),
                  _socialIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      final wa = businessProfile.whatsapp.isNotEmpty
                          ? businessProfile.whatsapp
                          : contactSettings.whatsapp;
                      safeLaunch(wa.isNotEmpty ? "https://wa.me/$wa" : "https://whatsapp.com");
                    },
                  ),
                  const SizedBox(width: 4),
                  _socialIconButton(
                    icon: Icons.business_center_outlined,
                    onTap: () {
                      final site = originalDetails.social.website.isNotEmpty
                          ? originalDetails.social.website
                          : "https://linkedin.com";
                      safeLaunch(site);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── EXPLORE COLUMN ──────────────────────────────────────────────────────────
  Widget _buildExploreColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerHeading("EXPLORE"),
        const SizedBox(height: 9),
        _footerLink("Collections", () {
          final ctx = widget.categoriesKey?.currentContext;
          if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }),
        _footerLink("Experiences", () {
          final ctx = widget.catalogKey?.currentContext;
          if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }),
        _footerLink("Event Gallery", () => Get.toNamed(AppRoutes.gallery)),
        _footerLink("Service Areas", () => Get.toNamed(AppRoutes.serviceArea)),
        _footerLink("Booking Policy", () => Get.toNamed(AppRoutes.bookingPolicy)),
      ],
    );
  }

  // ── HELP COLUMN ─────────────────────────────────────────────────────────────
  Widget _buildHelpColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerHeading("HELP"),
        const SizedBox(height: 9),
        _footerLink("Cancellation Policy", () => Get.toNamed(AppRoutes.cancellationPolicy)),
        _footerLink("Contact & Studios", () => Get.toNamed(AppRoutes.contact)),
        _footerLink("Stories", () {
          final ctx = widget.storiesKey?.currentContext;
          if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }),
        _footerLink("Track Booking", () => showBookingTrackerDialog(context)),
        _footerLink("FAQ", () {}),
      ],
    );
  }

  // ── VISIT US COLUMN ─────────────────────────────────────────────────────────
  Widget _buildVisitUsColumn(List<String> branchLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerHeading("VISIT US"),
        const SizedBox(height: 9),
        for (int i = 0; i < branchLines.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 5.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i < 2) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 1.5, right: 6.0),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 13.0,
                      color: AppColors.secondaryAccent,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 19.0),
                ],
                Expanded(
                  child: Text(
                    branchLines[i],
                    style: AppTheme.sansBody(
                      fontSize: 10.5,
                      color: const Color(0xFFBAC5C0),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── GET IN TOUCH COLUMN ─────────────────────────────────────────────────────
  Widget _buildGetInTouchColumn(
    String primaryPhone,
    String secondaryPhone,
    String primaryEmail,
    String instagramKadi,
    String instagramThangadh,
    void Function(String) safeLaunch,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerHeading("GET IN TOUCH"),
        const SizedBox(height: 9),

        // 1. Primary phone
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 12.5,
                color: AppColors.secondaryAccent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _FooterHoverLink(
                  title: primaryPhone,
                  allowWrap: true,
                  onTap: () => safeLaunch("tel:${primaryPhone.replaceAll(RegExp(r'\s+'), '')}"),
                ),
              ),
            ],
          ),
        ),

        // 2. Secondary phone
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 12.5,
                color: AppColors.secondaryAccent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _FooterHoverLink(
                  title: secondaryPhone,
                  allowWrap: true,
                  onTap: () => safeLaunch("tel:${secondaryPhone.replaceAll(RegExp(r'\s+'), '')}"),
                ),
              ),
            ],
          ),
        ),

        // 3. Support Email (Must wrap naturally if required, never truncated, no ellipsis)
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 12.5,
                color: AppColors.secondaryAccent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _FooterHoverLink(
                  title: primaryEmail,
                  allowWrap: true,
                  onTap: () => safeLaunch("mailto:$primaryEmail"),
                ),
              ),
            ],
          ),
        ),

        // 4. Instagram – Kadi
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 12.5,
                color: AppColors.secondaryAccent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _FooterHoverLink(
                  title: "Instagram – Kadi ↗",
                  allowWrap: true,
                  onTap: () => safeLaunch(instagramKadi),
                ),
              ),
            ],
          ),
        ),

        // 5. Instagram – Thangadh
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 12.5,
                color: AppColors.secondaryAccent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _FooterHoverLink(
                  title: "Instagram – Thangadh ↗",
                  allowWrap: true,
                  onTap: () => safeLaunch(instagramThangadh),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _footerHeading(String title) {
    return Text(
      title,
      style: AppTheme.sansBody(
        fontSize: 10.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.6,
        color: AppColors.secondaryAccent,
      ),
    );
  }

  Widget _footerLink(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.5),
      child: _FooterHoverLink(
        title: title,
        onTap: onTap,
      ),
    );
  }

  Widget _socialIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.secondaryAccent.withValues(alpha: 0.5),
            width: 0.9,
          ),
          color: const Color(0xFF0B1410),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 11, color: AppColors.secondaryAccent),
      ),
    );
  }
}

class _FooterHoverLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final bool allowWrap;

  const _FooterHoverLink({
    required this.title,
    required this.onTap,
    this.allowWrap = false,
  });

  @override
  State<_FooterHoverLink> createState() => _FooterHoverLinkState();
}

class _FooterHoverLinkState extends State<_FooterHoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.title,
          maxLines: widget.allowWrap ? null : 1,
          overflow: widget.allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
          softWrap: true,
          style: AppTheme.sansBody(
            fontSize: 11.0,
            color: const Color(0xFFBAC5C0),
            height: 1.38,
          ).copyWith(
            color: _isHovered ? AppColors.secondaryAccent : const Color(0xFFBAC5C0),
          ),
        ),
      ),
    );
  }
}

// ── Background Gold Waves & Particle Painter (Matching First Reference Image) ──
class _GoldWavesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const goldColor = Color(0xFFD4AF37);

    // ── 1. TOP FLOWING GOLD WAVES ──────────────────────────────────────────
    final topPaint1 = Paint()
      ..color = goldColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final topPath1 = Path();
    topPath1.moveTo(0, size.height * 0.14);
    topPath1.cubicTo(
      size.width * 0.10,
      size.height * 0.03,
      size.width * 0.22,
      size.height * 0.10,
      size.width * 0.40,
      size.height * 0.02,
    );
    canvas.drawPath(topPath1, topPaint1);

    final topPaint2 = Paint()
      ..color = goldColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final topPath2 = Path();
    topPath2.moveTo(0, size.height * 0.20);
    topPath2.cubicTo(
      size.width * 0.12,
      size.height * 0.07,
      size.width * 0.25,
      size.height * 0.14,
      size.width * 0.44,
      size.height * 0.05,
    );
    canvas.drawPath(topPath2, topPaint2);

    final topPaint3 = Paint()
      ..color = goldColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final topPath3 = Path();
    topPath3.moveTo(0, size.height * 0.26);
    topPath3.cubicTo(
      size.width * 0.14,
      size.height * 0.11,
      size.width * 0.28,
      size.height * 0.18,
      size.width * 0.48,
      size.height * 0.08,
    );
    canvas.drawPath(topPath3, topPaint3);

    // ── 2. BOTTOM FLOWING GOLD WAVES ───────────────────────────────────────
    final bottomPaint1 = Paint()
      ..color = goldColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bottomPath1 = Path();
    bottomPath1.moveTo(0, size.height * 0.68);
    bottomPath1.cubicTo(
      size.width * 0.08,
      size.height * 0.74,
      size.width * 0.22,
      size.height * 0.66,
      size.width * 0.40,
      size.height * 0.75,
    );
    canvas.drawPath(bottomPath1, bottomPaint1);

    final bottomPaint2 = Paint()
      ..color = goldColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bottomPath2 = Path();
    bottomPath2.moveTo(0, size.height * 0.74);
    bottomPath2.cubicTo(
      size.width * 0.10,
      size.height * 0.79,
      size.width * 0.25,
      size.height * 0.71,
      size.width * 0.45,
      size.height * 0.79,
    );
    canvas.drawPath(bottomPath2, bottomPaint2);

    // Bottom-right waves
    final bottomPathRight1 = Path();
    bottomPathRight1.moveTo(size.width * 0.65, size.height * 0.76);
    bottomPathRight1.cubicTo(
      size.width * 0.76,
      size.height * 0.70,
      size.width * 0.88,
      size.height * 0.77,
      size.width,
      size.height * 0.72,
    );
    canvas.drawPath(bottomPathRight1, bottomPaint1);

    final bottomPathRight2 = Path();
    bottomPathRight2.moveTo(size.width * 0.60, size.height * 0.79);
    bottomPathRight2.cubicTo(
      size.width * 0.73,
      size.height * 0.74,
      size.width * 0.85,
      size.height * 0.80,
      size.width,
      size.height * 0.76,
    );
    canvas.drawPath(bottomPathRight2, bottomPaint2);

    // ── 3. SUBTLE GOLD SPARKLES / PARTICLES ─────────────────────────────────
    void drawSparkle(double x, double y, double sizeRadius, double alpha) {
      final glowPaint = Paint()
        ..color = goldColor.withValues(alpha: alpha * 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), sizeRadius * 4.0, glowPaint);

      final corePaint = Paint()
        ..color = const Color(0xFFFFF9E0).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), sizeRadius, corePaint);
    }

    drawSparkle(size.width * 0.20, size.height * 0.05, 1.4, 0.65);
    drawSparkle(size.width * 0.32, size.height * 0.08, 1.1, 0.45);
    drawSparkle(size.width * 0.06, size.height * 0.70, 1.5, 0.7);
    drawSparkle(size.width * 0.36, size.height * 0.74, 1.3, 0.6);
    drawSparkle(size.width * 0.82, size.height * 0.73, 1.4, 0.55);
    drawSparkle(size.width * 0.94, size.height * 0.76, 1.1, 0.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Right Decorative Image Sweeping Gold Curved Line ──────────────────────────
class _RightImageGoldCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Primary glowing gold line
    final glowPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final paint1 = Paint()
      ..color = const Color(0xFFE5C158).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path1 = Path();
    path1.moveTo(size.width * 0.38, 0);
    path1.cubicTo(
      size.width * 0.22,
      size.height * 0.18,
      size.width * 0.04,
      size.height * 0.45,
      size.width * 0.03,
      size.height * 0.72,
    );
    path1.cubicTo(
      size.width * 0.02,
      size.height * 0.88,
      size.width * 0.15,
      size.height * 0.98,
      size.width * 0.38,
      size.height,
    );
    canvas.drawPath(path1, glowPaint);
    canvas.drawPath(path1, paint1);

    // Secondary parallel gold line
    final paint2 = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final path2 = Path();
    path2.moveTo(size.width * 0.46, 0);
    path2.cubicTo(
      size.width * 0.28,
      size.height * 0.20,
      size.width * 0.10,
      size.height * 0.46,
      size.width * 0.09,
      size.height * 0.70,
    );
    path2.cubicTo(
      size.width * 0.08,
      size.height * 0.85,
      size.width * 0.20,
      size.height * 0.96,
      size.width * 0.45,
      size.height,
    );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
