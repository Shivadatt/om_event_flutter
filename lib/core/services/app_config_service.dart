import 'package:get/get.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';

class AppConfigService extends GetxService {
  static AppConfigService get to => Get.find<AppConfigService>();

  final SettingsRepository _repo = Get.find<SettingsRepository>();

  // Rx Properties for all 31 Documents
  final rxBusinessProfile = BusinessProfile.defaultVal().obs;
  final rxHomepageSettings = HomepageSettings.defaultVal().obs;
  final rxThemeSettings = ThemeSettings.defaultVal().obs;
  final rxSEOSettings = SEOSettings.defaultVal().obs;
  final rxFooterSettings = FooterSettings.defaultVal().obs;
  final rxContactSettings = ContactSettings.defaultVal().obs;
  final rxPricingSettings = PricingSettings.defaultVal().obs;
  final rxBookingSettings = BookingSettings.defaultVal().obs;
  final rxNotificationsSettings = NotificationsSettings.defaultVal().obs;
  final rxPDFSettings = PDFSettings.defaultVal().obs;
  final rxStatisticsSettings = StatisticsSettings.defaultVal().obs;
  final rxFeatureFlagsSettings = FeatureFlagsSettings.defaultVal().obs;
  final rxMaintenanceSettings = MaintenanceSettings.defaultVal().obs;
  final rxAppSettings = AppSettings.defaultVal().obs;

  // Additional 16 Dynamic Rx Properties
  final rxAboutSettings = AboutSettings.defaultVal().obs;
  final rxEmailTemplatesSettings = EmailTemplatesSettings.defaultVal().obs;
  final rxSmsTemplatesSettings = SmsTemplatesSettings.defaultVal().obs;
  final rxInvoiceSettings = InvoiceSettings.defaultVal().obs;
  final rxAnalyticsSettings = AnalyticsSettings.defaultVal().obs;
  final rxDashboardSettings = DashboardSettings.defaultVal().obs;
  final rxWorkingHoursSettings = WorkingHoursSettings.defaultVal().obs;
  final rxPoliciesSettings = PoliciesSettings.defaultVal().obs;
  final rxValidationSettings = ValidationSettings.defaultVal().obs;
  final rxMessagesSettings = MessagesSettings.defaultVal().obs;
  final rxHomeSectionsSettings = HomeSectionsSettings.defaultVal().obs;
  final rxCtaSettings = CtaSettings.defaultVal().obs;
  final rxGallerySettings = GallerySettings.defaultVal().obs;
  final rxVideoSettings = VideoSettings.defaultVal().obs;
  final rxReviewSettings = ReviewSettings.defaultVal().obs;
  final rxFaqSettings = FaqSettings.defaultVal().obs;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  void _bindStreams() {
    rxBusinessProfile.bindStream(_repo.streamBusiness());
    rxHomepageSettings.bindStream(_repo.streamHomepage());
    rxThemeSettings.bindStream(_repo.streamTheme());
    rxSEOSettings.bindStream(_repo.streamSEO());
    rxFooterSettings.bindStream(_repo.streamFooter());
    rxContactSettings.bindStream(_repo.streamContact());
    rxPricingSettings.bindStream(_repo.streamPricing());
    rxBookingSettings.bindStream(_repo.streamBooking());
    rxNotificationsSettings.bindStream(_repo.streamNotifications());
    rxPDFSettings.bindStream(_repo.streamPDF());
    rxStatisticsSettings.bindStream(_repo.streamStatistics());
    rxFeatureFlagsSettings.bindStream(_repo.streamFeatureFlags());
    rxMaintenanceSettings.bindStream(_repo.streamMaintenance());
    rxAppSettings.bindStream(_repo.streamApp());

    // Additional 16 Binds
    rxAboutSettings.bindStream(_repo.streamAbout());
    rxEmailTemplatesSettings.bindStream(_repo.streamEmailTemplates());
    rxSmsTemplatesSettings.bindStream(_repo.streamSmsTemplates());
    rxInvoiceSettings.bindStream(_repo.streamInvoice());
    rxAnalyticsSettings.bindStream(_repo.streamAnalytics());
    rxDashboardSettings.bindStream(_repo.streamDashboard());
    rxWorkingHoursSettings.bindStream(_repo.streamWorkingHours());
    rxPoliciesSettings.bindStream(_repo.streamPolicies());
    rxValidationSettings.bindStream(_repo.streamValidation());
    rxMessagesSettings.bindStream(_repo.streamMessages());
    rxHomeSectionsSettings.bindStream(_repo.streamHomeSections());
    rxCtaSettings.bindStream(_repo.streamCta());
    rxGallerySettings.bindStream(_repo.streamGallerySettings());
    rxVideoSettings.bindStream(_repo.streamVideoSettings());
    rxReviewSettings.bindStream(_repo.streamReviewSettings());
    rxFaqSettings.bindStream(_repo.streamFaqSettings());
  }
}
