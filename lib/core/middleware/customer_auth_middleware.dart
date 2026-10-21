import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_routes.dart';
import '../utils/auth_route_helper.dart';
import '../utils/app_logger.dart';
import '../../presentation/controllers/customer_auth_controller.dart';
import '../../data/datasources/local_storage_source.dart';

/// Route guard for customer protected routes (e.g. Dashboard/Client Lounge).
///
/// Ensures:
/// 1. Admin/Super Admin/Staff users are NEVER permitted into Customer Lounge.
///    Any attempt redirects immediately to [AppRoutes.adminDashboard].
/// 2. Absolute 2-hour customer session expiration is strictly enforced.
/// 3. While AppBootstrapGate is initializing, valid customer sessions pass through so splash screen renders.
/// 4. Only verified, authenticated non-admin customers can access [AppRoutes.customerDashboard].
/// 5. Unauthenticated or expired visitors are redirected to [AppRoutes.customerLogin]
///    preserving the requested path in query parameter `redirect`.
class CustomerAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<CustomerAuthController>()) {
      AppLogger.info('[AUTH_SESSION] Middleware decision: pass-through allowed (bootstrapping controllers)');
      return null;
    }

    final customerAuth = Get.find<CustomerAuthController>();
    final localStorage = Get.isRegistered<LocalStorageSource>()
        ? Get.find<LocalStorageSource>()
        : null;

    // ── 1. Intercept Admin / Super Admin / Staff immediately ────────────────
    if (AuthRouteHelper.isCurrentAdminOrStaff()) {
      AppLogger.info('[AUTH_SESSION] Redirect reason: admin cannot access client lounge');
      AppLogger.info('[AUTH_SESSION] Middleware decision: redirect to adminDashboard');
      return const RouteSettings(name: AppRoutes.adminDashboard);
    }

    // ── 2. Handle Ongoing App Bootstrap Gate ────────────────────────────────
    // While AppBootstrapGate is resolving auth and profile during startup,
    // allow initial route frame so AppBootstrapGate can await Firebase restoration.
    if (!customerAuth.rxCustomerBootstrapped.value) {
      AppLogger.info('[AUTH_SESSION] Middleware decision: pass-through allowed (bootstrapping in progress)');
      return null;
    }

    // ── 3. Check Absolute 2-Hour Customer Session Expiration ────────────────
    if (customerAuth.isSessionExpired()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (customerAuth.rxIsLoggedIn.value || currentUser != null) {
        AppLogger.info('[AUTH_SESSION] Explicit sign-out reason: 2-hour session expired in middleware check');
        customerAuth.handleSessionExpired();
      }
      final encodedRoute = Uri.encodeComponent(route ?? '');
      AppLogger.info('[AUTH_SESSION] Redirect reason: customer session expired');
      AppLogger.info('[AUTH_SESSION] Middleware decision: redirect to client-login');
      return RouteSettings(
        name: '${AppRoutes.customerLogin}?redirect=$encodedRoute',
      );
    }


    // ── 4. Validate Authenticated Customer ──────────────────────────────────
    if (AuthRouteHelper.isVerifiedCustomer() && !customerAuth.isSessionExpired()) {
      AppLogger.info('[AUTH_SESSION] Middleware decision: verified customer allowed access to $route');
      return null;
    }

    // ── 5. Persistent Auth Fallback on Browser Reload / Cold Navigation ────
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.isAnonymous && !AuthRouteHelper.isCurrentAdminOrStaff()) {
      if (localStorage != null && !localStorage.isCustomerSessionExpired()) {
        customerAuth.rxIsLoggedIn.value = true;
        AppLogger.info('[AUTH_SESSION] Middleware decision: persistent user session verified, access allowed to $route');
        return null;
      }
    }

    // ── 6. Unauthenticated / Non-customer — Redirect to Client Login ────────
    final encodedRoute = Uri.encodeComponent(route ?? '');
    AppLogger.info('[AUTH_SESSION] Redirect reason: unauthenticated customer access attempt to $route');
    AppLogger.info('[AUTH_SESSION] Middleware decision: redirect to client-login');
    return RouteSettings(
      name: '${AppRoutes.customerLogin}?redirect=$encodedRoute',
    );
  }
}
