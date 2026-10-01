import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_routes.dart';
import '../constants/app_roles.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../data/datasources/local_storage_source.dart';

/// Route guard for all administrative routes.
///
/// Validates:
/// 1. 24-hour application session lifetime (immutable across route changes, page refreshes, and API calls)
/// 2. Active Firebase authentication
/// 3. Staff / Admin role authorization
///
/// Distinguishes between:
/// - Authenticated admin (allowed)
/// - Authenticated non-admin (denied)
/// - Session expired after 24h (session terminated & redirected)
/// - Unauthenticated user (redirected to login with original target path)
class AdminAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      final encodedRoute = Uri.encodeComponent(route ?? '');
      return RouteSettings(
        name: '${AppRoutes.login}?redirect=$encodedRoute',
      );
    }

    final auth = Get.find<AuthController>();

    // ── 1. Check Canonical 24-Hour Application Session ─────────────────────
    if (auth.isSessionExpired()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (auth.rxIsLoggedIn.value || currentUser != null) {
        auth.handleSessionExpired();
      }
      final encodedRoute = Uri.encodeComponent(route ?? '');
      return RouteSettings(
        name: '${AppRoutes.login}?redirect=$encodedRoute',
      );
    }

    // If bootstrap is still in progress in AppBootstrapGate, pass through so splash displays
    if (!auth.rxAdminBootstrapped.value && !auth.isSessionExpired()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null || (Get.isRegistered<LocalStorageSource>() && Get.find<LocalStorageSource>().getAdminCachedRole() != null)) {
        return null;
      }
    }

    // ── 2. Check In-Memory Role Authorization ─────────────────────────────
    final role = auth.rxAdminRole.value?.roleType ?? auth.rxUserRole.value;
    final isStaffOrAdmin = auth.rxAdminRole.value != null ||
        role == AppRoles.superAdmin ||
        role == AppRoles.demoAdmin ||
        role == 'admin' ||
        role == 'manager' ||
        role == 'staff';

    // If logged in as staff/admin and within 24-hour session, allow access immediately
    if (auth.rxIsLoggedIn.value && isStaffOrAdmin) {
      return null;
    }

    // ── 3. Persistent Auth Fallback on Browser Reload / Cold Navigation ────
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.isAnonymous) {
      if (Get.isRegistered<LocalStorageSource>()) {
        final localStorage = Get.find<LocalStorageSource>();
        final cachedRole = localStorage.getAdminCachedRole();
        final isCachedStaffOrAdmin = cachedRole == AppRoles.superAdmin ||
            cachedRole == AppRoles.demoAdmin ||
            cachedRole == 'admin' ||
            cachedRole == 'manager' ||
            cachedRole == 'staff';

        if (isCachedStaffOrAdmin || isStaffOrAdmin) {
          auth.rxIsLoggedIn.value = true;
          if (cachedRole != null && auth.rxUserRole.value.isEmpty) {
            auth.rxUserRole.value = cachedRole;
          }
          return null; // Session valid & authorized — allow access
        }
      }
    }

    // ── 4. Unauthenticated or Unauthorized — Redirect to Login ─────────────
    final encodedRoute = Uri.encodeComponent(route ?? '');
    return RouteSettings(
      name: '${AppRoutes.login}?redirect=$encodedRoute',
    );
  }
}
