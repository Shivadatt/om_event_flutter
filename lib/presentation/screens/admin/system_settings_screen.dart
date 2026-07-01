import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';
import 'package:om_event/domain/repositories/settings_repository.dart';
import 'widgets/admin_back_button.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final SettingsRepository _repository = Get.find<SettingsRepository>();
  int _selectedIndex = 0;

  // Controllers for ALL 31 documents
  // 1. Business Profile & Office Branches
  final _busName = TextEditingController();
  final _busCompany = TextEditingController();
  final _busPhone = TextEditingController();
  final _busEmail = TextEditingController();

  // Branch 1
  final _b1Name = TextEditingController();
  final _b1Address = TextEditingController();
  final _b1City = TextEditingController();
  final _b1State = TextEditingController();
  final _b1Country = TextEditingController();
  final _b1Pincode = TextEditingController();
  final _b1MapUrl = TextEditingController();
  final _b1Lat = TextEditingController();
  final _b1Lng = TextEditingController();
  final _b1Phone1 = TextEditingController();
  final _b1Phone2 = TextEditingController();
  final _b1Whatsapp = TextEditingController();
  final _b1Email = TextEditingController();
  final _b1Instagram = TextEditingController();
  final _b1Hours = TextEditingController();
  bool _b1IsPrimary = true;

  // Branch 2
  final _b2Name = TextEditingController();
  final _b2Address = TextEditingController();
  final _b2City = TextEditingController();
  final _b2State = TextEditingController();
  final _b2Country = TextEditingController();
  final _b2Pincode = TextEditingController();
  final _b2MapUrl = TextEditingController();
  final _b2Lat = TextEditingController();
  final _b2Lng = TextEditingController();
  final _b2Phone1 = TextEditingController();
  final _b2Phone2 = TextEditingController();
  final _b2Whatsapp = TextEditingController();
  final _b2Email = TextEditingController();
  final _b2Instagram = TextEditingController();
  final _b2Hours = TextEditingController();
  bool _b2IsPrimary = false;

  // 2. Homepage Copy
  final _homeHeroTitle = TextEditingController();
  final _homeHeroSubtitle = TextEditingController();

  // 3. About Details
  final _aboutDesc = TextEditingController();
  final _aboutMission = TextEditingController();
  final _aboutVision = TextEditingController();
  final _aboutStory = TextEditingController();

  // 4. Contact Settings
  final _contactPhone = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactWhatsapp = TextEditingController();
  final _contactAddress = TextEditingController();
  final _contactMaps = TextEditingController();

  // 5. Footer Settings
  final _footerDesc = TextEditingController();
  final _footerCopy = TextEditingController();

  // 6. SEO Metadata
  final _seoTitle = TextEditingController();
  final _seoKeywords = TextEditingController();
  final _seoDesc = TextEditingController();
  final _seoCanonical = TextEditingController();
  final _seoRobots = TextEditingController();

  // 7. Theme Styles
  final _themePrimary = TextEditingController();
  final _themeSecondary = TextEditingController();
  final _themeAccent = TextEditingController();
  final _themeRadius = TextEditingController();

  // 8. Pricing Rules
  final _priceGST = TextEditingController();
  final _priceDelivery = TextEditingController();
  final _priceTravel = TextEditingController();
  final _priceDiscount = TextEditingController();

  // 9. Booking Rules
  final _bookingAdvanceDays = TextEditingController();
  final _bookingWorkingHours = TextEditingController();

  // 10. Notifications
  final _notifPush = TextEditingController();

  // 13. PDF Details
  final _pdfHeader = TextEditingController();
  final _pdfFooter = TextEditingController();
  final _pdfTerms = TextEditingController();

  // 14. Invoice Settings
  final _invoiceTax = TextEditingController();
  final _invoiceNote = TextEditingController();

  // 15. Analytics Tools
  final _analyticsId = TextEditingController();
  bool _analyticsEnable = false;

  // 16. Admin Dashboard
  final _dashboardWelcome = TextEditingController();

  // 18. Maintenance Mode
  final _maintenanceMsg = TextEditingController();

  // 19. App Settings
  final _appVersion = TextEditingController();

  // 20. Social Redirects (Instagram only)
  final _socialInstagramKadi = TextEditingController();
  final _socialInstagramThangadh = TextEditingController();

  // 21. Working Hours
  final _workHolidays = TextEditingController();

  // 22. Policy Texts
  final _policyPrivacy = TextEditingController();
  final _policyTerms = TextEditingController();
  final _policyRefund = TextEditingController();

  // 26. Custom CTA
  final _ctaText = TextEditingController();
  final _ctaUrl = TextEditingController();

  // 27. Gallery Grid
  final _galleryColumns = TextEditingController();
  bool _galleryGridEnable = true;

  // 29. Reviews Filter
  final _reviewsMinStars = TextEditingController();

  // 30. Statistics Metrics
  final _statEvents = TextEditingController();
  final _statClients = TextEditingController();

  // 31. FAQ Accordions
  final _faqTitle = TextEditingController();
  bool _faqAccordionEnable = true;

  // Advanced JSON settings controllers for the 6 missing categories
  final _emailTemplatesJson = TextEditingController();
  final _smsTemplatesJson = TextEditingController();
  final _formsValidationJson = TextEditingController();
  final _alertMessagesJson = TextEditingController();
  final _homeSectionsJson = TextEditingController();
  final _videoFilmsJson = TextEditingController();

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

  void _populateFieldsIfMounted() {
    if (mounted) {
      setState(() {
        _populateFields();
      });
    }
  }

  void _populateFields() {
    final bus = AppConfigService.to.rxBusinessProfile.value;
    _busName.text = bus.name;
    _busCompany.text = bus.companyName;
    _busPhone.text = bus.phone;
    _busEmail.text = bus.email;

    final branches = bus.officeBranches;
    if (branches.isNotEmpty) {
      final b1 = branches[0];
      _b1Name.text = b1.branchName;
      _b1Address.text = b1.address;
      _b1City.text = b1.city;
      _b1State.text = b1.state;
      _b1Country.text = b1.country;
      _b1Pincode.text = b1.pincode;
      _b1MapUrl.text = b1.googleMapUrl;
      _b1Lat.text = b1.latitude;
      _b1Lng.text = b1.longitude;
      _b1Phone1.text = b1.phone1;
      _b1Phone2.text = b1.phone2;
      _b1Whatsapp.text = b1.whatsapp;
      _b1Email.text = b1.email;
      _b1Instagram.text = b1.instagram;
      _b1Hours.text = b1.businessHours;
      _b1IsPrimary = b1.isPrimary;
    }

    if (branches.length > 1) {
      final b2 = branches[1];
      _b2Name.text = b2.branchName;
      _b2Address.text = b2.address;
      _b2City.text = b2.city;
      _b2State.text = b2.state;
      _b2Country.text = b2.country;
      _b2Pincode.text = b2.pincode;
      _b2MapUrl.text = b2.googleMapUrl;
      _b2Lat.text = b2.latitude;
      _b2Lng.text = b2.longitude;
      _b2Phone1.text = b2.phone1;
      _b2Phone2.text = b2.phone2;
      _b2Whatsapp.text = b2.whatsapp;
      _b2Email.text = b2.email;
      _b2Instagram.text = b2.instagram;
      _b2Hours.text = b2.businessHours;
      _b2IsPrimary = b2.isPrimary;
    }

    final home = AppConfigService.to.rxHomepageSettings.value;
    _homeHeroTitle.text = home.heroTitle;
    _homeHeroSubtitle.text = home.heroSubtitle;

    final about = AppConfigService.to.rxAboutSettings.value;
    _aboutDesc.text = about.description;
    _aboutMission.text = about.mission;
    _aboutVision.text = about.vision;
    _aboutStory.text = about.story;

    final contact = AppConfigService.to.rxContactSettings.value;
    _contactPhone.text = contact.phone;
    _contactEmail.text = contact.email;
    _contactWhatsapp.text = contact.whatsapp;
    _contactAddress.text = contact.address;
    _contactMaps.text = contact.googleMaps;

    final footer = AppConfigService.to.rxFooterSettings.value;
    _footerDesc.text = footer.description;
    _footerCopy.text = footer.copyright;

    final seo = AppConfigService.to.rxSEOSettings.value;
    _seoTitle.text = seo.defaultTitle;
    _seoKeywords.text = seo.keywords;
    _seoDesc.text = seo.metaDescription;
    _seoCanonical.text = seo.canonicalUrl;
    _seoRobots.text = seo.robots;

    final theme = AppConfigService.to.rxThemeSettings.value;
    _themePrimary.text = theme.primaryColor;
    _themeSecondary.text = theme.secondaryColor;
    _themeAccent.text = theme.accentColor;
    _themeRadius.text = theme.borderRadius.toString();

    final price = AppConfigService.to.rxPricingSettings.value;
    _priceGST.text = price.gst.toString();
    _priceDelivery.text = price.deliveryCharge.toString();
    _priceTravel.text = price.travelCharge.toString();
    _priceDiscount.text = price.discount.toString();

    final booking = AppConfigService.to.rxBookingSettings.value;
    _bookingAdvanceDays.text = booking.advanceDays.toString();
    _bookingWorkingHours.text = booking.workingHours;

    final pdf = AppConfigService.to.rxPDFSettings.value;
    _pdfHeader.text = pdf.invoiceHeader;
    _pdfFooter.text = pdf.invoiceFooter;
    _pdfTerms.text = pdf.terms;

    final invoice = AppConfigService.to.rxInvoiceSettings.value;
    _invoiceTax.text = invoice.taxNumber;
    _invoiceNote.text = invoice.invoiceNote;

    final analytics = AppConfigService.to.rxAnalyticsSettings.value;
    _analyticsId.text = analytics.measurementId;
    _analyticsEnable = analytics.enableTracking;

    final dash = AppConfigService.to.rxDashboardSettings.value;
    _dashboardWelcome.text = dash.welcomeMessage;

    final app = AppConfigService.to.rxAppSettings.value;
    _appVersion.text = app.version;

    final maint = AppConfigService.to.rxMaintenanceSettings.value;
    _maintenanceMsg.text = maint.message;

    final busProfile = AppConfigService.to.rxBusinessProfile.value;
    _socialInstagramKadi.text = busProfile.socialLinks['instagram_kadi'] ?? '';
    _socialInstagramThangadh.text =
        busProfile.socialLinks['instagram_thangadh'] ?? '';

    final work = AppConfigService.to.rxWorkingHoursSettings.value;
    _workHolidays.text = work.holidays.join(", ");

    final policies = AppConfigService.to.rxPoliciesSettings.value;
    _policyPrivacy.text = policies.privacyPolicy;
    _policyTerms.text = policies.termsOfService;
    _policyRefund.text = policies.refundPolicy;

    final cta = AppConfigService.to.rxCtaSettings.value;
    _ctaText.text = cta.buttonText;
    _ctaUrl.text = cta.buttonUrl;

    final gall = AppConfigService.to.rxGallerySettings.value;
    _galleryColumns.text = gall.columns.toString();
    _galleryGridEnable = gall.enableGrid;

    final reviews = AppConfigService.to.rxReviewSettings.value;
    _reviewsMinStars.text = reviews.minimumStars.toString();

    final stats = AppConfigService.to.rxStatisticsSettings.value;
    _statEvents.text = stats.completedEvents.toString();
    _statClients.text = stats.happyClients.toString();

    final faq = AppConfigService.to.rxFaqSettings.value;
    _faqTitle.text = faq.title;
    _faqAccordionEnable = faq.enableAccordion;

    // Populate advanced JSON templates
    final emailT = AppConfigService.to.rxEmailTemplatesSettings.value;
    _emailTemplatesJson.text = const JsonEncoder.withIndent(
      "  ",
    ).convert(emailT.templates);

    final smsT = AppConfigService.to.rxSmsTemplatesSettings.value;
    _smsTemplatesJson.text = const JsonEncoder.withIndent(
      "  ",
    ).convert(smsT.templates);

    final valS = AppConfigService.to.rxValidationSettings.value;
    _formsValidationJson.text = const JsonEncoder.withIndent(
      "  ",
    ).convert(valS.validationRules);

    final msgS = AppConfigService.to.rxMessagesSettings.value;
    _alertMessagesJson.text = const JsonEncoder.withIndent(
      "  ",
    ).convert(msgS.customMessages);

    final secS = AppConfigService.to.rxHomeSectionsSettings.value;
    _homeSectionsJson.text = const JsonEncoder.withIndent(
      "  ",
    ).convert(secS.activeSections);

    final vidS = AppConfigService.to.rxVideoSettings.value;
    _videoFilmsJson.text = const JsonEncoder.withIndent(
      "  ",
    ).convert(vidS.videosList);
  }

  Future<void> _saveAndPublish(
    String docId,
    Future<void> Function() saveCall,
  ) async {
    try {
      await saveCall();
      await _repository.publishSettings(docId);
      Get.snackbar(
        "CMS Console",
        "${docId.toUpperCase()} settings saved and published reactively.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E2C27),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "CMS error: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _busName.dispose();
    _busCompany.dispose();
    _busPhone.dispose();
    _busEmail.dispose();
    _b1Name.dispose();
    _b1Address.dispose();
    _b1City.dispose();
    _b1State.dispose();
    _b1Country.dispose();
    _b1Pincode.dispose();
    _b1MapUrl.dispose();
    _b1Lat.dispose();
    _b1Lng.dispose();
    _b1Phone1.dispose();
    _b1Phone2.dispose();
    _b1Whatsapp.dispose();
    _b1Email.dispose();
    _b1Instagram.dispose();
    _b1Hours.dispose();
    _b2Name.dispose();
    _b2Address.dispose();
    _b2City.dispose();
    _b2State.dispose();
    _b2Country.dispose();
    _b2Pincode.dispose();
    _b2MapUrl.dispose();
    _b2Lat.dispose();
    _b2Lng.dispose();
    _b2Phone1.dispose();
    _b2Phone2.dispose();
    _b2Whatsapp.dispose();
    _b2Email.dispose();
    _b2Instagram.dispose();
    _b2Hours.dispose();
    _homeHeroTitle.dispose();
    _homeHeroSubtitle.dispose();
    _aboutDesc.dispose();
    _aboutMission.dispose();
    _aboutVision.dispose();
    _aboutStory.dispose();
    _contactPhone.dispose();
    _contactEmail.dispose();
    _contactWhatsapp.dispose();
    _contactAddress.dispose();
    _contactMaps.dispose();
    _footerDesc.dispose();
    _footerCopy.dispose();
    _seoTitle.dispose();
    _seoKeywords.dispose();
    _seoDesc.dispose();
    _seoCanonical.dispose();
    _seoRobots.dispose();
    _themePrimary.dispose();
    _themeSecondary.dispose();
    _themeAccent.dispose();
    _themeRadius.dispose();
    _priceGST.dispose();
    _priceDelivery.dispose();
    _priceTravel.dispose();
    _priceDiscount.dispose();
    _bookingAdvanceDays.dispose();
    _bookingWorkingHours.dispose();
    _notifPush.dispose();
    _pdfHeader.dispose();
    _pdfFooter.dispose();
    _pdfTerms.dispose();
    _invoiceTax.dispose();
    _invoiceNote.dispose();
    _analyticsId.dispose();
    _dashboardWelcome.dispose();
    _maintenanceMsg.dispose();
    _appVersion.dispose();
    _socialInstagramKadi.dispose();
    _socialInstagramThangadh.dispose();
    _workHolidays.dispose();
    _policyPrivacy.dispose();
    _policyTerms.dispose();
    _policyRefund.dispose();
    _ctaText.dispose();
    _ctaUrl.dispose();
    _galleryColumns.dispose();
    _reviewsMinStars.dispose();
    _statEvents.dispose();
    _statClients.dispose();
    _faqTitle.dispose();
    _emailTemplatesJson.dispose();
    _smsTemplatesJson.dispose();
    _formsValidationJson.dispose();
    _alertMessagesJson.dispose();
    _homeSectionsJson.dispose();
    _videoFilmsJson.dispose();
    super.dispose();
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

  Widget _jsonField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.italiana(
            fontSize: 18,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 15,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            fillColor: const Color(0xFF131D1A),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF254235)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            try {
              jsonDecode(value);
              return null;
            } catch (e) {
              return "Invalid JSON syntax: $e";
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmailTemplatesForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EMAIL TEMPLATES CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Templates JSON Map", _emailTemplatesJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('email_templates', () async {
                  final decoded =
                      jsonDecode(_emailTemplatesJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveEmailTemplates(
                    EmailTemplatesSettings(templates: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsTemplatesForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SMS TEMPLATES CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Templates JSON Map", _smsTemplatesJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('sms_templates', () async {
                  final decoded =
                      jsonDecode(_smsTemplatesJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveSmsTemplates(
                    SmsTemplatesSettings(templates: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FORMS VALIDATION CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Validation Rules JSON Map", _formsValidationJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('validation', () async {
                  final decoded =
                      jsonDecode(_formsValidationJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveValidation(
                    ValidationSettings(validationRules: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMessagesForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ALERT MESSAGES CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Custom Messages JSON Map", _alertMessagesJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('messages', () async {
                  final decoded =
                      jsonDecode(_alertMessagesJson.text)
                          as Map<String, dynamic>;
                  await _repository.saveMessages(
                    MessagesSettings(customMessages: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSectionsForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HOME SECTIONS CONFIG",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _jsonField("Active Sections JSON List", _homeSectionsJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('home_sections', () async {
                  final decoded =
                      jsonDecode(_homeSectionsJson.text) as List<dynamic>;
                  await _repository.saveHomeSections(
                    HomeSectionsSettings(activeSections: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFilmsForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("VIDEO FILMS CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
          const SizedBox(height: 24),
          _jsonField("Videos JSON List", _videoFilmsJson),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('video_settings', () async {
                  final decoded =
                      jsonDecode(_videoFilmsJson.text) as List<dynamic>;
                  await _repository.saveVideoSettings(
                    VideoSettings(videosList: decoded),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
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

  bool _validateBranchInputs() {
    if (_busName.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Business name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    // Branch 1
    if (_b1Name.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1Address.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Address is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1City.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 City is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1State.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 State is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1Country.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Country is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b1Phone1.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 1 Primary Phone is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Branch 2
    if (_b2Name.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2Address.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Address is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2City.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 City is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2State.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 State is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2Country.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Country is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (_b2Phone1.text.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Branch 2 Primary Phone is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  Widget _buildBranchCard({
    required String title,
    required TextEditingController nameCtrl,
    required TextEditingController addressCtrl,
    required TextEditingController cityCtrl,
    required TextEditingController stateCtrl,
    required TextEditingController countryCtrl,
    required TextEditingController pinCtrl,
    required TextEditingController mapCtrl,
    required TextEditingController latCtrl,
    required TextEditingController lngCtrl,
    required TextEditingController phone1Ctrl,
    required TextEditingController phone2Ctrl,
    required TextEditingController whatsappCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController instaCtrl,
    required TextEditingController hoursCtrl,
    required bool isPrimary,
    required ValueChanged<bool> onPrimaryChanged,
  }) {
    return Card(
      color: const Color(0xFF131D1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC9A77E), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 24),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.location_on, color: Color(0xFFC9A77E)),
          title: Text(
            title,
            style: GoogleFonts.italiana(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC9A77E),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text(
                      "Set as Primary Branch",
                      style: AppTheme.sansBody(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    value: isPrimary,
                    activeColor: const Color(0xFFC9A77E),
                    onChanged: onPrimaryChanged,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _field("Branch Name *", nameCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Business Hours", hoursCtrl)),
                    ],
                  ),
                  _field("Office Address *", addressCtrl),
                  Row(
                    children: [
                      Expanded(child: _field("City *", cityCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("State *", stateCtrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field("Country *", countryCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Pincode", pinCtrl)),
                    ],
                  ),
                  _field("Google Maps URL", mapCtrl),
                  Row(
                    children: [
                      Expanded(child: _field("Latitude", latCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Longitude", lngCtrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field("Primary Contact *", phone1Ctrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Secondary Contact", phone2Ctrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field("WhatsApp Number", whatsappCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Email Address", emailCtrl)),
                    ],
                  ),
                  _field("Instagram URL", instaCtrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BUSINESS PROFILE", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Business Name *", _busName),
        _field("Company Name", _busCompany),
        _field("General Support Phone", _busPhone),
        _field("General Support Email", _busEmail),
        const SizedBox(height: 32),
        Text(
          "OFFICE BRANCHES",
          style: GoogleFonts.italiana(
            fontSize: 20,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 16),
        _buildBranchCard(
          title:
              "Branch 1: ${_b1Name.text.isNotEmpty ? _b1Name.text : 'Main Office'}",
          nameCtrl: _b1Name,
          addressCtrl: _b1Address,
          cityCtrl: _b1City,
          stateCtrl: _b1State,
          countryCtrl: _b1Country,
          pinCtrl: _b1Pincode,
          mapCtrl: _b1MapUrl,
          latCtrl: _b1Lat,
          lngCtrl: _b1Lng,
          phone1Ctrl: _b1Phone1,
          phone2Ctrl: _b1Phone2,
          whatsappCtrl: _b1Whatsapp,
          emailCtrl: _b1Email,
          instaCtrl: _b1Instagram,
          hoursCtrl: _b1Hours,
          isPrimary: _b1IsPrimary,
          onPrimaryChanged: (val) {
            setState(() {
              _b1IsPrimary = val;
              if (val) _b2IsPrimary = false;
            });
          },
        ),
        _buildBranchCard(
          title:
              "Branch 2: ${_b2Name.text.isNotEmpty ? _b2Name.text : 'Secondary Office'}",
          nameCtrl: _b2Name,
          addressCtrl: _b2Address,
          cityCtrl: _b2City,
          stateCtrl: _b2State,
          countryCtrl: _b2Country,
          pinCtrl: _b2Pincode,
          mapCtrl: _b2MapUrl,
          latCtrl: _b2Lat,
          lngCtrl: _b2Lng,
          phone1Ctrl: _b2Phone1,
          phone2Ctrl: _b2Phone2,
          whatsappCtrl: _b2Whatsapp,
          emailCtrl: _b2Email,
          instaCtrl: _b2Instagram,
          hoursCtrl: _b2Hours,
          isPrimary: _b2IsPrimary,
          onPrimaryChanged: (val) {
            setState(() {
              _b2IsPrimary = val;
              if (val) _b1IsPrimary = false;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('business', () async {
                if (!_validateBranchInputs()) return;

                final updatedBranches = [
                  OfficeBranch(
                    id: "branch_1",
                    branchName: _b1Name.text,
                    address: _b1Address.text,
                    city: _b1City.text,
                    state: _b1State.text,
                    country: _b1Country.text,
                    pincode: _b1Pincode.text,
                    googleMapUrl: _b1MapUrl.text,
                    latitude: _b1Lat.text,
                    longitude: _b1Lng.text,
                    phone1: _b1Phone1.text,
                    phone2: _b1Phone2.text,
                    whatsapp: _b1Whatsapp.text,
                    email: _b1Email.text,
                    instagram: _b1Instagram.text,
                    businessHours: _b1Hours.text,
                    isPrimary: _b1IsPrimary,
                  ),
                  OfficeBranch(
                    id: "branch_2",
                    branchName: _b2Name.text,
                    address: _b2Address.text,
                    city: _b2City.text,
                    state: _b2State.text,
                    country: _b2Country.text,
                    pincode: _b2Pincode.text,
                    googleMapUrl: _b2MapUrl.text,
                    latitude: _b2Lat.text,
                    longitude: _b2Lng.text,
                    phone1: _b2Phone1.text,
                    phone2: _b2Phone2.text,
                    whatsapp: _b2Whatsapp.text,
                    email: _b2Email.text,
                    instagram: _b2Instagram.text,
                    businessHours: _b2Hours.text,
                    isPrimary: _b2IsPrimary,
                  ),
                ];

                final primaryBranch = updatedBranches.firstWhere(
                  (b) => b.isPrimary,
                  orElse: () => updatedBranches.first,
                );

                final busCurrent = AppConfigService.to.rxBusinessProfile.value;
                await _repository.saveBusiness(
                  BusinessProfile(
                    name: _busName.text,
                    companyName: _busCompany.text,
                    logo: busCurrent.logo,
                    whiteLogo: busCurrent.whiteLogo,
                    favicon: busCurrent.favicon,
                    gst: busCurrent.gst,
                    pan: busCurrent.pan,
                    ownerName: busCurrent.ownerName,
                    phone: primaryBranch.phone1,
                    email:
                        primaryBranch.email.isNotEmpty
                            ? primaryBranch.email
                            : busCurrent.email,
                    whatsapp:
                        primaryBranch.whatsapp.isNotEmpty
                            ? primaryBranch.whatsapp
                            : busCurrent.whatsapp,
                    officeBranches: updatedBranches,
                    workingHours:
                        primaryBranch.businessHours.isNotEmpty
                            ? primaryBranch.businessHours
                            : busCurrent.workingHours,
                    socialLinks: busCurrent.socialLinks,
                  ),
                );

                // Also update contact settings for compatibility
                await _repository.saveContact(
                  ContactSettings(
                    phone: primaryBranch.phone1,
                    email: primaryBranch.email,
                    whatsapp: primaryBranch.whatsapp,
                    address: primaryBranch.address,
                    googleMaps: primaryBranch.googleMapUrl,
                    branches: updatedBranches.map((b) => b.toMap()).toList(),
                  ),
                );
                await _repository.publishSettings('contact');
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildHomepageForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("HOMEPAGE COPYWRITING", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Hero Title", _homeHeroTitle),
        _field("Hero Subtitle", _homeHeroSubtitle),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('homepage', () async {
                final current = AppConfigService.to.rxHomepageSettings.value;
                await _repository.saveHomepage(
                  HomepageSettings(
                    heroTitle: _homeHeroTitle.text,
                    heroSubtitle: _homeHeroSubtitle.text,
                    heroEyebrow: current.heroEyebrow,
                    heroButtons: current.heroButtons,
                    heroImages: current.heroImages,
                    heroVideo: current.heroVideo,
                    heroBadge: current.heroBadge,
                    statistics: current.statistics,
                    benefits: current.benefits,
                    faqs: current.faqs,
                    about: current.about,
                    cta: current.cta,
                    whyChooseUs: current.whyChooseUs,
                    galleryHeader: current.galleryHeader,
                    reviewHeader: current.reviewHeader,
                    faqHeader: current.faqHeader,
                    sectionVisibility: current.sectionVisibility,
                    sectionOrder: current.sectionOrder,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildAboutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ABOUT US DETAILS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Description", _aboutDesc),
        _field("Mission", _aboutMission),
        _field("Vision", _aboutVision),
        _field("Story Text", _aboutStory),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('about', () async {
                await _repository.saveAbout(
                  AboutSettings(
                    description: _aboutDesc.text,
                    mission: _aboutMission.text,
                    vision: _aboutVision.text,
                    story: _aboutStory.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CONTACT DETAILS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Contact Phone", _contactPhone),
        _field("Contact Email", _contactEmail),
        _field("WhatsApp prefilled text", _contactWhatsapp),
        _field("Google Maps URL", _contactMaps),
        const SizedBox(height: 12),
        Text(
          "Note: Branch office addresses, city, pin code and geolocations are managed dynamically under the 'Business Profile' tab.",
          style: AppTheme.sansBody(
            fontSize: 12,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('contact', () async {
                final bus = AppConfigService.to.rxBusinessProfile.value;
                final primaryBranch = bus.officeBranches.firstWhere(
                  (b) => b.isPrimary,
                  orElse: () => bus.officeBranches.first,
                );

                await _repository.saveContact(
                  ContactSettings(
                    phone: _contactPhone.text,
                    email: _contactEmail.text,
                    whatsapp: _contactWhatsapp.text,
                    address: primaryBranch.address,
                    googleMaps: _contactMaps.text,
                    branches: bus.officeBranches.map((b) => b.toMap()).toList(),
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildFooterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FOOTER CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Footer Description", _footerDesc),
        _field("Copyright line", _footerCopy),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('footer', () async {
                final current = AppConfigService.to.rxFooterSettings.value;
                await _repository.saveFooter(
                  FooterSettings(
                    description: _footerDesc.text,
                    copyright: _footerCopy.text,
                    quickLinks: current.quickLinks,
                    legalLinks: current.legalLinks,
                    contact: current.contact,
                    socialLinks: current.socialLinks,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildSEOForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEO META CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Default Page Title", _seoTitle),
        _field("Meta Keywords (comma separated)", _seoKeywords),
        _field("Meta Description", _seoDesc),
        _field("Canonical URL", _seoCanonical),
        _field("Robots settings", _seoRobots),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('seo', () async {
                final current = AppConfigService.to.rxSEOSettings.value;
                await _repository.saveSEO(
                  SEOSettings(
                    defaultTitle: _seoTitle.text,
                    metaDescription: _seoDesc.text,
                    keywords: _seoKeywords.text,
                    canonicalUrl: _seoCanonical.text,
                    openGraph: current.openGraph,
                    twitterCard: current.twitterCard,
                    jsonLd: current.jsonLd,
                    robots: _seoRobots.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildThemeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("THEME STYLES", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Primary Hex Color", _themePrimary),
        _field("Secondary Hex Color", _themeSecondary),
        _field("Accent Hex Color", _themeAccent),
        _field("Default Border Radius", _themeRadius),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('theme', () async {
                final current = AppConfigService.to.rxThemeSettings.value;
                await _repository.saveTheme(
                  ThemeSettings(
                    primaryColor: _themePrimary.text,
                    secondaryColor: _themeSecondary.text,
                    accentColor: _themeAccent.text,
                    darkColors: current.darkColors,
                    lightColors: current.lightColors,
                    typography: current.typography,
                    borderRadius:
                        double.tryParse(_themeRadius.text) ??
                        current.borderRadius,
                    buttonStyle: current.buttonStyle,
                    cardStyle: current.cardStyle,
                    animationSpeed: current.animationSpeed,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildPricingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PRICING & GST RULES", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("GST percentage", _priceGST),
        _field("Flat delivery charge", _priceDelivery),
        _field("Travel charge per km", _priceTravel),
        _field("Default discount amount", _priceDiscount),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('pricing', () async {
                final current = AppConfigService.to.rxPricingSettings.value;
                await _repository.savePricing(
                  PricingSettings(
                    gst: double.tryParse(_priceGST.text) ?? current.gst,
                    deliveryCharge:
                        double.tryParse(_priceDelivery.text) ??
                        current.deliveryCharge,
                    travelCharge:
                        double.tryParse(_priceTravel.text) ??
                        current.travelCharge,
                    discount:
                        double.tryParse(_priceDiscount.text) ??
                        current.discount,
                    coupons: current.coupons,
                    advanceAmount: current.advanceAmount,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BOOKING PROTOCOLS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Advance Booking Offset Days", _bookingAdvanceDays),
        _field("Business hours", _bookingWorkingHours),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('booking', () async {
                final current = AppConfigService.to.rxBookingSettings.value;
                await _repository.saveBooking(
                  BookingSettings(
                    bookingRules: current.bookingRules,
                    advanceDays:
                        int.tryParse(_bookingAdvanceDays.text) ??
                        current.advanceDays,
                    workingHours: _bookingWorkingHours.text,
                    cancellationRules: current.cancellationRules,
                    refundRules: current.refundRules,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildNotificationsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "NOTIFICATIONS INTEGRATION",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Push Alerts Title", _notifPush),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('notifications', () async {
                final current =
                    AppConfigService.to.rxNotificationsSettings.value;
                await _repository.saveNotifications(
                  NotificationsSettings(
                    pushTemplates: {'title': _notifPush.text},
                    smsTemplates: current.smsTemplates,
                    emailTemplates: current.emailTemplates,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildPDFForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PDF ESTIMATE CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Invoice Document Header", _pdfHeader),
        _field("Invoice Document Footer", _pdfFooter),
        _field("Invoice Terms conditions", _pdfTerms),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('pdf', () async {
                final current = AppConfigService.to.rxPDFSettings.value;
                await _repository.savePDF(
                  PDFSettings(
                    invoiceHeader: _pdfHeader.text,
                    invoiceFooter: _pdfFooter.text,
                    terms: _pdfTerms.text,
                    bankDetails: current.bankDetails,
                    upi: current.upi,
                    signature: current.signature,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildInvoiceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INVOICE SETTINGS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Tax Registration ID", _invoiceTax),
        _field("Default Invoice Note", _invoiceNote),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('invoice', () async {
                await _repository.saveInvoice(
                  InvoiceSettings(
                    taxNumber: _invoiceTax.text,
                    invoiceNote: _invoiceNote.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildAnalyticsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ANALYTICS INTEGRATION",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Measurement ID (GA4)", _analyticsId),
        CheckboxListTile(
          title: const Text("Enable Analytics Tracking"),
          value: _analyticsEnable,
          onChanged: (v) {
            setState(() {
              _analyticsEnable = v ?? false;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('analytics', () async {
                await _repository.saveAnalytics(
                  AnalyticsSettings(
                    measurementId: _analyticsId.text,
                    enableTracking: _analyticsEnable,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildDashboardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ADMIN DASHBOARD CONFIG",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Admin Welcome Message", _dashboardWelcome),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('dashboard', () async {
                final current = AppConfigService.to.rxDashboardSettings.value;
                await _repository.saveDashboard(
                  DashboardSettings(
                    welcomeMessage: _dashboardWelcome.text,
                    activeWidgets: current.activeWidgets,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildFeatureFlagsForm() {
    return Obx(() {
      final flags = AppConfigService.to.rxFeatureFlagsSettings.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SYSTEM FEATURE FLAGS",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text("Enable Reviews Section"),
            value: flags.enableReviews,
            onChanged: (v) => _updateFeatureFlags(enableReviews: v),
          ),
          SwitchListTile(
            title: const Text("Enable Gallery Section"),
            value: flags.enableGallery,
            onChanged: (v) => _updateFeatureFlags(enableGallery: v),
          ),
          SwitchListTile(
            title: const Text("Enable Self Booking Mode"),
            value: flags.enableBooking,
            onChanged: (v) => _updateFeatureFlags(enableBooking: v),
          ),
          SwitchListTile(
            title: const Text("Enable Online Payments Integration"),
            value: flags.enablePayments,
            onChanged: (v) => _updateFeatureFlags(enablePayments: v),
          ),
        ],
      );
    });
  }

  Future<void> _updateFeatureFlags({
    bool? enableReviews,
    bool? enableGallery,
    bool? enableBooking,
    bool? enablePayments,
  }) async {
    final current = AppConfigService.to.rxFeatureFlagsSettings.value;
    await _saveAndPublish('feature_flags', () async {
      await _repository.saveFeatureFlags(
        FeatureFlagsSettings(
          enableReviews: enableReviews ?? current.enableReviews,
          enableGallery: enableGallery ?? current.enableGallery,
          enableBooking: enableBooking ?? current.enableBooking,
          enablePayments: enablePayments ?? current.enablePayments,
          enableCart: current.enableCart,
          enableQuotes: current.enableQuotes,
          enableAnalytics: current.enableAnalytics,
        ),
      );
    });
  }

  Widget _buildMaintenanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SYSTEM MAINTENANCE MODE",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        Obx(() {
          final maint = AppConfigService.to.rxMaintenanceSettings.value;
          return SwitchListTile(
            title: const Text("Activate Maintenance Mode"),
            value: maint.maintenanceMode,
            onChanged:
                (v) => _saveAndPublish('maintenance', () async {
                  await _repository.saveMaintenance(
                    MaintenanceSettings(
                      maintenanceMode: v,
                      message: _maintenanceMsg.text,
                      eta: maint.eta,
                    ),
                  );
                }),
          );
        }),
        const SizedBox(height: 16),
        _field("Banner Message", _maintenanceMsg),
      ],
    );
  }

  Widget _buildAppForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "APPLICATION SPECIFICATIONS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("App Current Version ID", _appVersion),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('app', () async {
                final current = AppConfigService.to.rxAppSettings.value;
                await _repository.saveApp(
                  AppSettings(
                    version: _appVersion.text,
                    forceUpdate: current.forceUpdate,
                    buildNumber: current.buildNumber,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  bool _isValidInstagramUrl(String url) {
    if (url.trim().isEmpty) return false;
    final regExp = RegExp(
      r'^(https?:\/\/)?(www\.)?instagram\.com\/[a-zA-Z0-9_\-\.]+\/?$',
      caseSensitive: false,
    );
    return regExp.hasMatch(url);
  }

  Widget _instagramField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.italiana(
            fontSize: 18,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            fillColor: const Color(0xFF131D1A),
            filled: true,
            hintText: "https://www.instagram.com/your_account/",
            hintStyle: const TextStyle(color: Colors.white24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF254235)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Instagram URL is required";
            }
            if (!_isValidInstagramUrl(value)) {
              return "Please enter a valid Instagram URL (e.g., https://www.instagram.com/username/)";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSocialForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SOCIAL REDIRECT LINKS",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _instagramField("Instagram - Kadi", _socialInstagramKadi),
          _instagramField("Instagram - Thangadh", _socialInstagramThangadh),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('business', () async {
                  final busCurrent =
                      AppConfigService.to.rxBusinessProfile.value;

                  final updatedSocialLinks = {
                    "instagram_kadi": _socialInstagramKadi.text.trim(),
                    "instagram_thangadh": _socialInstagramThangadh.text.trim(),
                  };

                  await _repository.saveBusiness(
                    BusinessProfile(
                      name: busCurrent.name,
                      companyName: busCurrent.companyName,
                      logo: busCurrent.logo,
                      whiteLogo: busCurrent.whiteLogo,
                      favicon: busCurrent.favicon,
                      gst: busCurrent.gst,
                      pan: busCurrent.pan,
                      ownerName: busCurrent.ownerName,
                      phone: busCurrent.phone,
                      email: busCurrent.email,
                      whatsapp: busCurrent.whatsapp,
                      officeBranches: busCurrent.officeBranches,
                      workingHours: busCurrent.workingHours,
                      socialLinks: updatedSocialLinks,
                    ),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BUSINESS HOURS & HOLIDAYS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Holiday Lists (comma separated)", _workHolidays),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('working_hours', () async {
                final current =
                    AppConfigService.to.rxWorkingHoursSettings.value;
                await _repository.saveWorkingHours(
                  WorkingHoursSettings(
                    weekdayHours: current.weekdayHours,
                    holidays:
                        _workHolidays.text
                            .split(",")
                            .map((s) => s.trim())
                            .toList(),
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildPoliciesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LEGAL POLICIES & TERMS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Privacy Policy", _policyPrivacy),
        _field("Terms of Service", _policyTerms),
        _field("Refund Policy", _policyRefund),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('policies', () async {
                await _repository.savePolicies(
                  PoliciesSettings(
                    privacyPolicy: _policyPrivacy.text,
                    termsOfService: _policyTerms.text,
                    refundPolicy: _policyRefund.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildCtaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CUSTOM HERO CTA BUTTON",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Button text", _ctaText),
        _field("Action redirect url", _ctaUrl),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('cta', () async {
                await _repository.saveCta(
                  CtaSettings(
                    buttonText: _ctaText.text,
                    buttonUrl: _ctaUrl.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildGalleryGridForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GALLERY GRID SETUP", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Grid Columns Count", _galleryColumns),
        CheckboxListTile(
          title: const Text("Enable Grid view layout"),
          value: _galleryGridEnable,
          onChanged: (v) {
            setState(() {
              _galleryGridEnable = v ?? true;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('gallery_settings', () async {
                await _repository.saveGallerySettings(
                  GallerySettings(
                    enableGrid: _galleryGridEnable,
                    columns: int.tryParse(_galleryColumns.text) ?? 3,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildReviewsFilterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CUSTOMER REVIEWS FILTER",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Minimum Star Rating allowed", _reviewsMinStars),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('review_settings', () async {
                final current = AppConfigService.to.rxReviewSettings.value;
                await _repository.saveReviewSettings(
                  ReviewSettings(
                    enableSorting: current.enableSorting,
                    minimumStars:
                        double.tryParse(_reviewsMinStars.text) ??
                        current.minimumStars,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildStatisticsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("STATISTICS METRICS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Completed Events Count", _statEvents),
        _field("Happy Clients Count", _statClients),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('statistics', () async {
                final current = AppConfigService.to.rxStatisticsSettings.value;
                await _repository.saveStatistics(
                  StatisticsSettings(
                    completedEvents:
                        int.tryParse(_statEvents.text) ??
                        current.completedEvents,
                    happyClients:
                        int.tryParse(_statClients.text) ?? current.happyClients,
                    cities: current.cities,
                    years: current.years,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildFaqAccordionsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FAQ TITLE CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("FAQ Accordions Section Title", _faqTitle),
        CheckboxListTile(
          title: const Text("Enable accordion expansion tiles"),
          value: _faqAccordionEnable,
          onChanged: (v) {
            setState(() {
              _faqAccordionEnable = v ?? true;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('faq_settings', () async {
                await _repository.saveFaqSettings(
                  FaqSettings(
                    title: _faqTitle.text,
                    enableAccordion: _faqAccordionEnable,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: AppTheme.sansBody(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.sansBody(fontSize: 12),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
