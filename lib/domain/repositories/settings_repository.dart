import '../entities/settings_entities.dart';

abstract class SettingsRepository {
  Stream<BusinessProfile> streamBusiness();
  Stream<HomepageSettings> streamHomepage();
  Stream<ThemeSettings> streamTheme();
  Stream<SEOSettings> streamSEO();
  Stream<FooterSettings> streamFooter();
  Stream<ContactSettings> streamContact();
  Stream<PricingSettings> streamPricing();
  Stream<BookingSettings> streamBooking();
  Stream<NotificationsSettings> streamNotifications();
  Stream<PDFSettings> streamPDF();
  Stream<StatisticsSettings> streamStatistics();
  Stream<FeatureFlagsSettings> streamFeatureFlags();
  Stream<MaintenanceSettings> streamMaintenance();
  Stream<AppSettings> streamApp();

  // Additional 16 Dynamic Streams
  Stream<AboutSettings> streamAbout();
  Stream<EmailTemplatesSettings> streamEmailTemplates();
  Stream<SmsTemplatesSettings> streamSmsTemplates();
  Stream<InvoiceSettings> streamInvoice();
  Stream<AnalyticsSettings> streamAnalytics();
  Stream<DashboardSettings> streamDashboard();
  Stream<WorkingHoursSettings> streamWorkingHours();
  Stream<PoliciesSettings> streamPolicies();
  Stream<ValidationSettings> streamValidation();
  Stream<MessagesSettings> streamMessages();
  Stream<HomeSectionsSettings> streamHomeSections();
  Stream<CtaSettings> streamCta();
  Stream<GallerySettings> streamGallerySettings();
  Stream<VideoSettings> streamVideoSettings();
  Stream<ReviewSettings> streamReviewSettings();
  Stream<FaqSettings> streamFaqSettings();

  Future<void> saveBusiness(BusinessProfile profile);
  Future<void> saveHomepage(HomepageSettings homepage);
  Future<void> saveTheme(ThemeSettings theme);
  Future<void> saveSEO(SEOSettings seo);
  Future<void> saveFooter(FooterSettings footer);
  Future<void> saveContact(ContactSettings contact);
  Future<void> savePricing(PricingSettings pricing);
  Future<void> saveBooking(BookingSettings booking);
  Future<void> saveNotifications(NotificationsSettings notifications);
  Future<void> savePDF(PDFSettings pdf);
  Future<void> saveStatistics(StatisticsSettings stats);
  Future<void> saveFeatureFlags(FeatureFlagsSettings flags);
  Future<void> saveMaintenance(MaintenanceSettings maintenance);
  Future<void> saveApp(AppSettings app);

  // Additional 16 Dynamic Saves
  Future<void> saveAbout(AboutSettings about);
  Future<void> saveEmailTemplates(EmailTemplatesSettings templates);
  Future<void> saveSmsTemplates(SmsTemplatesSettings templates);
  Future<void> saveInvoice(InvoiceSettings invoice);
  Future<void> saveAnalytics(AnalyticsSettings analytics);
  Future<void> saveDashboard(DashboardSettings dashboard);
  Future<void> saveWorkingHours(WorkingHoursSettings hours);
  Future<void> savePolicies(PoliciesSettings policies);
  Future<void> saveValidation(ValidationSettings validation);
  Future<void> saveMessages(MessagesSettings messages);
  Future<void> saveHomeSections(HomeSectionsSettings sections);
  Future<void> saveCta(CtaSettings cta);
  Future<void> saveGallerySettings(GallerySettings settings);
  Future<void> saveVideoSettings(VideoSettings settings);
  Future<void> saveReviewSettings(ReviewSettings settings);
  Future<void> saveFaqSettings(FaqSettings settings);

  Future<void> publishSettings(String docId);
  Future<List<Map<String, dynamic>>> getVersionHistory(String docId);
  Future<void> rollbackToVersion(String docId, int version);
}
