import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../constants/app_roles.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/customer_auth_controller.dart';
import '../../data/datasources/local_storage_source.dart';

/// Single source of truth for post-login, session restoration, and cross-domain route resolution.
/// Ensures Admin/Super Admin/Staff NEVER land on Customer Lounge (/dashboard),
/// and Customers NEVER land on Admin Dashboard (/admin, /admin/*).
class AuthRouteHelper {
  AuthRouteHelper._();

  /// Determines if the current authenticated or cached user is an admin, super admin, or staff.
  static bool isCurrentAdminOrStaff() {
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      if (auth.isStaffOrAdmin || auth.isCurrentAdminSessionValid) return true;
    }
    if (Get.isRegistered<LocalStorageSource>()) {
      final cachedRole = Get.find<LocalStorageSource>().getAdminCachedRole();
      if (AppRoles.isAdminRole(cachedRole)) return true;
    }
    return false;
  }

  /// Determines if the current user is a verified, non-admin customer.
  static bool isVerifiedCustomer() {
    if (isCurrentAdminOrStaff()) return false;
    if (Get.isRegistered<CustomerAuthController>()) {
      return Get.find<CustomerAuthController>().isAuthenticatedCustomer;
    }
    final user = FirebaseAuth.instance.currentUser;
    return user != null && !user.isAnonymous;
  }

  /// Resolves the canonical post-login landing route based strictly on authenticated role.
  /// - Admin / Super Admin / Staff -> [AppRoutes.adminDashboard]
  /// - Verified Customer -> [AppRoutes.customerDashboard]
  /// - Unauthenticated -> [AppRoutes.login] (admin) or [AppRoutes.customerLogin] (customer)
  static String resolvePostLoginRoute({bool preferAdmin = false}) {
    if (isCurrentAdminOrStaff()) {
      return AppRoutes.adminDashboard;
    }

    if (isVerifiedCustomer()) {
      return AppRoutes.customerDashboard;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.isAnonymous) {
      if (preferAdmin) return AppRoutes.adminDashboard;
      return AppRoutes.customerDashboard;
    }

    return preferAdmin ? AppRoutes.login : AppRoutes.customerLogin;
  }
}
