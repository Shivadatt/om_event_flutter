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
import '../../presentation/screens/admin/manage_bookings_screen.dart';
import '../../presentation/screens/admin/business_details_screen.dart';
import '../../presentation/bindings/business_details_binding.dart';
import '../constants/app_routes.dart';
import '../../presentation/screens/customer/auth/customer_auth_screen.dart';
import '../../presentation/screens/customer/dashboard/customer_dashboard_screen.dart';
import '../../presentation/screens/admin/customer_portal_admin_dashboard.dart';
import '../../presentation/screens/admin/booking_calendar_screen.dart';
import '../../presentation/screens/admin/admin_kpi_dashboard_screen.dart';
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
      name: AppRoutes.customerLogin,
      page: () => const CustomerAuthScreen(),
    ),
    GetPage(
      name: AppRoutes.customerDashboard,
      page: () => const CustomerDashboardScreen(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminLayout(child: AdminDashboardScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageLeads,
      page: () => const AdminLayout(child: ManageLeadsScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageQuotes,
      page: () => const AdminLayout(child: ManageQuotesScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageBookings,
      page: () => const AdminLayout(child: ManageBookingsScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageExperiences,
      page: () => const AdminLayout(child: ManageExperiencesScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageCategories,
      page: () => const AdminLayout(child: ManageCategoriesScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageCustomers,
      page: () => const AdminLayout(child: ManageCustomersScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.manageUsers,
      page: () => const AdminLayout(child: ManageAdminRolesScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.systemSettings,
      page: () => const SystemSettingsScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.businessDetails,
      page: () => const BusinessDetailsScreen(),
      binding: BusinessDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.manageReviews,
      page: () => const AdminLayout(child: ManageReviewsScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminLayout(child: ProfileScreen()),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.customerPortalAdmin,
      page: () => const AdminLayout(child: CustomerPortalAdminDashboard()),
    ),
    GetPage(
      name: AppRoutes.bookingCalendar,
      page: () => const AdminLayout(child: BookingCalendarScreen()),
    ),
    GetPage(
      name: AppRoutes.adminKpis,
      page: () => const AdminLayout(child: AdminKpiDashboardScreen()),
    ),
    GetPage(name: AppRoutes.docs, page: () => const DocsScreen()),
  ];
}
