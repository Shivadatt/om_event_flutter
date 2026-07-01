import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/config/constants.dart';
import 'package:om_event/core/extensions/extensions.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/controllers/quotation_controller.dart';
import 'widgets/announcement_banner.dart';
import 'widgets/nav_drawer.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/home_hero_section.dart';
import 'widgets/home_marquee_ribbon.dart';
import 'widgets/home_benefits_section.dart';
import 'widgets/home_categories_section.dart';
import 'widgets/home_catalog_section.dart';
import 'widgets/home_video_stories_section.dart';
import 'widgets/home_process_section.dart';
import 'widgets/home_stats_band.dart';
import 'widgets/home_faq_section.dart';
import 'widgets/home_contact_section.dart';
import 'widgets/home_footer_section.dart';

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

    final width = context.screenWidth;
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

    final isDark = context.isDarkMode;

    return Scaffold(
      key: scaffoldKey,
      drawer: isDesktop
          ? null
          : NavDrawer(
              categoriesKey: categoriesKey,
              catalogKey: catalogKey,
              storiesKey: storiesKey,
              contactKey: contactKey,
            ),
      endDrawer: CartDrawer(
        cartController: cartController,
        quoteController: quoteController,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: AnnouncementBanner(isDesktop: isDesktop)),
          SliverAppBar(
            floating: true,
            pinned: true,
            toolbarHeight: 76,
            backgroundColor:
                isDark ? const Color(0xFF101C18) : const Color(0xFFFAF8F5),
            leading: isDesktop
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: isDark ? Colors.white : const Color(0xFF17201E),
                    ),
                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                  ),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white : const Color(0xFF17201E),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "OE",
                      style: AppTheme.serifHeader(
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF17201E),
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: AppTheme.serifHeader(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF17201E),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "MAKE IT MEMORABLE",
                      style: AppTheme.sansBody(
                        fontSize: 6,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF1E2B27),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                if (isDesktop) ...[
                  const Spacer(),
                  _navLink(
                    context,
                    "Collections",
                    () => scrollToSection(categoriesKey),
                  ),
                  _navLink(
                    context,
                    "Experiences",
                    () => scrollToSection(catalogKey),
                  ),
                  _navLink(
                    context,
                    "Stories",
                    () => scrollToSection(storiesKey),
                  ),
                  _navLink(
                    context,
                    "Contact",
                    () => scrollToSection(contactKey),
                  ),
                  _navLink(
                    context,
                    "Developer API",
                    () => Get.toNamed(AppRoutes.docs),
                  ),
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
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Selection",
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF17201E),
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E2B27),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$count',
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                color: isDark
                                    ? const Color(0xFF1B2925)
                                    : Colors.white,
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
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: const Color(0xFFD3AD7B),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: isDark ? Colors.white : const Color(0xFF17201E),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.login),
                ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroSection(scaffoldKey: scaffoldKey, isDesktop: isDesktop),
                const MarqueeRibbon(),
                BenefitsSection(isDesktop: isDesktop),
                CategoriesSection(
                  controller: controller,
                  categoriesKey: categoriesKey,
                  catalogKey: catalogKey,
                ),
                ExperiencesCatalogSection(
                  controller: controller,
                  cartController: cartController,
                  catalogKey: catalogKey,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                ),
                VideoStoriesSection(
                  storiesKey: storiesKey,
                  isDesktop: isDesktop,
                  catalogKey: catalogKey,
                ),
                ProcessSection(isDesktop: isDesktop),
                AnimatedStatsBand(isDesktop: isDesktop),
                FAQSection(isDesktop: isDesktop),
                ContactSection(
                  controller: controller,
                  contactKey: contactKey,
                  isDesktop: isDesktop,
                ),
                FooterSection(
                  isDesktop: isDesktop,
                  categoriesKey: categoriesKey,
                  catalogKey: catalogKey,
                  storiesKey: storiesKey,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final uri = Uri.parse(
            "https://wa.me/${AppConstants.businessPhone}?text=${Uri.encodeComponent(AppConstants.whatsappMessage)}",
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        backgroundColor: const Color(0xFF2C9B5D),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(
          "WHATSAPP US",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
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
