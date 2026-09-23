/// Centralized route path string constants.
/// All `Get.toNamed()` and `GetPage.name` calls must use these constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String detail = '/detail';
  static const String quoteSuccess = '/quote-success';
  static const String login = '/admin';
  static const String adminDashboard = '/admin-dashboard';
  static const String manageLeads = '/admin/leads';
  static const String manageQuotes = '/admin/quotes';
  static const String manageExperiences = '/admin/experiences';
  static const String manageCategories = '/admin/categories';
  static const String manageCustomers = '/admin/customers';
  static const String manageUsers = '/admin/users';
  static const String systemSettings = '/admin/settings';
  static const String businessDetails = '/admin/business-details';
  static const String manageReviews = '/admin/reviews';
  static const String adminProfile = '/admin/profile';
  static const String docs = '/docs';
  static const String customerLogin = '/client-login';
  static const String customerDashboard = '/dashboard';
  static const String customerPortalAdmin = '/admin/customer-portal';
  static const String adminKpis = '/admin/kpis';
  static const String adminBookings = '/admin/bookings';
  static const String adminAvailability = '/admin/availability';

  // Phase 2 Customer Routes
  static const String gallery = '/gallery';
  static const String serviceArea = '/service-area';
  static const String bookingPolicy = '/booking-policy';
  static const String cancellationPolicy = '/cancellation-policy';
  static const String policies = '/policies';

  // Phase 3 Customer Routes
  static const String contact = '/contact';

  // Phase 6 Admin CMS Routes
  static const String manageGallery = '/admin/gallery';
  static const String manageFaq = '/admin/faq';
  static const String managePolicies = '/admin/policies-cms';
  static const String manageServiceArea = '/admin/service-area-cms';
  static const String manageNotificationTemplates = '/admin/notification-templates';
}
