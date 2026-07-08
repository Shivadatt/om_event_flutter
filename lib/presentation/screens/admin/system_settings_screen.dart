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
import 'widgets/settings_notifications_tab.dart';

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
  final _statEvents = TextEditingController(), _statClients = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(color: Color(0xFFC9A77E)),
        title: Text(
          "ENTERPRISE CMS SETTINGS PANEL",
          style: GoogleFonts.italiana(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.white12, width: 1),
              ),
            ),
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return ListTile(
                  title: Text(
                    _categories[index],
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? const Color(0xFFC9A77E) : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(child: _buildFormContent()),
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
