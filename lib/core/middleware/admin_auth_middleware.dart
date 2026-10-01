import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../constants/app_roles.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Route guard for all admin routes.
///
/// Checks [AuthController.rxIsLoggedIn] and admin role on every route entry.
/// If the user is not authenticated as staff/admin, redirects to [AppRoutes.login] (/admin)
/// preserving the originally requested path in the query parameter `redirect`.
class AdminAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // AuthController is registered permanently in InitialBinding — always available.
    final auth = Get.find<AuthController>();

    final role = auth.rxAdminRole.value?.roleType ?? auth.rxUserRole.value;
    final isStaffOrAdmin = auth.rxAdminRole.value != null ||
        role == AppRoles.superAdmin ||
        role == AppRoles.demoAdmin ||
        role == 'admin' ||
        role == 'manager';

    // If logged in as staff/admin, allow navigation to proceed.
    if (auth.rxIsLoggedIn.value && isStaffOrAdmin) return null;

    // Not logged in or not admin — redirect to admin login, preserving the requested path.
    final encodedRoute = Uri.encodeComponent(route ?? '');
    return RouteSettings(
      name: '${AppRoutes.login}?redirect=$encodedRoute',
    );
  }
}
