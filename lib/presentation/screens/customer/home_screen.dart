import 'dart:async' as dart_async;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
            backgroundColor: isDark ? const Color(0xFF141A18) : const Color(0xFF1E2B27),
            leading: isDesktop
                ? null
                : IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                  ),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "OE",
                      style: AppTheme.serifHeader(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
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
                      style: AppTheme.serifHeader(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    Text(
                      "MAKE IT MEMORABLE",
                      style: AppTheme.sansBody(fontSize: 6, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
                if (isDesktop) ...[
                  const Spacer(),
                  _navLink("COLLECTIONS", () => scrollToSection(categoriesKey)),
                  _navLink("EXPERIENCES", () => scrollToSection(catalogKey)),
                  _navLink("STORIES", () => scrollToSection(storiesKey)),
                  _navLink("CONTACT", () => scrollToSection(contactKey)),
                  _navLink("DEVELOPER API", () => Get.toNamed(AppRoutes.docs)),
                ],
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: Colors.white),
                onPressed: () {
                  Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                },
              ),
              Obx(() {
                final count = cartController.rxCartItems.length;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
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
                  icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
                  onPressed: () => Get.toNamed(AppRoutes.login),
                ),
              const SizedBox(width: 12),
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
                _CategoriesSection(controller: controller, categoriesKey: categoriesKey),
                _ExperiencesCatalogSection(
                  controller: controller,
                  cartController: cartController,
                  catalogKey: catalogKey,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
                _VideoStoriesSection(storiesKey: storiesKey, isDesktop: isDesktop),
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

  Widget _navLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// 1. HERO SECTION
class _HeroSection extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isDesktop;

  const _HeroSection({
    required this.scaffoldKey,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final heroDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF0F1815), const Color(0xFF192521), const Color(0xFF382E25)]
            : [const Color(0xFF1D2A26), const Color(0xFF2F413B), const Color(0xFF635242)],
      ),
    );

    return Container(
      width: double.infinity,
      decoration: heroDecoration,
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
    );
  }
}

class _HeroContent extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _HeroContent({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;
    final goldSecondary = isDark ? AppTheme.darkGoldSecondary : AppTheme.lightGoldSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bespoke event design • Ahmedabad",
          style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 18),
        RichText(
          text: TextSpan(
            style: AppTheme.serifHeader(fontSize: 48, color: Colors.white, height: 1.1),
            children: [
              const TextSpan(text: "Celebrations,\n"),
              TextSpan(
                text: "thoughtfully",
                style: AppTheme.serifHeader(
                  fontSize: 48,
                  color: goldSecondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const TextSpan(text: " composed."),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "From the first sketch to the final flower, create an experience that feels unmistakably yours—with transparent prices from the start.",
          style: AppTheme.sansBody(fontSize: 15, color: Colors.white70, height: 1.6),
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            Container(
              width: 160,
              child: CustomButton(
                text: "Design your event ↗",
                onPressed: () {
                  // Click to drawer
                  scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 160,
              child: CustomButton(
                text: "Plan with an expert",
                isPrimary: false,
                onPressed: () => _openLeadDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _trustLabel("4.9 ★ Google Rating"),
              _divider(),
              _trustLabel("650+ Celebrations"),
              _divider(),
              _trustLabel("8 Years of Wonder"),
            ],
          ),
        )
      ],
    );
  }

  Widget _trustLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.sansBody(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Text("•", style: TextStyle(color: Colors.white30)),
    );
  }
}

class HeroStageArch extends StatelessWidget {
  const HeroStageArch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
          width: 1,
        ),
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            // Vector painting of the double arch and balloons
            const Positioned.fill(
              child: CustomPaint(
                painter: StageArchPainter(),
              ),
            ),
            // Featured Story Center Copy
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
                      color: Colors.white.withOpacity(0.65),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ivory Vow",
                    style: AppTheme.serifHeader(
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
                      color: Colors.white.withOpacity(0.65),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            // Floating Badge: "HANDCRAFTED. Every detail, yours."
            Positioned(
              left: 24,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.48),
                  border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HANDCRAFTED",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC39463),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Every detail, yours.",
                      style: AppTheme.serifHeader(
                        fontSize: 14,
                        color: Colors.white,
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
    // Background gradient from dark green to brown
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [const Color(0xFF131E1B), const Color(0xFF483A2E)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Arch 1
    final archPaint1 = Paint()
      ..color = const Color(0xFFD3AD7B).withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path1 = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..lineTo(size.width * 0.18, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.04, size.width * 0.82, size.height * 0.28)
      ..lineTo(size.width * 0.82, size.height);
    canvas.drawPath(path1, archPaint1);

    // Arch 2 (inner offset arch)
    final archPaint2 = Paint()
      ..color = const Color(0xFFD3AD7B).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final path2 = Path()
      ..moveTo(size.width * 0.28, size.height)
      ..lineTo(size.width * 0.28, size.height * 0.38)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.16, size.width * 0.72, size.height * 0.38)
      ..lineTo(size.width * 0.72, size.height);
    canvas.drawPath(path2, archPaint2);

    // Decorative Balloon circles
    final balloonPaint = Paint()
      ..color = const Color(0xFFD3AD7B).withOpacity(0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.38), 24, balloonPaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.42), 18, balloonPaint);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.36), 20, balloonPaint);

    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.38), 24, balloonPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.42), 18, balloonPaint);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.36), 20, balloonPaint);

    final balloonPaint2 = Paint()
      ..color = const Color(0xFFF4F0E8).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.16), 26, balloonPaint2);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.18), 20, balloonPaint2);
    canvas.drawCircle(Offset(size.width * 0.54, size.height * 0.18), 20, balloonPaint2);
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
    "Surprises",
    "Grand Entries",
    "Launches",
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

    return Container(
      height: 52,
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: isDark ? AppTheme.darkLine : AppTheme.lightLine),
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
              children: [
                Text(
                  "  ${item.toUpperCase()}  ",
                  style: AppTheme.serifHeader(fontSize: 12, color: Colors.grey.shade600, letterSpacing: 2),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("✦", style: TextStyle(color: Colors.grey, fontSize: 10)),
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
class _BenefitsSection extends StatelessWidget {
  final bool isDesktop;
  const _BenefitsSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 1000 ? 3 : (width >= 700 ? 2 : 1);

    final List<Map<String, String>> cardsData = [
      {
        'icon': '◇',
        'title': 'Personal Design',
        'desc': 'A concept shaped around your story, venue and budget—not a fixed package.',
      },
      {
        'icon': '₹',
        'title': 'Clear Live Pricing',
        'desc': 'Build your selection and see every charge before you send an enquiry.',
      },
      {
        'icon': '⌁',
        'title': 'One Accountable Team',
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

    List<Widget> cards = cardsData.map((data) {
      return _benefitCard(context, data['icon']!, data['title']!, data['desc']!);
    }).toList();

    Widget gridWidget;
    if (crossAxisCount == 3) {
      gridWidget = Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 24),
              Expanded(child: cards[1]),
              const SizedBox(width: 24),
              Expanded(child: cards[2]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[3]),
              const SizedBox(width: 24),
              Expanded(child: cards[4]),
              const SizedBox(width: 24),
              Expanded(child: cards[5]),
            ],
          ),
        ],
      );
    } else if (crossAxisCount == 2) {
      gridWidget = Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 24),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 24),
              Expanded(child: cards[3]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[4]),
              const SizedBox(width: 24),
              Expanded(child: cards[5]),
            ],
          ),
        ],
      );
    } else {
      gridWidget = Column(
        children: cards,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width >= 1000 ? 64 : 24,
        vertical: 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Why Celebrate With Us",
                style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text(
                "Everything your event needs. One accountable team.",
                style: AppTheme.serifHeader(fontSize: 32, height: 1.1),
              ),
              const SizedBox(height: 36),
              gridWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitCard(BuildContext context, String icon, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
        border: Border.all(color: isDark ? AppTheme.darkLine : AppTheme.lightLine, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? AppTheme.darkGold : AppTheme.lightGold, width: 1),
            ),
            child: Center(
              child: Text(
                icon,
                style: AppTheme.serifHeader(fontSize: 18, color: isDark ? AppTheme.darkGold : AppTheme.lightGold),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.serifHeader(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTheme.sansBody(fontSize: 13, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted, height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


// 4. CATEGORIES
class _CategoriesSection extends StatelessWidget {
  final CatalogController controller;
  final GlobalKey categoriesKey;

  const _CategoriesSection({
    required this.controller,
    required this.categoriesKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = width >= 1000 ? 64.0 : 24.0;

    return Padding(
      key: categoriesKey,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Begin with a feeling",
                style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                "What are we celebrating?",
                style: AppTheme.serifHeader(fontSize: 32),
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isLoadingCategories.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: controller.rxCategories.map((cat) {
                    final isSelected = controller.selectedCategorySlug.value == cat.slug;
                    return GestureDetector(
                      onTap: () => controller.selectCategory(cat.slug),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppTheme.darkGold : AppTheme.lightGold)
                              : (isDark ? AppTheme.darkPaper : AppTheme.lightPaper),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppTheme.darkLine : AppTheme.lightLine),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              cat.name.replaceFirst(" Celebrations", "").toUpperCase(),
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppTheme.darkInk : AppTheme.lightInk),
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

// 5. EXPERIENCES CATALOG
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
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;
    final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Container(
      key: catalogKey,
      color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Filter Toolbar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => controller.updateSearchQuery(val),
                      style: AppTheme.sansBody(fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 18),
                        hintText: "Search a mood, theme or event...",
                        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: isDark ? AppTheme.darkLine : AppTheme.lightLine),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Obx(() => DropdownButton<String>(
                        value: controller.sortBy.value,
                        items: const [
                          DropdownMenuItem(value: 'popular', child: Text("Popularity")),
                          DropdownMenuItem(value: 'latest', child: Text("Newest")),
                          DropdownMenuItem(value: 'price_low', child: Text("Price: Low-High")),
                          DropdownMenuItem(value: 'price_high', child: Text("Price: High-Low")),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.updateSort(val);
                        },
                        style: AppTheme.sansBody(fontSize: 12, color: isDark ? AppTheme.darkInk : AppTheme.lightInk),
                      )),
                ],
              ),
              const SizedBox(height: 48),

              // Catalog Grid
              Obx(() {
                if (controller.isLoadingExperiences.value) {
                  return const Center(child: LoadingIndicator(message: "Refreshing experiences canvas..."));
                }

                if (controller.rxExperiences.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        "No signature experiences match your search.",
                        style: AppTheme.sansBody(fontSize: 14, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 48,
                    childAspectRatio: isDesktop ? 0.72 : (isTablet ? 0.78 : 0.85),
                  ),
                  itemCount: controller.rxExperiences.length,
                  itemBuilder: (context, index) {
                    final item = controller.rxExperiences[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('${AppRoutes.detail}/${item.slug}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Container with fallback and QuickAdd
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: _buildImage(item.imageUrl, item.name, item.categorySlug, item.categoryName),
                                ),
                                if (item.isFeatured)
                                  Positioned(
                                    left: 14,
                                    top: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      color: (isDark ? AppTheme.darkPaper : AppTheme.lightPaper).withOpacity(0.92),
                                      child: Text(
                                        "MOST LOVED",
                                        style: AppTheme.sansBody(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  right: 14,
                                  bottom: 14,
                                  child: FloatingActionButton(
                                    mini: true,
                                    heroTag: 'add-quick-${item.id}',
                                    backgroundColor: isDark ? AppTheme.darkGold : AppTheme.lightGold,
                                    foregroundColor: Colors.white,
                                    onPressed: () {
                                      cartController.addToCart(item);
                                      Get.snackbar("Added to Canvas", "${item.name} added.");
                                    },
                                    child: const Icon(Icons.add, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${item.categoryName.toUpperCase()} · ${item.durationHours.toStringAsFixed(0)} HRS",
                                style: AppTheme.sansBody(
                                    fontSize: 9,
                                    color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${item.rating} (${item.reviewCount})",
                                    style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            style: AppTheme.serifHeader(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.sansBody(fontSize: 13, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                AppFormatters.formatCurrency(item.effectivePrice),
                                style: AppTheme.sansBody(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (item.offerPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  AppFormatters.formatCurrency(item.price),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 6),
                              Text(
                                "starting price",
                                style: AppTheme.sansBody(fontSize: 10, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              })
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

  const _VideoStoriesSection({
    required this.storiesKey,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Padding(
      key: storiesKey,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Visual Stories",
                style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text(
                "Capturing the moments.",
                style: AppTheme.serifHeader(fontSize: 32, height: 1.1),
              ),
              const SizedBox(height: 36),
              isDesktop
                  ? const Row(
                      children: [
                        Expanded(
                          child: VideoStoryCard(
                            posterAsset: "assets/images/birthday.jpg",
                            videoAsset: "assets/videos/Birthday.mp4",
                            tag: "Sample Films",
                            title: "A glimpse before the big day",
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: VideoStoryCard(
                            posterAsset: "assets/images/BaloonBlast.jpg",
                            videoAsset: "assets/videos/Balloonblast.mp4",
                            tag: "Intimate Surprises",
                            title: "Balloon Blast the perfect surprise",
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        VideoStoryCard(
                          posterAsset: "assets/images/birthday.jpg",
                          videoAsset: "assets/videos/Birthday.mp4",
                          tag: "Sample Films",
                          title: "A glimpse before the big day",
                        ),
                        const SizedBox(height: 32),
                        VideoStoryCard(
                          posterAsset: "assets/images/BaloonBlast.jpg",
                          videoAsset: "assets/videos/Balloonblast.mp4",
                          tag: "Intimate Surprises",
                          title: "Balloon Blast the perfect surprise",
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoStoryCard extends StatefulWidget {
  final String posterAsset;
  final String videoAsset;
  final String tag;
  final String title;

  const VideoStoryCard({
    super.key,
    required this.posterAsset,
    required this.videoAsset,
    required this.tag,
    required this.title,
  });

  @override
  State<VideoStoryCard> createState() => _VideoStoryCardState();
}

class _VideoStoryCardState extends State<VideoStoryCard> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          height: 480,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Video / Poster
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
              // Dark gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.72),
                      ],
                    ),
                  ),
                ),
              ),
              // Play/Pause indicator
              Center(
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
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
              // Labels
              Positioned(
                left: 24,
                bottom: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tag.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC39463),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                            style: AppTheme.sansBody(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.6),
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
            _drawerTile("COLLECTIONS", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(categoriesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("EXPERIENCES", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(catalogKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("STORIES", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(storiesKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("CONTACT", () {
              Navigator.pop(context);
              Scrollable.ensureVisible(contactKey.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            }),
            _drawerTile("DEVELOPER API", () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.docs);
            }),
            _drawerTile("TEAM STUDIO", () {
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
                color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15),
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
                  color: creamColor.withOpacity(0.65),

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

