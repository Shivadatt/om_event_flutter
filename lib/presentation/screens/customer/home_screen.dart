import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:om_event/core/services/business_details_service.dart';
import 'package:om_event/domain/entities/business_details_entity.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/extensions/extensions.dart';
import 'package:om_event/presentation/controllers/cart_controller.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/controllers/quotation_controller.dart';
import 'package:om_event/presentation/controllers/customer_auth_controller.dart';
import 'widgets/announcement_banner.dart';
import 'widgets/nav_drawer.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/customer_reviews_section.dart';
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
import 'widgets/home_sliver_app_bar.dart';

part 'parts/home_tab_navigation.dart';

class HomeScreen extends GetView<CatalogController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final quoteController = Get.find<QuotationController>();
    final authCtrl = Get.find<CustomerAuthController>();
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
    final isScrolled = ValueNotifier<bool>(false);

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > 50) {
            if (!isScrolled.value) isScrolled.value = true;
          } else {
            if (isScrolled.value) isScrolled.value = false;
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: AnnouncementBanner(isDesktop: isDesktop)),
            HomeSliverAppBar(
              scaffoldKey: scaffoldKey,
              cartController: cartController,
              authCtrl: authCtrl,
              isDesktop: isDesktop,
              isDark: isDark,
              categoriesKey: categoriesKey,
              catalogKey: catalogKey,
              storiesKey: storiesKey,
              contactKey: contactKey,
              scrollToSection: scrollToSection,
              isScrolled: isScrolled,
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
                CustomerReviewsSection(isDesktop: isDesktop),
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
      ),
      floatingActionButton: _buildWhatsAppFab(context),
    );
  }
}
