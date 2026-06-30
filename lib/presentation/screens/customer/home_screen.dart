import 'dart:async' as dart_async;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/config/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/experience.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/quotation_controller.dart';
import '../../widgets/item_visual_placeholder.dart';

class HomeScreen extends GetView<CatalogController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final quoteController = Get.find<QuotationController>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Section Scroll Keys
    final categoriesKey = GlobalKey();
    final catalogKey = GlobalKey();
    final storiesKey = GlobalKey();
    final contactKey = GlobalKey();

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 700 && width < 1000;

    void scrollToSection(GlobalKey key) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      drawer: isDesktop
          ? null
          : _NavDrawer(
              categoriesKey: categoriesKey,
              catalogKey: catalogKey,
              storiesKey: storiesKey,
              contactKey: contactKey,
            ),
      endDrawer: _CartDrawer(
        cartController: cartController,
        quoteController: quoteController,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _AnnouncementBanner(isDesktop: isDesktop),
          ),
          // Responsive AppBar
          SliverAppBar(
            floating: true,
            pinned: true,
            toolbarHeight: 76,
            backgroundColor: isDark ? const Color(0xFF101C18) : const Color(0xFFFAF8F5),
            leading: isDesktop
                ? null
                : IconButton(
                    icon: Icon(Icons.menu, color: isDark ? Colors.white : const Color(0xFF17201E)),
                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                  ),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white : const Color(0xFF17201E), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "OE",
                      style: AppTheme.serifHeader(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF17201E), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "OM EVENTS",
                      style: AppTheme.serifHeader(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF17201E), fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    Text(
                      "MAKE IT MEMORABLE",
                      style: AppTheme.sansBody(fontSize: 6, color: isDark ? Colors.white70 : const Color(0xFF1E2B27), fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
                if (isDesktop) ...[
                  const Spacer(),
                  _navLink(context, "Collections", () => scrollToSection(categoriesKey)),
                  _navLink(context, "Experiences", () => scrollToSection(catalogKey)),
                  _navLink(context, "Stories", () => scrollToSection(storiesKey)),
                  _navLink(context, "Contact", () => scrollToSection(contactKey)),
                  _navLink(context, "Developer API", () => Get.toNamed(AppRoutes.docs)),
                ],
              ],
            ),
            actions: [
              const SizedBox(width: 8),
              Obx(() {
                final count = cartController.rxCartItems.length;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openEndDrawer(),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Selection",
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: isDark ? Colors.white : const Color(0xFF17201E),
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : const Color(0xFF1E2B27),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$count',
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                color: isDark ? const Color(0xFF1B2925) : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 14),
              if (isDesktop)
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  child: Text(
                    "TEAM STUDIO",
                    style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFFD3AD7B), fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                )
              else
                IconButton(
                  icon: Icon(Icons.admin_panel_settings_outlined, color: isDark ? Colors.white : const Color(0xFF17201E)),
                  onPressed: () => Get.toNamed(AppRoutes.login),
                ),
              const SizedBox(width: 16),
            ],
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(scaffoldKey: scaffoldKey, isDesktop: isDesktop),
                const _MarqueeRibbon(),
                _BenefitsSection(isDesktop: isDesktop),
                _CategoriesSection(
                  controller: controller,
                  categoriesKey: categoriesKey,
                  catalogKey: catalogKey,
                ),
                _ExperiencesCatalogSection(
                  controller: controller,
                  cartController: cartController,
                  catalogKey: catalogKey,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
                _VideoStoriesSection(
                  storiesKey: storiesKey,
                  isDesktop: isDesktop,
                  catalogKey: catalogKey,
                ),
                _ProcessSection(isDesktop: isDesktop),
                _AnimatedStatsBand(isDesktop: isDesktop),

                _FAQSection(isDesktop: isDesktop),
                _ContactSection(controller: controller, contactKey: contactKey, isDesktop: isDesktop),
                _FooterSection(
                  isDesktop: isDesktop,
                  categoriesKey: categoriesKey,
                  catalogKey: catalogKey,
                  storiesKey: storiesKey,
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final uri = Uri.parse("https://wa.me/${AppConstants.businessPhone}?text=${Uri.encodeComponent(AppConstants.whatsappMessage)}");
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        backgroundColor: const Color(0xFF2C9B5D),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(
          "WHATSAPP US",
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            color: isDark ? Colors.white70 : const Color(0xFF17201E),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// 1. HERO SECTION

class _HeroBackgroundPainter extends CustomPainter {
  final bool isDark;
  const _HeroBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // A. Base linear gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        isDark
            ? [const Color(0xFF101C18), const Color(0xFF273A34), const Color(0xFF755F49)]
            : [const Color(0xFFFAF8F5), const Color(0xFFEBE6DD)],
        [0.0, 0.52, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (isDark) {
      // B. orb-one (amber glowing circle top right)
      final orb1Paint = Paint()
        ..color = const Color(0xFFC3925D).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
      canvas.drawCircle(Offset(size.width + 100, 240), 240, orb1Paint);

      // C. orb-two (border-only circle center bottom)
      final orb2Paint = Paint()
        ..color = const Color(0xFFD0AE84).withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(size.width * 0.35, size.height + 30), 150, orb2Paint);
    }

    // D. Dot Grid Overlay (24px spacing)
    final dotPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)
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

class _HeroSection extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;

  const _HeroSection({
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
            child: CustomPaint(
              painter: _HeroBackgroundPainter(isDark: isDark),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 24,
              vertical: isDesktop ? 100 : 60,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 11,
                            child: _HeroContent(scaffoldKey: scaffoldKey),
                          ),
                          const SizedBox(width: 64),
                          const Expanded(
                            flex: 9,
                            child: HeroStageArch(),
                          ),
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
    final goldSecondary = isDark ? AppTheme.darkGoldSecondary : AppTheme.lightGoldSecondary;

    final double titleSize = width >= 700 ? (width * 0.065).clamp(60.0, 108.0) : 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BESPOKE EVENT DESIGN • AHMEDABAD",
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
            children: [
              const TextSpan(text: "Celebrations,\n"),
              TextSpan(
                text: "thoughtfully",
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: goldSecondary,
                ),
              ),
              const TextSpan(text: " composed."),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "From the first sketch to the final flower, create an experience that feels unmistakably yours—with transparent prices from the start.",
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
              onPressed: () => _openLeadDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 38),
        Row(
          children: [
            _trustLabel("4.9 ★ Google Rating", isDark),
            _divider(isDark),
            _trustLabel("650+ Celebrations", isDark),
            _divider(isDark),
            _trustLabel("8 Years of Wonder", isDark),
          ],
        )
      ],
    );
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

    return Container(
      height: 500,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(
                painter: StageArchPainter(),
              ),
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
                    "Ivory Vow",
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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                width: 170,
                decoration: const BoxDecoration(
                  color: Color(0xEBF4F0E8),
                ),
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
  }
}

class StageArchPainter extends CustomPainter {
  const StageArchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background linear gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          Colors.white.withValues(alpha: 0.09),
          Colors.black.withValues(alpha: 0.14),
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Warm gold glow overlay at (50% w, 32% h)
    final glowCenter = Offset(size.width * 0.5, size.height * 0.32);
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        glowCenter,
        size.width * 0.37,
        [
          const Color(0x7BF3D6AB), // rgba(243,214,171,.48)
          Colors.transparent,
        ],
      );
    canvas.drawCircle(glowCenter, size.width * 0.37, glowPaint);

    // 3. Black gradient from bottom
    final bottomPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, size.height),
        Offset(size.width * 0.5, size.height * 0.45),
        [
          const Color(0xCC080D0B), // rgba(8,13,11,.8)
          Colors.transparent,
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55), bottomPaint);

    // 4. Draw Arches
    final archPaintOuter = Paint()
      ..color = const Color(0xB2EDCB9B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final outerW = size.width * 0.76;
    final outerH = size.height * 0.70;
    final outerL = size.width * 0.12;
    final outerRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(outerL, size.height - outerH, outerW, outerH + 20),
      topLeft: Radius.circular(outerW / 2),
      topRight: Radius.circular(outerW / 2),
    );
    canvas.drawRRect(outerRRect, archPaintOuter);

    final innerW = size.width * 0.58;
    final innerH = size.height * 0.58;
    final innerL = size.width * 0.21;
    final innerRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(innerL, size.height - innerH, innerW, innerH + 20),
      topLeft: Radius.circular(innerW / 2),
      topRight: Radius.circular(innerW / 2),
    );
    canvas.drawRRect(innerRRect, archPaintOuter);

    // 5. Draw Bulbs
    void drawBulb(Offset center) {
      // Glow underlay
      final bulbGlow = Paint()
        ..color = const Color(0x33E7D4B8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, 40.0, bulbGlow);

      final radialGlow = Paint()
        ..shader = ui.Gradient.radial(
          center,
          35.0,
          [
            const Color(0xFFE7D4B8),
            const Color(0xFFC2A279),
            Colors.transparent,
          ],
          [
            0.20,
            0.40,
            0.42,
          ],
        );
      canvas.drawCircle(center, 35.0, radialGlow);
    }

    // Outer arch bulbs
    drawBulb(Offset(outerL, size.height - outerH + outerH * 0.30));
    drawBulb(Offset(outerL + outerW, size.height - outerH + outerH * 0.14));

    // Inner arch bulbs
    drawBulb(Offset(innerL, size.height - innerH + innerH * 0.30));
    drawBulb(Offset(innerL + innerW, size.height - innerH + innerH * 0.14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. MARQUEE RIBBON
class _MarqueeRibbon extends StatefulWidget {
  const _MarqueeRibbon();

  @override
  State<_MarqueeRibbon> createState() => _MarqueeRibbonState();
}

class _MarqueeRibbonState extends State<_MarqueeRibbon> {
  late ScrollController _scrollController;
  dart_async.Timer? _timer;

  final List<String> _marqueeItems = [
    "Weddings",
    "Birthdays",
    "Baby Showers",
    "Proposals",
    "Brand Launches",
    "Grand Entries",
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    const speed = 0.8; // Pixels per tick
    _timer = dart_async.Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        final next = current + speed;
        if (next >= max) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(next);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF101C18) : const Color(0xFFFAF8F5);
    final borderColor = isDark ? const Color(0xFF1D2A26) : const Color(0xFFE5DFD5);

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Center(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = _marqueeItems[index % _marqueeItems.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 24),
                Text(
                  item.toUpperCase(),
                  style: GoogleFonts.italiana(
                    fontSize: 20,
                    color: isDark ? const Color(0xFFFAF8F5) : const Color(0xFF17201E),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 24),
                const Text(
                  "✦",
                  style: TextStyle(
                    color: Color(0xFFD6B080),
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// 3. BENEFITS
class _BenefitsSection extends StatefulWidget {
  final bool isDesktop;
  const _BenefitsSection({required this.isDesktop});

  @override
  State<_BenefitsSection> createState() => _BenefitsSectionState();
}

class _BenefitsSectionState extends State<_BenefitsSection> {
  final List<Map<String, String>> cardsData = [
    {
      'icon': '◇',
      'title': 'Personal design',
      'desc': 'A concept shaped around your story, venue and budget—not a fixed package.',
    },
    {
      'icon': '₹',
      'title': 'Clear live pricing',
      'desc': 'Build your selection and see every charge before you send an enquiry.',
    },
    {
      'icon': '⌁',
      'title': 'One accountable team',
      'desc': 'Design, production, installation and teardown stay under one roof.',
    },
    {
      'icon': '✓',
      'title': 'Venue-ready planning',
      'desc': 'Timelines, access, power and installation details checked well in advance.',
    },
    {
      'icon': '✦',
      'title': 'Premium execution',
      'desc': 'Purposeful materials, careful finishing and a crew that respects the space.',
    },
    {
      'icon': '◌',
      'title': 'Calm on event day',
      'desc': 'A dedicated coordinator keeps the moving parts invisible to you.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 1000 ? 3 : (width >= 700 ? 2 : 1);
    final double hPad = width >= 1000 ? 110.0 : 24.0;
    final double titleSize = widget.isDesktop ? (width * 0.044).clamp(42.0, 67.0) : 36.0;

    List<Widget> cards = cardsData.map((data) {
      return _BenefitCard(icon: data['icon']!, title: data['title']!, description: data['desc']!);
    }).toList();

    Widget gridWidget;
    if (crossAxisCount == 3) {
      gridWidget = Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[3]),
              const SizedBox(width: 16),
              Expanded(child: cards[4]),
              const SizedBox(width: 16),
              Expanded(child: cards[5]),
            ],
          ),
        ],
      );
    } else if (crossAxisCount == 2) {
      gridWidget = Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
          ]),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 16),
            Expanded(child: cards[3]),
          ]),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: cards[4]),
            const SizedBox(width: 16),
            Expanded(child: cards[5]),
          ]),
        ],
      );
    } else {
      gridWidget = Column(
        children: cards.expand((c) => [c, const SizedBox(height: 16)]).toList()..removeLast(),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A2420),
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: widget.isDesktop ? 105 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eyebrow
              Text(
                "WHY CELEBRATE WITH US",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  color: const Color(0xFFD6B080),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 20),
              // Large 2-line heading
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.italiana(
                    fontSize: titleSize,
                    color: const Color(0xFFF2EEE6),
                    height: 1.0,
                  ),
                  children: const [
                    TextSpan(text: "Everything your event needs.\n"),
                    TextSpan(
                      text: "One thoughtful team.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFD3AD7B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Subtext with "More" in gold
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.sansBody(
                    fontSize: 14,
                    color: const Color(0xFF6D746F),
                    height: 1.7,
                  ),
                  children: [
                    const TextSpan(text: "Less chasing vendors. "),
                    TextSpan(
                      text: "More",
                      style: AppTheme.sansBody(
                        fontSize: 14,
                        color: const Color(0xFFD3AD7B),
                      ),
                    ),
                    const TextSpan(text: " time being present."),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              gridWidget,
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(30),
        constraints: const BoxConstraints(minHeight: 190),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2C27),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFAA7C4B) // gold on hover
                : const Color(0xFF243028),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 45,
                    offset: const Offset(0, 18),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold circle icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFAA7C4B),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: GoogleFonts.italiana(
                    fontSize: 20,
                    color: const Color(0xFFAA7C4B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              widget.title,
              style: GoogleFonts.italiana(
                fontSize: 22,
                color: const Color(0xFFF2EEE6),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 7),
            // Description
            Text(
              widget.description,
              style: AppTheme.sansBody(
                fontSize: 12,
                color: const Color(0xFF6D746F),
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// EXPERIENCE DETAIL DIALOG  (matches Django website's modal)
// ──────────────────────────────────────────────────────────
void _showExperienceDetailDialog(BuildContext context, Experience item) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.70),
    builder: (_) => _ExperienceDetailDialog(item: item),
  );
}

class _ExperienceDetailDialog extends StatefulWidget {
  final Experience item;
  const _ExperienceDetailDialog({required this.item});

  @override
  State<_ExperienceDetailDialog> createState() => _ExperienceDetailDialogState();
}

class _ExperienceDetailDialogState extends State<_ExperienceDetailDialog> {
  final _notesController = TextEditingController();
  String _selectedColor = '';
  String _selectedTheme = '';

  @override
  void initState() {
    super.initState();
    if (widget.item.colors.isNotEmpty) _selectedColor = widget.item.colors.first;
    if (widget.item.themes.isNotEmpty) _selectedTheme = widget.item.themes.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildImage(String url, String title, String categorySlug, String categoryName) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName);
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final item = widget.item;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width >= 800;

    // Dialog max width and max height
    final dialogWidth = (width * 0.9).clamp(320.0, 940.0);
    final dialogMaxHeight = height * 0.92;

    // Price info
    final hasDiscount = item.offerPrice != null && item.price > item.effectivePrice;
    final discountPct = hasDiscount
        ? ((1 - item.effectivePrice / item.price) * 100).round()
        : 0;
    final savedAmount = item.price - item.effectivePrice;

    Widget rightPanel = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category eyebrow
          Text(
            "${item.categoryName.toUpperCase()} · CUSTOMIZABLE",
            style: AppTheme.sansBody(
              fontSize: 9,
              color: const Color(0xFFAA7C4B),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          // Title
          Text(
            item.name,
            style: GoogleFonts.italiana(
              fontSize: isDesktop ? 42 : 30,
              color: const Color(0xFF17201E),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          // Description
          Text(
            item.description,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: const Color(0xFF6D746F),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          // Price block
          if (hasDiscount) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppFormatters.formatCurrency(item.price),
                  style: AppTheme.sansBody(
                    fontSize: 14,
                    color: const Color(0xFF6D746F),
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: 10),
                Text(
                  "$discountPct% OFF",
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: const Color(0xFFAA7C4B),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Text(
            AppFormatters.formatCurrency(item.effectivePrice),
            style: GoogleFonts.italiana(
              fontSize: 34,
              color: const Color(0xFF17201E),
              height: 1,
            ),
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 4),
            Text(
              "You Save ${AppFormatters.formatCurrency(savedAmount)}",
              style: AppTheme.sansBody(
                fontSize: 12,
                color: const Color(0xFF3A7A5A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            "Starting Price",
            style: AppTheme.sansBody(
              fontSize: 11,
              color: const Color(0xFF17201E),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          // COLOR STORY dropdown
          if (item.colors.isNotEmpty) ...[
            Text(
              "COLOR STORY",
              style: AppTheme.sansBody(
                fontSize: 9,
                color: const Color(0xFF17201E),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            _ModalDropdown(
              value: _selectedColor,
              items: item.colors,
              onChanged: (v) => setState(() => _selectedColor = v),
            ),
            const SizedBox(height: 16),
          ],
          // DESIGN MOOD dropdown
          if (item.themes.isNotEmpty) ...[
            Text(
              "DESIGN MOOD",
              style: AppTheme.sansBody(
                fontSize: 9,
                color: const Color(0xFF17201E),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            _ModalDropdown(
              value: _selectedTheme,
              items: item.themes,
              onChanged: (v) => setState(() => _selectedTheme = v),
            ),
            const SizedBox(height: 16),
          ],
          // YOUR NOTE text area
          Text(
            "YOUR NOTE",
            style: AppTheme.sansBody(
              fontSize: 9,
              color: const Color(0xFF17201E),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF17201E).withValues(alpha: 0.2)),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTheme.sansBody(fontSize: 13, color: const Color(0xFF17201E)),
              decoration: InputDecoration(
                hintText: "Names, venue details or a specific idea…",
                hintStyle: AppTheme.sansBody(fontSize: 12, color: const Color(0xFF6D746F)),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Inclusions
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _InclusionChip("Styling & installation"),
              _InclusionChip("Teardown"),
              _InclusionChip("Dedicated coordinator"),
            ],
          ),
          const SizedBox(height: 16),
          // ADD TO MY SELECTION button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                cartController.addToCart(
                  item,
                  color: _selectedColor,
                  theme: _selectedTheme,
                  notes: _notesController.text,
                );
                Navigator.of(context).pop();
                Get.snackbar(
                  "Added to Canvas",
                  "${item.name} added to your selection.",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text(
                "ADD TO MY SELECTION",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAA7C4B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ((width - dialogWidth) / 2).clamp(8.0, double.infinity),
        vertical: (height - dialogMaxHeight) / 2,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Material(
          color: const Color(0xFFFBF9F4),
          borderRadius: BorderRadius.zero,
          child: Stack(
            children: [
              // Content: image left + right panel
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left: image
                        SizedBox(
                          width: dialogWidth * 0.47,
                          child: _buildImage(
                            item.imageUrl,
                            item.name,
                            item.categorySlug,
                            item.categoryName,
                          ),
                        ),
                        // Right: scrollable detail panel
                        Expanded(child: rightPanel),
                      ],
                    )
                  : rightPanel,
              // Close button (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF9F4),
                      border: Border.all(
                        color: const Color(0xFF17201E).withValues(alpha: 0.2),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF17201E)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;

  const _ModalDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF17201E).withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          style: AppTheme.sansBody(fontSize: 13, color: const Color(0xFF17201E)),
          iconEnabledColor: const Color(0xFF17201E),
          items: items
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _InclusionChip extends StatelessWidget {
  final String label;
  const _InclusionChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 12, color: Color(0xFFAA7C4B)),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 11,
            color: const Color(0xFF6D746F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
// 4. CATEGORIES


class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;

    final paint3 = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50;

    canvas.drawCircle(center, 120.0 + 25.0, paint3);
    canvas.drawCircle(center, 120.0 + 12.0, paint2);
    canvas.drawCircle(center, 120.0, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryCard extends StatefulWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color catColor;
    try {
      catColor = Color(int.parse(widget.category.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      catColor = const Color(0xFFC79B61);
    }
    const cardBackground = Color(0xFF1C2724);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // 1. Gradient Background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          catColor,
                          cardBackground,
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Decorative Concentric Circles in Top-Right
                Positioned(
                  right: -60,
                  top: -70,
                  child: CustomPaint(
                    size: const Size(240, 240),
                    painter: _ConcentricCirclesPainter(),
                  ),
                ),

                // 3. Card Content
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Icon
                      Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 34),
                      ),

                      // Bottom Column: Text info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.category.itemCount} SIGNATURE EXPERIENCES",
                            style: AppTheme.sansBody(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.65),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.category.name,
                            style: GoogleFonts.italiana(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.category.description,
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 4. Arrow Button in Bottom-Right
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: _isHovered
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedRotation(
                      turns: _isHovered ? 0.125 : 0.0, // Rotate by 45 degrees
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        "↗",
                        style: AppTheme.sansBody(
                          fontSize: 18,
                          color: _isHovered ? const Color(0xFF17201E) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final CatalogController controller;
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;

  const _CategoriesSection({
    required this.controller,
    required this.categoriesKey,
    required this.catalogKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    // Spacing clamp
    final double sectionPaddingVertical = (width * 0.08).clamp(85.0, 155.0);
    final double titleSize = width >= 700 ? (width * 0.05).clamp(46.0, 78.0) : 42.0;
    final bool isWide = width >= 800;

    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BEGIN WITH A FEELING",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: const Color(0xFFAA7C4B),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: titleSize,
              fontWeight: FontWeight.normal,
              color: isDark ? Colors.white : const Color(0xFF17201E),
              height: 0.98,
            ),
            children: [
              const TextSpan(text: "What are we\n"),
              TextSpan(
                text: "celebrating?",
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFAA7C4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final descWidget = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Text(
        "Choose a chapter and make it personal. Every collection is a starting point, never a fixed package.",
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          height: 1.8,
        ),
      ),
    );

    final headerRow = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headingWidget,
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: descWidget,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headingWidget,
              const SizedBox(height: 22),
              descWidget,
            ],
          );

    return Container(
      key: categoriesKey,
      width: double.infinity,
      color: isDark ? const Color(0xFF0B100E) : const Color(0xFFFAF8F5),
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: sectionPaddingVertical),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerRow,
              const SizedBox(height: 62),
              Obx(() {
                if (controller.isLoadingCategories.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFAA7C4B)));
                }

                if (controller.rxCategories.isEmpty) {
                  return const SizedBox();
                }

                final gridCount = width >= 1000 ? 3 : (width >= 600 ? 2 : 1);
                final double cardHeight = width >= 600 ? 275 : 230;
                final double gridWidth = width - (paddingHorizontal * 2);
                final double cardWidth = (gridWidth.clamp(0.0, 1200.0) - (gridCount - 1) * 16) / gridCount;
                final double childAspectRatio = cardWidth / cardHeight;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: controller.rxCategories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.rxCategories[index];
                    return _CategoryCard(
                      category: cat,
                      onTap: () {
                        controller.selectCategory(cat.slug);
                        if (catalogKey.currentContext != null) {
                          Scrollable.ensureVisible(
                            catalogKey.currentContext!,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// 5. EXPERIENCES CATALOG

class _ExperienceCard extends StatefulWidget {
  final Experience item;
  final VoidCallback onQuickAdd;
  final VoidCallback onTap;

  const _ExperienceCard({
    required this.item,
    required this.onQuickAdd,
    required this.onTap,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _isHovered = false;

  Widget _buildImage(String url, String title, String categorySlug, String categoryName) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName);
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ItemVisualPlaceholder(title: title, categorySlug: categorySlug, categoryName: categoryName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.04 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: _buildImage(
                          widget.item.imageUrl,
                          widget.item.name,
                          widget.item.categorySlug,
                          widget.item.categoryName,
                        ),
                      ),
                    ),
                    if (widget.item.isFeatured)
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          color: const Color(0xEBFAF5EE),
                          child: Text(
                            "MOST LOVED",
                            style: AppTheme.sansBody(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF28322E),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onQuickAdd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isHovered ? const Color(0xFFC79B61) : const Color(0xE6192320),
                            ),
                            alignment: Alignment.center,
                            child: AnimatedRotation(
                              turns: _isHovered ? 0.25 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: const Text(
                                "+",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.item.categoryName.toUpperCase()} · ${widget.item.durationHours.toStringAsFixed(0)} HRS",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: const Color(0xFFAA7C4B),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.item.name,
                    style: GoogleFonts.italiana(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF17201E),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: Text(
                      widget.item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            AppFormatters.formatCurrency(widget.item.effectivePrice),
                            style: AppTheme.sansBody(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF17201E),
                            ),
                          ),
                          if (widget.item.offerPrice != null && widget.item.offerPrice! < widget.item.price) ...[
                            const SizedBox(width: 6),
                            Text(
                              AppFormatters.formatCurrency(widget.item.price),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Text(
                            "starting price",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Color(0xFFC79B61)),
                          const SizedBox(width: 3),
                          Text(
                            "${widget.item.rating} (${widget.item.reviewCount})",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperiencesCatalogSection extends StatelessWidget {
  final CatalogController controller;
  final CartController cartController;
  final GlobalKey catalogKey;
  final bool isDesktop;
  final bool isTablet;

  const _ExperiencesCatalogSection({
    required this.controller,
    required this.cartController,
    required this.catalogKey,
    required this.isDesktop,
    required this.isTablet,
  });

  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.white : const Color(0xFF1E2B27))
                : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : (isDark ? Colors.white24 : Colors.black12),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? (isDark ? const Color(0xFF17201E) : Colors.white)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    final double sectionPaddingVertical = (width * 0.08).clamp(85.0, 155.0);
    final double titleSize = width >= 700 ? (width * 0.05).clamp(46.0, 78.0) : 42.0;
    final bool isWide = width >= 800;

    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CURATED EXPERIENCES",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: const Color(0xFFAA7C4B),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: titleSize,
              fontWeight: FontWeight.normal,
              color: isDark ? Colors.white : const Color(0xFF17201E),
              height: 0.98,
            ),
            children: [
              const TextSpan(text: "Designed to leave\n"),
              const TextSpan(text: "a "),
              TextSpan(
                text: "beautiful echo.",
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFAA7C4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final descWidget = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Text(
        "Explore signature concepts, see an honest starting price, then tune every color, material and detail.",
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          height: 1.8,
        ),
      ),
    );

    final headerRow = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headingWidget,
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: descWidget,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headingWidget,
              const SizedBox(height: 22),
              descWidget,
            ],
          );

    final searchWidget = Container(
      height: 46,
      width: isWide ? 280 : double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => controller.updateSearchQuery(val),
              style: AppTheme.sansBody(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF17201E),
              ),
              decoration: const InputDecoration(
                hintText: "Search a mood, theme or event…",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );

    final sortWidget = Container(
      height: 46,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.sortBy.value,
              dropdownColor: isDark ? const Color(0xFF1B2320) : Colors.white,
              icon: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'popular', child: Text("Most loved")),
                DropdownMenuItem(value: 'latest', child: Text("Latest")),
                DropdownMenuItem(value: 'price_low', child: Text("Price: low to high")),
                DropdownMenuItem(value: 'price_high', child: Text("Price: high to low")),
              ],
              onChanged: (val) {
                if (val != null) controller.updateSort(val);
              },
              style: AppTheme.sansBody(
                fontSize: 12,
                color: isDark ? Colors.white : const Color(0xFF17201E),
              ),
            ),
          )),
    );

    final chipsWidget = SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Obx(() {
              final isActive = controller.selectedCategorySlug.value.isEmpty;
              return _buildChip(
                label: "All",
                isActive: isActive,
                onTap: () => controller.selectCategory(''),
                isDark: isDark,
              );
            }),
            const SizedBox(width: 7),
            Obx(() => Row(
                  children: controller.rxCategories.map((cat) {
                    final isActive = controller.selectedCategorySlug.value == cat.slug;
                    return Padding(
                      padding: const EdgeInsets.only(right: 7.0),
                      child: _buildChip(
                        label: cat.name.replaceFirst(" Celebrations", ""),
                        isActive: isActive,
                        onTap: () => controller.selectCategory(cat.slug),
                        isDark: isDark,
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );

    final toolbar = isWide
        ? Row(
            children: [
              searchWidget,
              const SizedBox(width: 14),
              Expanded(child: chipsWidget),
              const SizedBox(width: 14),
              sortWidget,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchWidget,
              const SizedBox(height: 14),
              chipsWidget,
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerLeft, child: sortWidget),
            ],
          );

    return Container(
      key: catalogKey,
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: sectionPaddingVertical),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerRow,
              const SizedBox(height: 62),
              toolbar,
              const SizedBox(height: 34),
              Obx(() {
                if (controller.isLoadingExperiences.value) {
                  return const Center(child: LoadingIndicator(message: "Refreshing experiences canvas..."));
                }

                if (controller.rxExperiences.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        "No experiences match that search. Try a broader mood.",
                        style: AppTheme.sansBody(fontSize: 14, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                      ),
                    ),
                  );
                }

                final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                final double gridWidth = width - (paddingHorizontal * 2);
                final double cardWidth = (gridWidth.clamp(0.0, 1200.0) - (gridCount - 1) * 18) / gridCount;
                final double childAspectRatio = cardWidth / ((cardWidth / 1.12) + 170);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 32,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: controller.rxExperiences.length,
                  itemBuilder: (context, index) {
                    final item = controller.rxExperiences[index];
                    return _ExperienceCard(
                      item: item,
                      onQuickAdd: () {
                        cartController.addToCart(item);
                        Get.snackbar("Added to Canvas", "${item.name} added.", snackPosition: SnackPosition.BOTTOM);
                      },
                      onTap: () => _showExperienceDetailDialog(context, item),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// 6. VIDEO STORIES SECTION
class _VideoStoriesSection extends StatelessWidget {
  final GlobalKey storiesKey;
  final bool isDesktop;
  final GlobalKey catalogKey;

  const _VideoStoriesSection({
    required this.storiesKey,
    required this.isDesktop,
    required this.catalogKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: storiesKey,
      width: double.infinity,
      color: const Color(0xFF16201D),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 100.0 : 60.0,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _VideoStoryRow(
                isDesktop: isDesktop,
                eyebrow: "Celebrate in style",
                titlePart1: "A glimpse before",
                titlePart2: "the big day.",
                description:
                    "From elegant balloon styling to personalized backdrops and thoughtful details, we create celebrations that feel joyful, memorable, and uniquely yours. Every setup is crafted to make your special day unforgettable.",
                facts: const [
                  "Theme & Planning",
                  "Production & styling",
                  "Celebrate & Capture Memories",
                ],
                videoAsset: "assets/videos/Birthday.mp4",
                posterAsset: "assets/images/birthday.jpg",
                onCtaPressed: () {
                  Scrollable.ensureVisible(
                    catalogKey.currentContext!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              SizedBox(height: isDesktop ? 100 : 60),
              _VideoStoryRow(
                isDesktop: isDesktop,
                eyebrow: "Experience the excitement",
                titlePart1: "Balloon Blast",
                titlePart2: "the perfect surprise.",
                description:
                    "A single pop transforms the atmosphere into a shower of colors, confetti, and unforgettable smiles. Designed to create the perfect reveal for birthdays, proposals, anniversaries, baby showers, and every celebration worth remembering.",
                facts: const [
                  "Suspense & Countdown",
                  "Balloon Blast Moment",
                  "Cheers & Celebration",
                ],
                videoAsset: "assets/videos/Balloonblast.mp4",
                posterAsset: "assets/images/BaloonBlast.jpg",
                onCtaPressed: () {
                  Scrollable.ensureVisible(
                    catalogKey.currentContext!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoStoryRow extends StatelessWidget {
  final bool isDesktop;
  final String eyebrow;
  final String titlePart1;
  final String titlePart2;
  final String description;
  final List<String> facts;
  final String videoAsset;
  final String posterAsset;
  final VoidCallback onCtaPressed;

  const _VideoStoryRow({
    required this.isDesktop,
    required this.eyebrow,
    required this.titlePart1,
    required this.titlePart2,
    required this.description,
    required this.facts,
    required this.videoAsset,
    required this.posterAsset,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double titleSize = isDesktop ? (width * 0.045).clamp(42.0, 76.0) : 34.0;

    final copyWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 10,
            color: const Color(0xFFD6B080), // gold-2
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: titleSize,
              color: Colors.white,
              height: 0.98,
            ),
            children: [
              TextSpan(text: "$titlePart1\n"),
              TextSpan(
                text: titlePart2,
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFD6B080), // gold-2
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: AppTheme.sansBody(
            fontSize: 14,
            color: const Color(0xFFF4F0E8).withValues(alpha: 0.65),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(facts.length, (index) {
            final numStr = "0${index + 1}";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      numStr,
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: const Color(0xFFD6B080),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      facts[index].toUpperCase(),
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: const Color(0xFFF4F0E8),
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: "Build your celebration ↗",
          isPrimary: false,
          onPressed: onCtaPressed,
        ),
      ],
    );

    final videoWidget = _VideoStoryFrame(
      videoAsset: videoAsset,
      posterAsset: posterAsset,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 8,
            child: copyWidget,
          ),
          const SizedBox(width: 80),
          Expanded(
            flex: 12,
            child: videoWidget,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          copyWidget,
          const SizedBox(height: 40),
          videoWidget,
        ],
      );
    }
  }
}

class _VideoStoryFrame extends StatefulWidget {
  final String videoAsset;
  final String posterAsset;

  const _VideoStoryFrame({
    required this.videoAsset,
    required this.posterAsset,
  });

  @override
  State<_VideoStoryFrame> createState() => _VideoStoryFrameState();
}

class _VideoStoryFrameState extends State<_VideoStoryFrame> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.asset(widget.videoAsset);
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0); // Muted by default
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (_isInitialized && !_isPlaying) {
          _controller!.play();
          setState(() => _isPlaying = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (_isInitialized && _isPlaying) {
          _controller!.pause();
          setState(() => _isPlaying = false);
        }
      },
      child: GestureDetector(
        onTap: _togglePlay,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 80,
                offset: const Offset(0, 28),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: _isInitialized && _isPlaying
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          )
                        : Image.asset(
                            widget.posterAsset,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    color: const Color(0xC70F1815),
                    child: Text(
                      "SAMPLE EVENT FILM · HD",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 7. PROCESS
class _ProcessSection extends StatelessWidget {
  final bool isDesktop;
  const _ProcessSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Easy by design",
                style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                "Your celebration, without the chaos.",
                style: AppTheme.serifHeader(fontSize: 32),
              ),
              const SizedBox(height: 36),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _stepRow(context, "01", "Choose your canvas",
                                "Browse our event collections and add the ideas that feel like you.")),
                        const SizedBox(width: 24),
                        Expanded(
                            child: _stepRow(context, "02", "Make it personal",
                                "Tune colors, themes and quantities. Leave us the details—we love those.")),
                        const SizedBox(width: 24),
                        Expanded(
                            child: _stepRow(context, "03", "Know your number",
                                "See every charge clearly and download a polished, itemized quotation.")),
                        const SizedBox(width: 24),
                        Expanded(
                            child: _stepRow(context, "04", "We bring the wonder",
                                "Our crew handles production, styling and teardown. You stay in the moment.")),
                      ],
                    )
                  : Column(
                      children: [
                        _stepRow(context, "01", "Choose your canvas",
                            "Browse our event collections and add the ideas that feel like you."),
                        _stepRow(context, "02", "Make it personal",
                            "Tune colors, themes and quantities. Leave us the details—we love those."),
                        _stepRow(context, "03", "Know your number",
                            "See every charge clearly and download a polished, itemized quotation."),
                        _stepRow(context, "04", "We bring the wonder",
                            "Our crew handles production, styling and teardown. You stay in the moment."),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRow(BuildContext context, String step, String title, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? AppTheme.darkLine : AppTheme.lightLine)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: AppTheme.serifHeader(fontSize: 24, color: isDark ? AppTheme.darkGold : AppTheme.lightGold),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.serifHeader(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: AppTheme.sansBody(fontSize: 13, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// 8. FAQ SECTION
class _FAQSection extends StatelessWidget {
  final bool isDesktop;
  const _FAQSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "A few good questions",
                            style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Before the confetti flies.",
                            style: AppTheme.serifHeader(fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      flex: 13,
                      child: Column(
                        children: [
                          _faqItem("How far in advance should I book?",
                              "Four to eight weeks is ideal for custom work. For larger weddings, reserve your date three to six months ahead. Short notice? Ask us—we keep a little room for spontaneous magic."),
                          _faqItem("Can I change the colors and materials?",
                              "Absolutely. Every concept can be adapted to your palette, venue and story. Use the canvas builder to share your direction."),
                          _faqItem("What does the starting price include?",
                              "The starting price includes the listed styling, setup and teardown. Your quotation separately displays GST and flat delivery charges."),
                          _faqItem("Do you visit the venue before the event?",
                              "For complex installations and weddings, we schedule a site visit after the discovery call. It helps us verify dimensions, power access and load-in timing."),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A few good questions",
                      style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Before the confetti flies.",
                      style: AppTheme.serifHeader(fontSize: 28),
                    ),
                    const SizedBox(height: 28),
                    _faqItem("How far in advance should I book?",
                        "Four to eight weeks is ideal for custom work. For larger weddings, reserve your date three to six months ahead. Short notice? Ask us—we keep a little room for spontaneous magic."),
                    _faqItem("Can I change the colors and materials?",
                        "Absolutely. Every concept can be adapted to your palette, venue and story. Use the canvas builder to share your direction."),
                    _faqItem("What does the starting price include?",
                        "The starting price includes the listed styling, setup and teardown. Your quotation separately displays GST and flat delivery charges."),
                    _faqItem("Do you visit the venue before the event?",
                        "For complex installations and weddings, we schedule a site visit after the discovery call. It helps us verify dimensions, power access and load-in timing."),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      children: [
        Text(
          answer,
          style: AppTheme.sansBody(fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}

// 9. CONTACT LEAD CAPTURE
class _ContactSection extends StatelessWidget {
  final CatalogController controller;
  final GlobalKey contactKey;
  final bool isDesktop;

  const _ContactSection({
    required this.controller,
    required this.contactKey,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Container(
      key: contactKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8D623E), Color(0xFFBE9162)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Have something else in mind?",
                            style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFFF6DFC4), fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Let’s make room for the unexpected.",
                            style: AppTheme.serifHeader(fontSize: 36, color: Colors.white, height: 1.1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tell us the dream, the venue, and the number you want to stay near. We’ll shape the rest together.",
                            style: AppTheme.sansBody(fontSize: 15, color: Colors.white.withValues(alpha: 0.9), height: 1.6),
                          ),
                          const SizedBox(height: 28),
                          CustomButton(
                            text: "Start a Conversation",
                            isPrimary: false,
                            onPressed: () => _openLeadDialog(context),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Have something else in mind?",
                      style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFFF6DFC4), fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Let’s make room for the unexpected.",
                      style: AppTheme.serifHeader(fontSize: 28, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Tell us the dream, the venue, and the number you want to stay near. We’ll shape the rest together.",
                      style: AppTheme.sansBody(fontSize: 14, color: Colors.white70, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: "Start a Conversation",
                      isPrimary: false,
                      onPressed: () => _openLeadDialog(context),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

// 10. FOOTER
class _FooterSection extends StatelessWidget {
  final bool isDesktop;
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;
  final GlobalKey storiesKey;

  const _FooterSection({
    required this.isDesktop,
    required this.categoriesKey,
    required this.catalogKey,
    required this.storiesKey,
  });

  Widget _footerLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 32.0;

    return Container(
      color: const Color(0xFF101815),
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 64),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Col 1: Branding
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("OE", style: AppTheme.serifHeader(fontSize: 28, color: const Color(0xFFC9A77E))),
                              Text("OM EVENTS", style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3)),
                              const SizedBox(height: 14),
                              Text("Moments pass. Beautiful ones echo.", style: AppTheme.serifHeader(fontSize: 14, color: const Color(0xFFC9A77E))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Col 2: Exploration
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("EXPLORE", style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 16),
                              _footerLink("Collections", () {
                                Scrollable.ensureVisible(categoriesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                              }),
                              _footerLink("Experiences", () {
                                Scrollable.ensureVisible(catalogKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                              }),
                              _footerLink("Stories", () {
                                Scrollable.ensureVisible(storiesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                              }),
                              _footerLink("API docs", () => Get.toNamed(AppRoutes.docs)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Col 3: Visit
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("VISIT", style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 16),
                              Text(
                                "Branch - 1: Medha (kadi-kalyanpura road),\nBranch - 2: Thangadh (Surendranagar)\nGujarat, India 382715",
                                style: AppTheme.sansBody(fontSize: 11, color: Colors.white60, height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => launchUrl(Uri.parse("tel:+919512149944")),
                                child: Text("+91 95121 49944", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                              ),
                              InkWell(
                                onTap: () => launchUrl(Uri.parse("tel:+919313513156")),
                                child: Text("+91 93135 13156", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => launchUrl(Uri.parse("mailto:omeventsanddecorators@gmail.com")),
                                child: Text("omeventsanddecorators\n@gmail.com", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60, height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Col 4: Follow the wonder
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("FOLLOW THE WONDER", style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              const SizedBox(height: 16),
                              _footerLink("Instagram - Kadi ↗", () => launchUrl(Uri.parse("https://www.instagram.com/om_events_and_decorators/"))),
                              _footerLink("Instagram - Thangadh ↗", () => launchUrl(Uri.parse("https://www.instagram.com/om_events__decorators/"))),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("OE", style: AppTheme.serifHeader(fontSize: 24, color: const Color(0xFFC9A77E))),
                        Text("OM EVENTS", style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3)),
                        const SizedBox(height: 10),
                        Text("Moments pass. Beautiful ones echo.", style: AppTheme.serifHeader(fontSize: 16, color: const Color(0xFFC9A77E))),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("EXPLORE", style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                  const SizedBox(height: 12),
                                  _footerLink("Collections", () {
                                    Scrollable.ensureVisible(categoriesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                  }),
                                  _footerLink("Experiences", () {
                                    Scrollable.ensureVisible(catalogKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                  }),
                                  _footerLink("Stories", () {
                                    Scrollable.ensureVisible(storiesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                  }),
                                  _footerLink("API docs", () => Get.toNamed(AppRoutes.docs)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("FOLLOW THE WONDER", style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                  const SizedBox(height: 12),
                                  _footerLink("Instagram - Kadi ↗", () => launchUrl(Uri.parse("https://www.instagram.com/om_events_and_decorators/"))),
                                  _footerLink("Instagram - Thangadh ↗", () => launchUrl(Uri.parse("https://www.instagram.com/om_events__decorators/"))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text("VISIT", style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        Text(
                          "Branch - 1: Medha (kadi-kalyanpura road),\nBranch - 2: Thangadh (Surendranagar)\nGujarat, India 382715",
                          style: AppTheme.sansBody(fontSize: 11, color: Colors.white60, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse("tel:+919512149944")),
                          child: Text("+91 95121 49944", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse("tel:+919313513156")),
                          child: Text("+91 93135 13156", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse("mailto:omeventsanddecorators@gmail.com")),
                          child: Text("omeventsanddecorators@gmail.com", style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
                        ),
                      ],
                    ),
              const SizedBox(height: 48),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© 2026 Om Events. Made with care in Gujarat.",
                    style: AppTheme.sansBody(fontSize: 9, color: Colors.white30),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.toNamed(AppRoutes.docs),
                        child: Text(
                          "DEVELOPER API",
                          style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          "TEAM STUDIO",
                          style: AppTheme.sansBody(fontSize: 9, color: const Color(0xFFC9A77E), letterSpacing: 1.0),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Left Drawer for Navigation on Mobile
class _NavDrawer extends StatelessWidget {
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;
  final GlobalKey storiesKey;
  final GlobalKey contactKey;

  const _NavDrawer({
    required this.categoriesKey,
    required this.catalogKey,
    required this.storiesKey,
    required this.contactKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Text("OE", style: AppTheme.serifHeader(fontSize: 32, color: goldColor)),
            Text("OM EVENTS", style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const Divider(height: 40),
            _drawerTile("Collections", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(categoriesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("Experiences", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(catalogKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("Stories", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(storiesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("Contact", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(contactKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("Developer API", () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.docs);
            }),
            _drawerTile("Team Studio", () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.login);
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(String label, VoidCallback onTap) {
    return ListTile(
      title: Text(
        label,
        style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
      onTap: onTap,
    );
  }
}

// 10. CART DRAWER COMPONENT
class _CartDrawer extends StatelessWidget {
  final CartController cartController;
  final QuotationController quoteController;

  const _CartDrawer({
    required this.cartController,
    required this.quoteController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: math.min(480, MediaQuery.of(context).size.width * 0.85),
      child: SafeArea(
        child: Obx(() {
          final items = cartController.rxCartItems;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Head
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("YOUR EVENT CANVAS", style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text("Selection (${items.length})", style: AppTheme.serifHeader(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),

              // Cart Items List
              if (items.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("✦", style: AppTheme.serifHeader(fontSize: 34, color: isDark ? AppTheme.darkGold : AppTheme.lightGold)),
                          const SizedBox(height: 12),
                          Text("Your canvas is open.", style: AppTheme.serifHeader(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Add signature experiences and we'll calculate charges as you go.",
                              textAlign: TextAlign.center,
                              style: AppTheme.sansBody(fontSize: 12, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final customization = [item.color, item.theme].where((e) => e.isNotEmpty).join(' · ');

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkLine : AppTheme.lightLine)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade800,
                              child: item.experience.imageUrl.startsWith('assets/')
                                  ? Image.asset(item.experience.imageUrl, fit: BoxFit.cover)
                                  : Image.network(
                                      item.experience.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.experience.name, style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(
                                    customization.isEmpty ? "Customizable" : customization,
                                    style: AppTheme.sansBody(fontSize: 10, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(AppFormatters.formatCurrency(item.experience.effectivePrice * item.quantity), style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  onPressed: () => cartController.removeFromCart(index),
                                ),
                                // Quantity selector
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => cartController.changeQuantity(index, -1),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(border: Border.all(color: isDark ? AppTheme.darkLine : AppTheme.lightLine)),
                                        child: const Icon(Icons.remove, size: 12),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      child: Text('${item.quantity}', style: const TextStyle(fontSize: 11)),
                                    ),
                                    GestureDetector(
                                      onTap: () => cartController.changeQuantity(index, 1),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(border: Border.all(color: isDark ? AppTheme.darkLine : AppTheme.lightLine)),
                                        child: const Icon(Icons.add, size: 12),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Totals Summary & Submit
              if (items.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _summaryRow("Subtotal", AppFormatters.formatCurrency(cartController.subtotal)),
                      _summaryRow(
                        "Celebration discount",
                        cartController.volumeDiscount > 0
                            ? "- ${AppFormatters.formatCurrency(cartController.volumeDiscount)}"
                            : "Unlock at ₹50k",
                        color: cartController.volumeDiscount > 0 ? Colors.green : Colors.grey,
                      ),
                      _summaryRow("Delivery Charge", AppFormatters.formatCurrency(cartController.deliveryCharge)),
                      _summaryRow("GST (${AppConstants.gstPercent.toStringAsFixed(0)}%)", AppFormatters.formatCurrency(cartController.gstAmount)),
                      if (AppConstants.enableClientFeeWaiver)
                        _summaryRow("Extra Discount!!", "- ${AppFormatters.formatCurrency(cartController.clientWaiverDiscount)}", color: Colors.green),
                      const Divider(height: 16),
                      _summaryRow(
                        "Estimated Total",
                        AppFormatters.formatCurrency(cartController.grandTotal),
                        isBold: true,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        text: "Create my quotation",
                        onPressed: () {
                          // Close drawer and open Quotation dialog
                          Navigator.of(context).pop();
                          _openQuoteDialog(context, quoteController);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, double fontSize = 12, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.sansBody(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: AppTheme.sansBody(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
          ),
        ],
      ),
    );
  }
}

// 11. LEAD DIALOG MODAL
void _openLeadDialog(BuildContext context) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  final budgetController = TextEditingController();
  final reqsController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      final catalogController = Get.find<CatalogController>();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        insetPadding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("LET'S TALK", style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Text("Tell us about the occasion.", style: AppTheme.serifHeader(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: "Your Name",
                    placeholder: "Enter full name",
                    controller: nameController,
                    validator: (val) => AppValidators.isValidName(val ?? '') ? null : "Please enter your name.",
                  ),
                  CustomInput(
                    label: "Phone Number",
                    placeholder: "10-digit mobile number",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) => AppValidators.isValidPhone(val ?? '') ? null : "Please enter a 10-digit number.",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          label: "Event Date",
                          placeholder: "YYYY-MM-DD",
                          controller: dateController,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          label: "Approx. Budget",
                          placeholder: "₹",
                          controller: budgetController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  CustomInput(
                    label: "What are you imagining?",
                    placeholder: "Details, must-have accents, themes...",
                    controller: reqsController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Obx(() => CustomButton(
                        text: "Request a callback",
                        isLoading: catalogController.isSubmittingLead.value,
                        onPressed: () async {
                          if (formKey.currentState?.validate() == true) {
                            final success = await catalogController.requestCallback(
                              name: nameController.text,
                              phone: phoneController.text,
                              dateStr: dateController.text,
                              budgetStr: budgetController.text,
                              requirements: reqsController.text,
                            );
                            if (success) {
                              Get.back();
                            }
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// 12. QUOTE DIALOG MODAL
void _openQuoteDialog(BuildContext context, QuotationController quoteController) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController(text: "18:00");
  final locController = TextEditingController();
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        insetPadding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ALMOST THERE", style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Text("Where should we bring the wonder?", style: AppTheme.serifHeader(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: "Full Name",
                    placeholder: "Enter full name",
                    controller: nameController,
                    validator: (val) => AppValidators.isValidName(val ?? '') ? null : "Please enter your name.",
                  ),
                  CustomInput(
                    label: "Phone",
                    placeholder: "10-digit mobile number",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) => AppValidators.isValidPhone(val ?? '') ? null : "Please enter a 10-digit number.",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          label: "Event Date",
                          placeholder: "YYYY-MM-DD",
                          controller: dateController,
                          keyboardType: TextInputType.datetime,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Date required.";
                            final parsed = DateTime.tryParse(val);
                            if (parsed == null) return "Invalid date.";
                            if (!AppValidators.isFutureDate(parsed)) return "Cannot be in the past.";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          label: "Event Time",
                          placeholder: "HH:MM",
                          controller: timeController,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ],
                  ),
                  CustomInput(
                    label: "Venue / Location",
                    placeholder: "Venue name, area and city",
                    controller: locController,
                    validator: (val) => (val != null && val.trim().isNotEmpty) ? null : "Location required.",
                  ),
                  CustomInput(
                    label: "Notes or Special Instructions",
                    placeholder: "Timings, access rules, specific colors...",
                    controller: notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Obx(() => CustomButton(
                        text: "Generate quotation",
                        isLoading: quoteController.isGeneratingQuote.value,
                        onPressed: () async {
                          if (formKey.currentState?.validate() == true) {
                            final success = await quoteController.submitQuotationRequest(
                              name: nameController.text,
                              phone: phoneController.text,
                              dateStr: dateController.text,
                              timeStr: timeController.text,
                              location: locController.text,
                              notes: notesController.text,
                            );
                            if (success) {
                              Get.back();
                            }
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AnnouncementBanner extends StatelessWidget {
  final bool isDesktop;
  const _AnnouncementBanner({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: double.infinity,
      color: const Color(0xFFB88957),
      alignment: Alignment.center,
      child: Text(
        "NOW ACCEPTING CELEBRATIONS FOR JULY–DECEMBER 2026    •    GUJARAT & BEYOND",
        style: AppTheme.sansBody(
          fontSize: isDesktop ? 10 : 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: isDesktop ? 2.0 : 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AnimatedStatsBand extends StatelessWidget {
  final bool isDesktop;
  const _AnimatedStatsBand({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forestColor = isDark ? const Color(0xFFD8E3DC) : const Color(0xFF1E2B27);
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    if (width >= 700) {
      return Container(
        color: forestColor,
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 62),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: const [
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 650,
                    label: "celebrations styled",
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 38,
                    label: "creative specialists",
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 4.9,
                    label: "average rating",
                    hasPlus: false,
                    decimals: 1,
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 12,
                    label: "cities served",
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: forestColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 650,
                    label: "celebrations styled",
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 38,
                    label: "creative specialists",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: const [
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 4.9,
                    label: "average rating",
                    hasPlus: false,
                    decimals: 1,
                  ),
                ),
                Expanded(
                  child: _AnimatedStatTile(
                    targetValue: 12,
                    label: "cities served",
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}

class _AnimatedStatTile extends StatefulWidget {
  final double targetValue;
  final String label;
  final bool hasPlus;
  final int decimals;

  const _AnimatedStatTile({
    required this.targetValue,
    required this.label,
    this.hasPlus = true,
    this.decimals = 0,
  });

  @override
  State<_AnimatedStatTile> createState() => _AnimatedStatTileState();
}

class _AnimatedStatTileState extends State<_AnimatedStatTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? const Color(0xFFE3C89F) : const Color(0xFFD3AD7B);
    final creamColor = isDark ? const Color(0xFF141A18) : const Color(0xFFF4F0E8);
    final double paddingLeft = MediaQuery.of(context).size.width >= 700 ? 28 : 15;
    final double fontSize = MediaQuery.of(context).size.width >= 700 ? 56 : 42;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        String numStr = _animation.value.toStringAsFixed(widget.decimals);
        if (widget.hasPlus) {
          numStr += "+";
        }
        return Container(
          padding: EdgeInsets.only(left: paddingLeft),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                numStr,
                style: AppTheme.serifHeader(
                  fontSize: fontSize,
                  color: goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label.toUpperCase(),
                style: AppTheme.sansBody(
                  fontSize: 9,
                  color: creamColor.withValues(alpha: 0.65),

                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

