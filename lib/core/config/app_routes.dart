import 'package:get/get.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/customer/home_screen.dart';
import '../../presentation/screens/customer/experience_detail_screen.dart';
import '../../presentation/screens/customer/quote_success_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/manage_leads_screen.dart';
import '../../presentation/screens/admin/manage_quotes_screen.dart';
import '../../presentation/screens/admin/manage_experiences_screen.dart';
import '../../presentation/screens/docs/docs_screen.dart';
import '../../presentation/bindings/catalog_binding.dart';
import '../../presentation/bindings/admin_binding.dart';

class AppRoutes {
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
  static const String docs = '/docs';

  static List<GetPage> get pages => [
        GetPage(
          name: splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: onboarding,
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: home,
          page: () => const HomeScreen(),
          binding: CatalogBinding(),
        ),
        GetPage(
          name: '$detail/:slug',
          page: () => const ExperienceDetailScreen(),
          binding: CatalogBinding(),
        ),
        GetPage(
          name: quoteSuccess,
          page: () => const QuoteSuccessScreen(),
        ),
        GetPage(
          name: login,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: adminDashboard,
          page: () => const AdminDashboardScreen(),
          binding: AdminBinding(),
        ),
        GetPage(
          name: manageLeads,
          page: () => const ManageLeadsScreen(),
          binding: AdminBinding(),
        ),
        GetPage(
          name: manageQuotes,
          page: () => const ManageQuotesScreen(),
          binding: AdminBinding(),
        ),
        GetPage(
          name: manageExperiences,
          page: () => const ManageExperiencesScreen(),
          binding: AdminBinding(),
        ),
        GetPage(
          name: docs,
          page: () => const DocsScreen(),
        ),
      ];
}
