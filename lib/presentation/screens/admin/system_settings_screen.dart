import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/core/services/business_details_service.dart';
import 'package:om_event/domain/entities/business_details_entity.dart';
import 'package:om_event/domain/entities/settings_entities.dart';
import 'package:om_event/domain/entities/contact_number_entity.dart';
import 'package:om_event/domain/repositories/settings_repository.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/settings_notifications_tab.dart';
import 'widgets/luxury_gold_waves_painter.dart';
import 'package:om_event/core/config/feature_flags.dart';
import 'maintenance_center_screen.dart';
import 'scheduler_health_screen.dart';

import 'package:om_event/core/config/app_routes.dart';
import '../../controllers/business_details_controller.dart';

part 'parts/settings_fields.dart';
part 'parts/settings_saves.dart';
part 'parts/settings_dispose.dart';
part 'parts/settings_business_form.dart';
part 'parts/settings_marketing_form.dart';
part 'parts/settings_social_form.dart';
part 'parts/settings_operations_form.dart';
part 'parts/settings_advanced_form.dart';
part 'parts/settings_templates_form.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final SettingsRepository _repository = Get.find<SettingsRepository>();
  int _selectedIndex = 0;

  final _busName = TextEditingController(), _busCompany = TextEditingController(), _busPhone = TextEditingController(), _busEmail = TextEditingController();
  List<ContactNumberEntity> _contactNumbers = [];

  final _b1Name = TextEditingController(), _b1Address = TextEditingController(), _b1City = TextEditingController(), _b1State = TextEditingController(), _b1Country = TextEditingController(), _b1Pincode = TextEditingController(), _b1MapUrl = TextEditingController(), _b1Lat = TextEditingController(), _b1Lng = TextEditingController(), _b1Phone1 = TextEditingController(), _b1Phone2 = TextEditingController(), _b1Whatsapp = TextEditingController(), _b1Email = TextEditingController(), _b1Instagram = TextEditingController(), _b1Hours = TextEditingController();
  bool _b1IsPrimary = true;

  final _b2Name = TextEditingController(), _b2Address = TextEditingController(), _b2City = TextEditingController(), _b2State = TextEditingController(), _b2Country = TextEditingController(), _b2Pincode = TextEditingController(), _b2MapUrl = TextEditingController(), _b2Lat = TextEditingController(), _b2Lng = TextEditingController(), _b2Phone1 = TextEditingController(), _b2Phone2 = TextEditingController(), _b2Whatsapp = TextEditingController(), _b2Email = TextEditingController(), _b2Instagram = TextEditingController(), _b2Hours = TextEditingController();
  bool _b2IsPrimary = false;

  final _homeHeroTitle = TextEditingController(), _homeHeroSubtitle = TextEditingController();
  final _aboutDesc = TextEditingController(), _aboutMission = TextEditingController(), _aboutVision = TextEditingController(), _aboutStory = TextEditingController();
  final _contactPhone = TextEditingController(), _contactEmail = TextEditingController(), _contactWhatsapp = TextEditingController(), _contactAddress = TextEditingController(), _contactMaps = TextEditingController();
  final _footerDesc = TextEditingController(), _footerCopy = TextEditingController();
  final _seoTitle = TextEditingController(), _seoKeywords = TextEditingController(), _seoDesc = TextEditingController(), _seoCanonical = TextEditingController(), _seoRobots = TextEditingController();
  final _themePrimary = TextEditingController(), _themeSecondary = TextEditingController(), _themeAccent = TextEditingController(), _themeRadius = TextEditingController();
  final _priceGST = TextEditingController(), _priceDelivery = TextEditingController(), _priceTravel = TextEditingController(), _priceDiscount = TextEditingController();
  final _bookingAdvanceDays = TextEditingController(), _bookingWorkingHours = TextEditingController();
  final _notifPush = TextEditingController();
  final _pdfHeader = TextEditingController(), _pdfFooter = TextEditingController(), _pdfTerms = TextEditingController();
  final _invoiceTax = TextEditingController(), _invoiceNote = TextEditingController();
  final _analyticsId = TextEditingController();
  bool _analyticsEnable = false;
  final _dashboardWelcome = TextEditingController();
  final _maintenanceMsg = TextEditingController();
  final _appVersion = TextEditingController();
  final _socialInstagramKadi = TextEditingController(), _socialInstagramThangadh = TextEditingController();
  final _workHolidays = TextEditingController();
  final _policyPrivacy = TextEditingController(), _policyTerms = TextEditingController(), _policyRefund = TextEditingController();
  final _ctaText = TextEditingController(), _ctaUrl = TextEditingController();
  final _galleryColumns = TextEditingController();
  bool _galleryGridEnable = true;
  final _reviewsMinStars = TextEditingController();
  final _statEvents = TextEditingController(), _statClients = TextEditingController(), _statCities = TextEditingController(), _statYears = TextEditingController();
  final _faqTitle = TextEditingController();
  bool _faqAccordionEnable = true;

  final _emailTemplatesJson = TextEditingController(), _smsTemplatesJson = TextEditingController(), _formsValidationJson = TextEditingController(), _alertMessagesJson = TextEditingController(), _homeSectionsJson = TextEditingController(), _videoFilmsJson = TextEditingController();

  final List<String> _categories = [
    "Business Profile",
    "Homepage Copy",
    "About Details",
    "Contact Settings",
    "Footer Settings",
    "SEO Metadata",
    "Theme Styles",
    "Pricing Rules",
    "Booking Rules",
    "Notifications",
    "Email Templates",
    "SMS Templates",
    "PDF Details",
    "Invoice Settings",
    "Analytics Tools",
    "Admin Dashboard",
    "Feature Flags",
    "Maintenance Mode",
    "App Settings",
    "Social Redirects",
    "Working Hours",
    "Policy Texts",
    "Forms Validation",
    "Alert Messages",
    "Home Section Toggles",
    "Custom CTA",
    "Gallery Grid",
    "Video Films",
    "Reviews Filter",
    "Statistics Metrics",
    "FAQ Accordions",
    "Maintenance Center",
  ];

  @override
  void initState() {
    super.initState();
    _populateFields();
    _setupInitialPopulationListeners();
  }

  void _setupInitialPopulationListeners() {
    final config = AppConfigService.to;
    once(config.rxBusinessProfile, (_) => _populateFieldsIfMounted());
    once(config.rxHomepageSettings, (_) => _populateFieldsIfMounted());
    once(config.rxAboutSettings, (_) => _populateFieldsIfMounted());
    once(config.rxContactSettings, (_) => _populateFieldsIfMounted());
    once(config.rxFooterSettings, (_) => _populateFieldsIfMounted());
    once(config.rxSEOSettings, (_) => _populateFieldsIfMounted());
    once(config.rxThemeSettings, (_) => _populateFieldsIfMounted());
    once(config.rxPricingSettings, (_) => _populateFieldsIfMounted());
    once(config.rxBookingSettings, (_) => _populateFieldsIfMounted());
    once(config.rxNotificationsSettings, (_) => _populateFieldsIfMounted());
    once(config.rxPDFSettings, (_) => _populateFieldsIfMounted());
    once(config.rxInvoiceSettings, (_) => _populateFieldsIfMounted());
    once(config.rxAnalyticsSettings, (_) => _populateFieldsIfMounted());
    once(config.rxDashboardSettings, (_) => _populateFieldsIfMounted());
    once(config.rxMaintenanceSettings, (_) => _populateFieldsIfMounted());
    once(config.rxAppSettings, (_) => _populateFieldsIfMounted());
    once(config.rxWorkingHoursSettings, (_) => _populateFieldsIfMounted());
    once(config.rxPoliciesSettings, (_) => _populateFieldsIfMounted());
    once(config.rxCtaSettings, (_) => _populateFieldsIfMounted());
    once(config.rxGallerySettings, (_) => _populateFieldsIfMounted());
    once(config.rxReviewSettings, (_) => _populateFieldsIfMounted());
    once(config.rxStatisticsSettings, (_) => _populateFieldsIfMounted());
    once(config.rxFaqSettings, (_) => _populateFieldsIfMounted());
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _cardBg = Color(0xFF0C1511);

  IconData _getCategoryIcon(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('business profile')) return Icons.business_center_outlined;
    if (c.contains('homepage')) return Icons.auto_stories_outlined;
    if (c.contains('about')) return Icons.info_outline_rounded;
    if (c.contains('contact')) return Icons.perm_contact_calendar_outlined;
    if (c.contains('footer')) return Icons.view_agenda_outlined;
    if (c.contains('seo')) return Icons.travel_explore_outlined;
    if (c.contains('theme')) return Icons.palette_outlined;
    if (c.contains('pricing')) return Icons.monetization_on_outlined;
    if (c.contains('booking')) return Icons.event_available_outlined;
    if (c.contains('notification')) return Icons.notifications_outlined;
    if (c.contains('email')) return Icons.mail_outline_rounded;
    if (c.contains('sms')) return Icons.sms_outlined;
    if (c.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (c.contains('invoice')) return Icons.receipt_long_outlined;
    if (c.contains('analytics')) return Icons.analytics_outlined;
    if (c.contains('admin dashboard')) return Icons.dashboard_outlined;
    if (c.contains('feature flags')) return Icons.flag_outlined;
    if (c.contains('maintenance mode')) return Icons.power_settings_new_outlined;
    if (c.contains('app settings')) return Icons.settings_applications_outlined;
    if (c.contains('social redirects')) return Icons.share_outlined;
    if (c.contains('working hours')) return Icons.schedule_outlined;
    if (c.contains('policy')) return Icons.policy_outlined;
    if (c.contains('forms validation')) return Icons.checklist_rtl_outlined;
    if (c.contains('alert messages')) return Icons.warning_amber_rounded;
    if (c.contains('home section')) return Icons.layers_outlined;
    if (c.contains('cta')) return Icons.touch_app_outlined;
    if (c.contains('gallery grid')) return Icons.grid_view_outlined;
    if (c.contains('video films')) return Icons.video_library_outlined;
    if (c.contains('reviews filter')) return Icons.rate_review_outlined;
    if (c.contains('statistics metrics')) return Icons.bar_chart_outlined;
    if (c.contains('faq')) return Icons.help_outline_rounded;
    if (c.contains('maintenance center')) return Icons.build_circle_outlined;
    return Icons.settings_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. Option 4 Luxury Gold Wave Ribbons Background ───────
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LuxuryGoldWavesPainter(),
              ),
            ),
          ),

          // ── 2. Main Content Layer ──────────────────────────────────
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Eyebrow Header: STUDIO SYSTEM SETTINGS ───────────
                  Row(
                    children: [
                      if (!isInsideDrawer) ...[
                        const AdminBackButton(),
                        const SizedBox(width: 8),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "STUDIO SYSTEM SETTINGS",
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _goldColor,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            "SETTINGS",
                            style: GoogleFonts.dmSans(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w600,
                              color: _goldColor.withValues(alpha: 0.6),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Responsive Layout: Left Nav + Form Panel ───────
                  Expanded(
                    child: isMobile
                        ? _buildMobileLayout(context)
                        : _buildDesktopLayout(context, screenWidth),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop Layout: Side-by-Side Compact Workspace ─────────────────
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final navWidth = screenWidth < 1100 ? 210.0 : 230.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left Navigation Panel (Option 4 Compact Rail) ───────────
        Container(
          width: navWidth,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _goldColor.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 4, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "STUDIO SYSTEM SETTINGS",
                      style: GoogleFonts.dmSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _goldColor,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      "SETTINGS",
                      style: GoogleFonts.dmSans(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        color: _goldColor.withValues(alpha: 0.6),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedIndex;
                      final title = _categories[index];
                      final icon = _getCategoryIcon(title);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(9),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFFE5A93C), Color(0xFFC88A24)],
                                  )
                                : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _goldColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                size: 15,
                                color: isSelected ? const Color(0xFF0C1410) : _goldColor,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF0C1410) : Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // ── Main Form Area (Option 4 Compact Luxury Container) ──────
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            width: screenWidth >= 1050 ? 640 : (screenWidth - navWidth - 64).clamp(320.0, 640.0),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _goldColor.withValues(alpha: 0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout: Top Horizontal Tab Bar + Form Panel ─────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Horizontal Scrollable Tab Bar
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIndex;
              final title = _categories[index];
              final icon = _getCategoryIcon(title);

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFE5A93C), Color(0xFFC88A24)],
                          )
                        : null,
                    color: isSelected ? null : _cardBg,
                    borderRadius: BorderRadius.circular(9),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: _goldColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? const Color(0xFF0C1410) : _goldColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0C1410) : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Main Form Panel
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _goldColor.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildFormContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildBusinessForm();
      case 1:
        return _buildHomepageForm();
      case 2:
        return _buildAboutForm();
      case 3:
        return _buildContactForm();
      case 4:
        return _buildFooterForm();
      case 5:
        return _buildSEOForm();
      case 6:
        return _buildThemeForm();
      case 7:
        return _buildPricingForm();
      case 8:
        return _buildBookingForm();
      case 9:
        return _buildNotificationsForm();
      case 10:
        return _buildEmailTemplatesForm();
      case 11:
        return _buildSmsTemplatesForm();
      case 12:
        return _buildPDFForm();
      case 13:
        return _buildInvoiceForm();
      case 14:
        return _buildAnalyticsForm();
      case 15:
        return _buildDashboardForm();
      case 16:
        return _buildFeatureFlagsForm();
      case 17:
        return _buildMaintenanceForm();
      case 18:
        return _buildAppForm();
      case 19:
        return _buildSocialForm();
      case 20:
        return _buildWorkingHoursForm();
      case 21:
        return _buildPoliciesForm();
      case 22:
        return _buildValidationForm();
      case 23:
        return _buildAlertMessagesForm();
      case 24:
        return _buildHomeSectionsForm();
      case 25:
        return _buildCtaForm();
      case 26:
        return _buildGalleryGridForm();
      case 27:
        return _buildVideoFilmsForm();
      case 28:
        return _buildReviewsFilterForm();
      case 29:
        return _buildStatisticsForm();
      case 30:
        return _buildFaqAccordionsForm();
      case 31:
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final Color primaryAccentColor = const Color(0xFFD4AF37);
        final Color txtColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);
        final Color subColor = isDark ? const Color(0xFFB6ADA4) : const Color(0xFF6B7280);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "System Maintenance Center",
              style: AppTheme.sansBody(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Access migrations, database seeders, relationship repairs, dry runs, and validation checks from a centralized administrator dashboard.",
              style: AppTheme.sansBody(fontSize: 14, color: subColor),
            ),
            const SizedBox(height: 24),
            // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
            // REASON: Not required for current business flow.
            // DO NOT DELETE - Keep for future reactivation.
            if (FeatureFlags.advancedMaintenance) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccentColor,
                  foregroundColor: txtColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Get.to(() => const MaintenanceCenterScreen()),
                child: const Text(
                  "Open Maintenance Center",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
            // REASON: Not required for current business flow.
            // DO NOT DELETE - Keep for future reactivation.
            if (FeatureFlags.schedulerHealth) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryAccentColor,
                  side: BorderSide(color: primaryAccentColor.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.schedule_rounded, size: 18),
                onPressed: () => Get.to(() => const SchedulerHealthScreen()),
                label: const Text(
                  "Scheduler Health Dashboard",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (!FeatureFlags.advancedMaintenance && !FeatureFlags.schedulerHealth)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Advanced Maintenance & Scheduler Health tools are temporarily disabled for the current business flow.",
                        style: AppTheme.sansBody(fontSize: 13, color: subColor),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      default:
        return Center(
          child: Text(
            "${_categories[_selectedIndex]} settings are dynamic and fully operational.",
            style: AppTheme.sansBody(fontSize: 14),
          ),
        );
    }
  }
}
