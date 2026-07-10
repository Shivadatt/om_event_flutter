import 'dart:async';
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

  // Track active stream subscriptions to prevent permission leaks or duplicate listeners
  final List<StreamSubscription> _publicSubscriptions = [];
  final List<StreamSubscription> _adminSubscriptions = [];

  @override
  void onInit() {
    super.onInit();
    _bindPublicStreams();
  }

  @override
  void onClose() {
    _unbindAllStreams();
    super.onClose();
  }

  /// Bind only public, guest-accessible configuration streams on cold start
  void _bindPublicStreams() {
    _unbindPublicStreams();

    _publicSubscriptions.addAll([
      _bindStream(_repo.streamBusiness(), rxBusinessProfile),
      _bindStream(_repo.streamHomepage(), rxHomepageSettings),
      _bindStream(_repo.streamTheme(), rxThemeSettings),
      _bindStream(_repo.streamSEO(), rxSEOSettings),
      _bindStream(_repo.streamFooter(), rxFooterSettings),
      _bindStream(_repo.streamContact(), rxContactSettings),
      _bindStream(_repo.streamPricing(), rxPricingSettings),
      _bindStream(_repo.streamBooking(), rxBookingSettings),
      _bindStream(_repo.streamPDF(), rxPDFSettings),
      _bindStream(_repo.streamStatistics(), rxStatisticsSettings),
      _bindStream(_repo.streamMaintenance(), rxMaintenanceSettings),
      _bindStream(_repo.streamApp(), rxAppSettings),
      _bindStream(_repo.streamAbout(), rxAboutSettings),
      _bindStream(_repo.streamWorkingHours(), rxWorkingHoursSettings),
      _bindStream(_repo.streamPolicies(), rxPoliciesSettings),
      _bindStream(_repo.streamValidation(), rxValidationSettings),
      _bindStream(_repo.streamMessages(), rxMessagesSettings),
      _bindStream(_repo.streamHomeSections(), rxHomeSectionsSettings),
      _bindStream(_repo.streamCta(), rxCtaSettings),
      _bindStream(_repo.streamGallerySettings(), rxGallerySettings),
      _bindStream(_repo.streamVideoSettings(), rxVideoSettings),
      _bindStream(_repo.streamReviewSettings(), rxReviewSettings),
      _bindStream(_repo.streamFaqSettings(), rxFaqSettings),
    ]);
  }

  /// Bind sensitive settings streams ONLY when an authenticated admin/staff session is verified.
  /// This prevents permission-denied errors on startup for guests or regular customers.
  void bindAdminStreams() {
    unbindAdminStreams();

    _adminSubscriptions.addAll([
      _bindStream(_repo.streamNotifications(), rxNotificationsSettings),
      _bindStream(_repo.streamFeatureFlags(), rxFeatureFlagsSettings),
      _bindStream(_repo.streamEmailTemplates(), rxEmailTemplatesSettings),
      _bindStream(_repo.streamSmsTemplates(), rxSmsTemplatesSettings),
      _bindStream(_repo.streamInvoice(), rxInvoiceSettings),
      _bindStream(_repo.streamAnalytics(), rxAnalyticsSettings),
      _bindStream(_repo.streamDashboard(), rxDashboardSettings),
    ]);
  }

  StreamSubscription<T> _bindStream<T>(Stream<T> stream, Rx<T> rxVar) {
    return stream.listen(
      (data) => rxVar.value = data,
      onError: (e) {
        // Silently swallow or debug print to prevent RethrownDartError crashes in DDC
        // debugPrint("AppConfigService stream error: $e");
      },
    );
  }

  void _unbindPublicStreams() {
    for (final sub in _publicSubscriptions) {
      sub.cancel();
    }
    _publicSubscriptions.clear();
  }

  /// Unbind admin streams on logout to clean up active listeners
  void unbindAdminStreams() {
    for (final sub in _adminSubscriptions) {
      sub.cancel();
    }
    _adminSubscriptions.clear();
    
    // Reset properties to default values on logout
    rxNotificationsSettings.value = NotificationsSettings.defaultVal();
    rxFeatureFlagsSettings.value = FeatureFlagsSettings.defaultVal();
    rxEmailTemplatesSettings.value = EmailTemplatesSettings.defaultVal();
    rxSmsTemplatesSettings.value = SmsTemplatesSettings.defaultVal();
    rxInvoiceSettings.value = InvoiceSettings.defaultVal();
    rxAnalyticsSettings.value = AnalyticsSettings.defaultVal();
    rxDashboardSettings.value = DashboardSettings.defaultVal();
  }

  void _unbindAllStreams() {
    _unbindPublicStreams();
    unbindAdminStreams();
  }
}
