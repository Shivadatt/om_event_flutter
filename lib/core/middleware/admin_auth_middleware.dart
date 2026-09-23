import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Route guard for all admin routes.
///
/// Checks [AuthController.rxIsLoggedIn] on every route entry.
/// If the user is not authenticated, redirects to [AppRoutes.login]
/// preserving the originally requested path in the query parameter `redirect`.
///
/// Usage in AppRouter:
/// ```dart
/// GetPage(
///   name: AppRoutes.adminDashboard,
///   page: () => const AdminLayout(child: AdminDashboardScreen()),
///   binding: AdminBinding(),
///   middlewares: [AdminAuthMiddleware()],
/// )
/// ```
class AdminAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // AuthController is registered permanently in InitialBinding — always available.
    final auth = Get.find<AuthController>();

    // If logged in, allow navigation to proceed.
    if (auth.rxIsLoggedIn.value) return null;

    // Not logged in — redirect to admin login, preserving the requested path.
    final encodedRoute = Uri.encodeComponent(route ?? '');
    return RouteSettings(
      name: '${AppRoutes.login}?redirect=$encodedRoute',
    );
  }
}
