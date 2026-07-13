import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';
import 'package:om_event/domain/entities/contact_number_entity.dart';
import 'package:om_event/domain/repositories/settings_repository.dart';
import 'package:om_event/core/utils/validators.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/settings_notifications_tab.dart';
import 'maintenance_center_screen.dart';
import 'scheduler_health_screen.dart';

part 'parts/settings_fields.dart';
part 'parts/settings_saves.dart';
part 'parts/settings_dispose.dart';
part 'parts/settings_business_contacts.dart';
part 'parts/settings_business_contacts_add.dart';
part 'parts/settings_business_contacts_edit.dart';
part 'parts/settings_business_branch_card.dart';
part 'parts/settings_business_validation.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryAccent = const Color(0xFFD4AF37); // Metallic luxury gold
    final Color cardColor = isDark ? const Color(0xFF2A241F) : const Color(0xFFFAF6EE); // Luxury surface
    final Color borderColor = isDark ? const Color(0x26D4AF37) : const Color(0x1F000000);
    final Color textColor = isDark ? const Color(0xFFF7F2EA) : const Color(0xFF0F0D0B);
    final Color subtitleColor = isDark ? const Color(0xFFB6ADA4) : const Color(0xFF6B7280);

    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "STUDIO SYSTEM SETTINGS",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Left floating navigation rail
          Container(
            width: 250,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryAccent.withValues(alpha: 0.08) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? primaryAccent : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        _categories[index].toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryAccent : subtitleColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Form content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: _buildFormContent(),
              ),
            ),
          ),
        ],
      ),
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
