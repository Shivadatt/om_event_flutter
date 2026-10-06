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

  static const Map<String, String> _routePermissions = {
    AppRoutes.manageCategories: 'can_manage_categories',
    AppRoutes.manageExperiences: 'can_manage_items',
    AppRoutes.manageCustomers: 'can_manage_customers',
    AppRoutes.manageLeads: 'can_manage_leads',
    AppRoutes.manageQuotes: 'can_manage_quotes',
    AppRoutes.manageUsers: 'can_manage_users',
    AppRoutes.businessDetails: 'can_manage_settings',
    AppRoutes.systemSettings: 'can_manage_settings',
  };

  static String? _getRequiredPermission(String? route) {
    if (route == null) return null;
    var cleanRoute = route.split('?').first.split('#').first.trim();
    if (cleanRoute.length > 1 && cleanRoute.endsWith('/')) {
      cleanRoute = cleanRoute.substring(0, cleanRoute.length - 1);
    }
    if (_routePermissions.containsKey(cleanRoute)) {
      return _routePermissions[cleanRoute];
    }
    for (final entry in _routePermissions.entries) {
      if (cleanRoute.startsWith('${entry.key}/')) {
        return entry.value;
      }
    }
    return null;
  }

  RouteSettings? _checkRoutePermission(AuthController auth, String? route) {
    final requiredPermission = _getRequiredPermission(route);
    if (requiredPermission == null) {
      return null;
    }

    final admin = auth.rxAdminRole.value;
    final isSuperAdmin =
        auth.rxUserRole.value == 'super_admin' || admin?.roleType == 'super_admin';
    if (isSuperAdmin) {
      return null;
    }

    if (admin != null) {
      if (!admin.hasPermission(requiredPermission)) {
        _notifyAccessDenied();
        return const RouteSettings(name: AppRoutes.adminDashboard);
      }
      return null;
    }

    // Role is not yet loaded or user lacks permission — deny route access
    _notifyAccessDenied();
    return const RouteSettings(name: AppRoutes.adminDashboard);
  }

  void _notifyAccessDenied() {
    Future.microtask(() {
      if (Get.isSnackbarOpen != true) {
        Get.snackbar(
          "Access Denied",
          "You do not have permission to access this section.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2A1515),
          colorText: Colors.redAccent,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

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
    if (auth.rxIsLoggedIn.value && auth.isStaffOrAdmin) {
      final permCheck = _checkRoutePermission(auth, route);
      if (permCheck != null) return permCheck;
      return null;
    }

    // ── 3. Persistent Auth Fallback on Browser Reload / Cold Navigation ────
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && !currentUser.isAnonymous) {
      if (Get.isRegistered<LocalStorageSource>()) {
        final localStorage = Get.find<LocalStorageSource>();
        final cachedRole = localStorage.getAdminCachedRole();
        final isCachedStaffOrAdmin = AppRoles.isAdminRole(cachedRole);

        if (isCachedStaffOrAdmin || auth.isStaffOrAdmin) {
          auth.rxIsLoggedIn.value = true;
          if (cachedRole != null && auth.rxUserRole.value.isEmpty) {
            auth.rxUserRole.value = cachedRole;
          }
          final permCheck = _checkRoutePermission(auth, route);
          if (permCheck != null) return permCheck;
          return null; // Session valid & authorized — allow access
        }
      }

      // If active Firebase user is authenticated but NOT admin/staff, they are a CUSTOMER
      // Redirect customers attempting to access admin routes directly to Customer Lounge
      return const RouteSettings(name: AppRoutes.customerDashboard);
    }

    // ── 4. Unauthenticated — Redirect to Admin Login ───────────────────────
    final encodedRoute = Uri.encodeComponent(route ?? '');
    return RouteSettings(
      name: '${AppRoutes.login}?redirect=$encodedRoute',
    );
  }
}
