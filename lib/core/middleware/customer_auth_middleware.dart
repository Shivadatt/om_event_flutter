import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../utils/auth_route_helper.dart';

/// Route guard for customer protected routes (e.g. Dashboard/Client Lounge).
///
/// Ensures:
/// 1. Admin/Super Admin/Staff users are NEVER permitted into Customer Lounge.
///    Any attempt redirects immediately to [AppRoutes.adminDashboard].
/// 2. Only verified, authenticated non-admin customers can access [AppRoutes.customerDashboard].
/// 3. Unauthenticated visitors are redirected to [AppRoutes.customerLogin]
///    preserving the requested path in query parameter `redirect`.
class CustomerAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // ── 1. Intercept Admin / Super Admin / Staff immediately ────────────────
    if (AuthRouteHelper.isCurrentAdminOrStaff()) {
      return const RouteSettings(name: AppRoutes.adminDashboard);
    }

    // ── 2. Validate Authenticated Customer ──────────────────────────────────
    if (AuthRouteHelper.isVerifiedCustomer()) {
      return null; // Allowed: Verified customer
    }

    // ── 3. Unauthenticated / Non-customer — Redirect to Client Login ────────
    final encodedRoute = Uri.encodeComponent(route ?? '');
    return RouteSettings(
      name: '${AppRoutes.customerLogin}?redirect=$encodedRoute',
    );
  }
}
