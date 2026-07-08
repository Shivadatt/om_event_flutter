part of '../settings_repository_impl.dart';

mixin SettingsOperations {
  FirebaseFirestore get _firestore;
  Future<void> _saveToDraft(String docId, Map<String, dynamic> draftData);

  Stream<PricingSettings> streamPricing() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('pricing')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return PricingSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return PricingSettings(
            gst: (source['gst'] ?? 18.0).toDouble(),
            deliveryCharge: (source['deliveryCharge'] ?? 500.0).toDouble(),
            travelCharge: (source['travelCharge'] ?? 0.0).toDouble(),
            discount: (source['discount'] ?? 0.0).toDouble(),
            coupons: source['coupons'] ?? [],
            advanceAmount: (source['advanceAmount'] ?? 0.0).toDouble(),
          );
        });
  }

  Stream<BookingSettings> streamBooking() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('booking')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return BookingSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return BookingSettings(
            bookingRules: source['bookingRules'] ?? [],
            advanceDays: source['advanceDays'] ?? 7,
            workingHours: source['workingHours'] ?? '9:00 AM - 8:00 PM',
            cancellationRules: source['cancellationRules'] ?? [],
            refundRules: source['refundRules'] ?? [],
          );
        });
  }

  Stream<NotificationsSettings> streamNotifications() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('notifications')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return NotificationsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return NotificationsSettings(
            pushTemplates: Map<String, dynamic>.from(
              source['pushTemplates'] ?? {},
            ),
            smsTemplates: Map<String, dynamic>.from(
              source['smsTemplates'] ?? {},
            ),
            emailTemplates: Map<String, dynamic>.from(
              source['emailTemplates'] ?? {},
            ),
          );
        });
  }

  Stream<PDFSettings> streamPDF() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('pdf')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return PDFSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return PDFSettings(
            invoiceHeader: source['invoiceHeader'] ?? '',
            invoiceFooter: source['invoiceFooter'] ?? '',
            terms: source['terms'] ?? '',
            bankDetails: Map<String, dynamic>.from(source['bankDetails'] ?? {}),
            upi: source['upi'] ?? '',
            signature: source['signature'] ?? '',
          );
        });
  }

  Stream<StatisticsSettings> streamStatistics() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('statistics')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return StatisticsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return StatisticsSettings(
            completedEvents: source['completedEvents'] ?? 0,
            happyClients: source['happyClients'] ?? 0,
            cities: source['cities'] ?? 0,
            years: source['years'] ?? 0,
          );
        });
  }

  Stream<FeatureFlagsSettings> streamFeatureFlags() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('feature_flags')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return FeatureFlagsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return FeatureFlagsSettings(
            enableReviews: source['enableReviews'] ?? true,
            enableGallery: source['enableGallery'] ?? true,
            enableBooking: source['enableBooking'] ?? true,
            enablePayments: source['enablePayments'] ?? false,
            enableCart: source['enableCart'] ?? true,
            enableQuotes: source['enableQuotes'] ?? true,
            enableAnalytics: source['enableAnalytics'] ?? false,
          );
        });
  }

  Stream<MaintenanceSettings> streamMaintenance() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('maintenance')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return MaintenanceSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return MaintenanceSettings(
            maintenanceMode: source['maintenanceMode'] ?? false,
            message: source['message'] ?? '',
            eta: source['eta'] ?? '',
          );
        });
  }

  Stream<AppSettings> streamApp() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('app')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return AppSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return AppSettings(
            version: source['version'] ?? '1.0.0',
            forceUpdate: source['forceUpdate'] ?? false,
            buildNumber: source['buildNumber'] ?? 1,
          );
        });
  }

  Stream<EmailTemplatesSettings> streamEmailTemplates() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('email_templates')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return EmailTemplatesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return EmailTemplatesSettings(templates: source['templates'] ?? {});
        });
  }

  Stream<SmsTemplatesSettings> streamSmsTemplates() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('sms_templates')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return SmsTemplatesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return SmsTemplatesSettings(templates: source['templates'] ?? {});
        });
  }

  Stream<InvoiceSettings> streamInvoice() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('invoice')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return InvoiceSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return InvoiceSettings(
            taxNumber: source['taxNumber'] ?? '',
            invoiceNote: source['invoiceNote'] ?? '',
          );
        });
  }

  Stream<AnalyticsSettings> streamAnalytics() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('analytics')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return AnalyticsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return AnalyticsSettings(
            measurementId: source['measurementId'] ?? '',
            enableTracking: source['enableTracking'] ?? false,
          );
        });
  }

  Stream<DashboardSettings> streamDashboard() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('dashboard')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return DashboardSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return DashboardSettings(
            welcomeMessage: source['welcomeMessage'] ?? 'Welcome back, Admin',
            activeWidgets: source['activeWidgets'] ?? [],
          );
        });
  }

  Stream<WorkingHoursSettings> streamWorkingHours() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('working_hours')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return WorkingHoursSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return WorkingHoursSettings(
            weekdayHours: source['weekdayHours'] ?? [],
            holidays: source['holidays'] ?? [],
          );
        });
  }

  Stream<PoliciesSettings> streamPolicies() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('policies')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return PoliciesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return PoliciesSettings(
            privacyPolicy: source['privacyPolicy'] ?? '',
            termsOfService: source['termsOfService'] ?? '',
            refundPolicy: source['refundPolicy'] ?? '',
          );
        });
  }

  Stream<ValidationSettings> streamValidation() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('validation')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ValidationSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return ValidationSettings(
            validationRules: source['validationRules'] ?? {},
          );
        });
  }

  Stream<MessagesSettings> streamMessages() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('messages')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return MessagesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return MessagesSettings(
            customMessages: source['customMessages'] ?? {},
          );
        });
  }

  Stream<GallerySettings> streamGallerySettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('gallery_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return GallerySettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return GallerySettings(
            enableGrid: source['enableGrid'] ?? true,
            columns: source['columns'] ?? 3,
          );
        });
  }

  Stream<VideoSettings> streamVideoSettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('video_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return VideoSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return VideoSettings(videosList: source['videosList'] ?? []);
        });
  }

  Stream<ReviewSettings> streamReviewSettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('review_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ReviewSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return ReviewSettings(
            enableSorting: source['enableSorting'] ?? true,
            minimumStars: (source['minimumStars'] ?? 4.0).toDouble(),
          );
        });
  }

  Stream<FaqSettings> streamFaqSettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('faq_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return FaqSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return FaqSettings(
            title: source['title'] ?? 'FAQ',
            enableAccordion: source['enableAccordion'] ?? true,
          );
        });
  }

  Future<void> savePricing(PricingSettings pricing) async {
    await _saveToDraft('pricing', {
      'gst': pricing.gst,
      'deliveryCharge': pricing.deliveryCharge,
      'travelCharge': pricing.travelCharge,
      'discount': pricing.discount,
      'coupons': pricing.coupons,
      'advanceAmount': pricing.advanceAmount,
    });
  }

  Future<void> saveBooking(BookingSettings booking) async {
    await _saveToDraft('booking', {
      'bookingRules': booking.bookingRules,
      'advanceDays': booking.advanceDays,
      'workingHours': booking.workingHours,
      'cancellationRules': booking.cancellationRules,
      'refundRules': booking.refundRules,
    });
  }

  Future<void> saveNotifications(NotificationsSettings notifications) async {
    await _saveToDraft('notifications', {
      'pushTemplates': notifications.pushTemplates,
      'smsTemplates': notifications.smsTemplates,
      'emailTemplates': notifications.emailTemplates,
    });
  }

  Future<void> savePDF(PDFSettings pdf) async {
    await _saveToDraft('pdf', {
      'invoiceHeader': pdf.invoiceHeader,
      'invoiceFooter': pdf.invoiceFooter,
      'terms': pdf.terms,
      'bankDetails': pdf.bankDetails,
      'upi': pdf.upi,
      'signature': pdf.signature,
    });
  }

  Future<void> saveStatistics(StatisticsSettings stats) async {
    await _saveToDraft('statistics', {
      'completedEvents': stats.completedEvents,
      'happyClients': stats.happyClients,
      'cities': stats.cities,
      'years': stats.years,
    });
  }

  Future<void> saveFeatureFlags(FeatureFlagsSettings flags) async {
    await _saveToDraft('feature_flags', {
      'enableReviews': flags.enableReviews,
      'enableGallery': flags.enableGallery,
      'enableBooking': flags.enableBooking,
      'enablePayments': flags.enablePayments,
      'enableCart': flags.enableCart,
      'enableQuotes': flags.enableQuotes,
      'enableAnalytics': flags.enableAnalytics,
    });
  }

  Future<void> saveMaintenance(MaintenanceSettings maintenance) async {
    await _saveToDraft('maintenance', {
      'maintenanceMode': maintenance.maintenanceMode,
      'message': maintenance.message,
      'eta': maintenance.eta,
    });
  }

  Future<void> saveApp(AppSettings app) async {
    await _saveToDraft('app', {
      'version': app.version,
      'forceUpdate': app.forceUpdate,
      'buildNumber': app.buildNumber,
    });
  }

  Future<void> saveEmailTemplates(EmailTemplatesSettings templates) async {
    await _saveToDraft('email_templates', {'templates': templates.templates});
  }

  Future<void> saveSmsTemplates(SmsTemplatesSettings templates) async {
    await _saveToDraft('sms_templates', {'templates': templates.templates});
  }

  Future<void> saveInvoice(InvoiceSettings invoice) async {
    await _saveToDraft('invoice', {
      'taxNumber': invoice.taxNumber,
      'invoiceNote': invoice.invoiceNote,
    });
  }

  Future<void> saveAnalytics(AnalyticsSettings analytics) async {
    await _saveToDraft('analytics', {
      'measurementId': analytics.measurementId,
      'enableTracking': analytics.enableTracking,
    });
  }

  Future<void> saveDashboard(DashboardSettings dashboard) async {
    await _saveToDraft('dashboard', {
      'welcomeMessage': dashboard.welcomeMessage,
      'activeWidgets': dashboard.activeWidgets,
    });
  }

  Future<void> saveWorkingHours(WorkingHoursSettings hours) async {
    await _saveToDraft('working_hours', {
      'weekdayHours': hours.weekdayHours,
      'holidays': hours.holidays,
    });
  }

  Future<void> savePolicies(PoliciesSettings policies) async {
    await _saveToDraft('policies', {
      'privacyPolicy': policies.privacyPolicy,
      'termsOfService': policies.termsOfService,
      'refundPolicy': policies.refundPolicy,
    });
  }

  Future<void> saveValidation(ValidationSettings validation) async {
    await _saveToDraft('validation', {
      'validationRules': validation.validationRules,
    });
  }

  Future<void> saveMessages(MessagesSettings messages) async {
    await _saveToDraft('messages', {'customMessages': messages.customMessages});
  }

  Future<void> saveGallerySettings(GallerySettings settings) async {
    await _saveToDraft('gallery_settings', {
      'enableGrid': settings.enableGrid,
      'columns': settings.columns,
    });
  }

  Future<void> saveVideoSettings(VideoSettings settings) async {
    await _saveToDraft('video_settings', {'videosList': settings.videosList});
  }

  Future<void> saveReviewSettings(ReviewSettings settings) async {
    await _saveToDraft('review_settings', {
      'enableSorting': settings.enableSorting,
      'minimumStars': settings.minimumStars,
    });
  }

  Future<void> saveFaqSettings(FaqSettings settings) async {
    await _saveToDraft('faq_settings', {
      'title': settings.title,
      'enableAccordion': settings.enableAccordion,
    });
  }
}
