part of '../system_settings_screen.dart';

extension _SettingsSavesExtension on _SystemSettingsScreenState {
  void _populateFieldsIfMounted() {
    if (mounted) {
      updateState(() {
        _populateFields();
      });
    }
  }

  void _populateFields() {
    final bus = AppConfigService.to.rxBusinessProfile.value;
    _busName.text = bus.name;
    _busCompany.text = bus.companyName;
    _contactNumbers = List.from(bus.contactNumbers)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
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
}
