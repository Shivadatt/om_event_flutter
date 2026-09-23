import 'package:get/get.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/customer/home_screen.dart';
import '../../presentation/screens/customer/experience_detail_screen.dart';
import '../../presentation/screens/customer/quote_success_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/widgets/admin_layout.dart';
import '../../presentation/screens/admin/manage_leads_screen.dart';
import '../../presentation/screens/admin/manage_quotes_screen.dart';
import '../../presentation/screens/admin/bookings/admin_bookings_screen.dart';
import '../../presentation/screens/admin/availability/admin_availability_screen.dart';
import '../../presentation/screens/admin/manage_experiences_screen.dart';
import '../../presentation/screens/admin/manage_categories_screen.dart';
import '../../presentation/screens/admin/manage_customers_screen.dart';
import '../../presentation/screens/admin/manage_admin_roles_screen.dart';
import '../../presentation/screens/admin/system_settings_screen.dart';
import '../../presentation/screens/admin/manage_reviews_screen.dart';
import '../../presentation/screens/admin/profile_screen.dart';
import '../../presentation/screens/docs/docs_screen.dart';
import '../../presentation/bindings/catalog_binding.dart';
import '../../presentation/bindings/admin_binding.dart';
import '../../presentation/screens/admin/business_details_screen.dart';
import '../../presentation/bindings/business_details_binding.dart';
import '../constants/app_routes.dart';
import '../../presentation/screens/customer/auth/customer_auth_screen.dart';
import '../../presentation/screens/customer/dashboard/customer_dashboard_screen.dart';
import '../../presentation/screens/admin/customer_portal_admin_dashboard.dart';
import '../../presentation/screens/admin/admin_kpi_dashboard_screen.dart';
import '../../presentation/screens/customer/gallery/public_gallery_screen.dart';
import '../../presentation/screens/customer/service_area/service_area_screen.dart';
import '../../presentation/screens/customer/policies/policies_screen.dart';
import '../../presentation/screens/customer/contact/contact_screen.dart';
import '../../presentation/screens/admin/cms/manage_gallery_screen.dart';
import '../../presentation/screens/admin/cms/manage_faq_screen.dart';
import '../../presentation/screens/admin/cms/manage_policies_screen.dart';
import '../../presentation/screens/admin/cms/manage_service_area_screen.dart';
import '../../presentation/screens/admin/cms/manage_notification_templates_screen.dart';
import '../middleware/admin_auth_middleware.dart';
import '../middleware/customer_auth_middleware.dart';
export '../constants/app_routes.dart';

/// Route definitions and page factory registry.
/// All route path strings are sourced from [AppRoutes] in core/constants/.
class AppRouter {
  static List<GetPage> get pages => [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: '${AppRoutes.detail}/:slug',
      page: () => const ExperienceDetailScreen(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.quoteSuccess,
      page: () => const QuoteSuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const PublicGalleryScreen(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.serviceArea,
      page: () => const ServiceAreaScreen(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingPolicy,
      page: () => const PoliciesScreen(initialTabIndex: 0),
    ),
    GetPage(
      name: AppRoutes.cancellationPolicy,
      page: () => const PoliciesScreen(initialTabIndex: 1),
    ),
    GetPage(
      name: AppRoutes.policies,
      page: () => const PoliciesScreen(),
    ),
    GetPage(
      name: AppRoutes.contact,
      page: () => const ContactScreen(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.customerLogin,
      page: () => const CustomerAuthScreen(),
    ),
    GetPage(
      name: AppRoutes.customerDashboard,
      page: () => const CustomerDashboardScreen(),
      binding: CatalogBinding(),
      middlewares: [CustomerAuthMiddleware()],
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminLayout(child: AdminDashboardScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageLeads,
      page: () => const AdminLayout(child: ManageLeadsScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageQuotes,
      page: () => const AdminLayout(child: ManageQuotesScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminBookings,
      page: () => const AdminLayout(child: AdminBookingsScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminAvailability,
      page: () => const AdminLayout(child: AdminAvailabilityScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.manageExperiences,
      page: () => const AdminLayout(child: ManageExperiencesScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageCategories,
      page: () => const AdminLayout(child: ManageCategoriesScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageCustomers,
      page: () => const AdminLayout(child: ManageCustomersScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageUsers,
      page: () => const AdminLayout(child: ManageAdminRolesScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.systemSettings,
      page: () => const SystemSettingsScreen(),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.businessDetails,
      page: () => const BusinessDetailsScreen(),
      binding: BusinessDetailsBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageReviews,
      page: () => const AdminLayout(child: ManageReviewsScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminLayout(child: ProfileScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.customerPortalAdmin,
      page: () => const AdminLayout(child: CustomerPortalAdminDashboard()),
      middlewares: [AdminAuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.adminKpis,
      page: () => const AdminLayout(child: AdminKpiDashboardScreen()),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(name: AppRoutes.docs, page: () => const DocsScreen()),

    // Phase 6 — Admin CMS Routes
    GetPage(
      name: AppRoutes.manageGallery,
      page: () => const AdminLayout(child: ManageGalleryScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageFaq,
      page: () => const AdminLayout(child: ManageFaqScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.managePolicies,
      page: () => const AdminLayout(child: ManagePoliciesScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageServiceArea,
      page: () => const AdminLayout(child: ManageServiceAreaScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.manageNotificationTemplates,
      page: () => const AdminLayout(child: ManageNotificationTemplatesScreen()),
      binding: AdminBinding(),
      middlewares: [AdminAuthMiddleware()],
    ),
  ];
}
