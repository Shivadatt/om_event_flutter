import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_roles.dart';
import '../../core/services/app_bootstrap_service.dart';
import '../../core/utils/app_logger.dart';
import '../bindings/initial_binding.dart';
import '../controllers/auth_controller.dart';
import '../screens/splash/video_splash_screen.dart';

import '../controllers/customer_auth_controller.dart';
import '../../core/utils/auth_route_helper.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../core/config/app_routes.dart';

/// Application bootstrap states for startup and reload gating.
enum AppBootstrapState {
  initializing,
  authenticated,
  unauthenticated,
  sessionExpired,
  authorizationFailed,
  error,
}

/// Root application bootstrap gate.
///
/// Ensures that on every application reload, restart, fresh tab load, or direct URL
/// entry to any route, the luxury OM Events Splash Screen is the FIRST visible screen
/// rendered before ANY application UI or heavy data loading.
///
/// Required sequence:
/// `App launch → Existing splash widget renders → Video loads and plays → Existing splash completion logic → Correct destination`
class AppBootstrapGate extends StatefulWidget {
  final Widget? child;

  const AppBootstrapGate({super.key, this.child});

  @override
  State<AppBootstrapGate> createState() => _AppBootstrapGateState();

  /// Checks if a given route path belongs to the administrative section.
  static bool isAdminPath(String path) {
    final clean = path.trim().toLowerCase();
    final normalized = clean.startsWith('#') ? clean.substring(1) : clean;
    return normalized == '/admin' ||
        normalized.startsWith('/admin/') ||
        normalized == '/admin-dashboard' ||
        normalized.startsWith('/admin-dashboard');
  }

  /// Checks if a given route path belongs to the customer protected lounge.
  static bool isCustomerProtectedPath(String path) {
    final clean = path.trim().toLowerCase();
    final normalized = clean.startsWith('#') ? clean.substring(1) : clean;
    final uri = Uri.tryParse(normalized);
    final routePath = uri?.path ?? normalized;
    return routePath == '/dashboard' || routePath.startsWith('/dashboard/');
  }

  /// Checks if a given route path belongs to the customer login screen.
  static bool isCustomerLoginPath(String path) {
    final clean = path.trim().toLowerCase();
    final normalized = clean.startsWith('#') ? clean.substring(1) : clean;
    final uri = Uri.tryParse(normalized);
    final routePath = uri?.path ?? normalized;
    return routePath == '/client-login' || routePath.startsWith('/client-login/');
  }
}

class _AppBootstrapGateState extends State<AppBootstrapGate> {
  AppBootstrapState _bootstrapState = AppBootstrapState.initializing;

  @override
  void initState() {
    super.initState();
    _bootstrapState = AppBootstrapState.initializing;
    _runAppBootstrap();
  }

  /// Determines if the current startup or page reload target is an admin route.
  bool _isTargetingAdmin() {
    final path = Uri.base.path;
    final fragment = Uri.base.fragment;
    final defaultRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;

    return AppBootstrapGate.isAdminPath(path) ||
        AppBootstrapGate.isAdminPath(fragment) ||
        AppBootstrapGate.isAdminPath(defaultRoute);
  }

  /// Determines if the current startup or page reload target is customer protected (/dashboard).
  bool _isTargetingCustomerProtected() {
    final path = Uri.base.path;
    final fragment = Uri.base.fragment;
    final defaultRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;

    return AppBootstrapGate.isCustomerProtectedPath(path) ||
        AppBootstrapGate.isCustomerProtectedPath(fragment) ||
        AppBootstrapGate.isCustomerProtectedPath(defaultRoute);
  }

  /// Determines if the current startup or page reload target is customer login (/client-login).
  bool _isTargetingCustomerLogin() {
    final path = Uri.base.path;
    final fragment = Uri.base.fragment;
    final defaultRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;

    return AppBootstrapGate.isCustomerLoginPath(path) ||
        AppBootstrapGate.isCustomerLoginPath(fragment) ||
        AppBootstrapGate.isCustomerLoginPath(defaultRoute);
  }


  /// Executes the canonical startup authentication, dependency setup, and session sequence.
  Future<void> _runAppBootstrap() async {
    final stopwatch = Stopwatch()..start();
    AppBootstrapState targetState = AppBootstrapState.authenticated;
    AppLogger.info(
      'Starting AppBootstrapGate sequence',
      className: 'AppBootstrapGate',
      methodName: '_runAppBootstrap',
    );

    try {
      // 1. Await background non-blocking core services (Firebase + SharedPreferences)
      await AppBootstrapService.ensureInitialized();

      // 2. Register application dependencies if not already registered
      if (!Get.isRegistered<AuthController>()) {
        InitialBinding().dependencies();
        AppLogger.success(
          'InitialBinding dependencies registered via AppBootstrapGate',
          className: 'AppBootstrapGate',
          methodName: '_runAppBootstrap',
        );
      }

      // 3. Resolve route-specific authorization
      if (_isTargetingAdmin()) {
        final authController = Get.find<AuthController>();

        // Await Firebase Auth state restoration on Flutter Web (IndexedDB)
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null && !authController.isSessionExpired()) {
          try {
            currentUser = await FirebaseAuth.instance
                .authStateChanges()
                .where((user) => user != null)
                .first
                .timeout(
                  const Duration(milliseconds: 2500),
                  onTimeout: () => FirebaseAuth.instance.currentUser,
                );
          } catch (_) {
            currentUser = FirebaseAuth.instance.currentUser;
          }
        }

        // Validate Canonical 24-hour admin session
        final hasAdminSession = Get.isRegistered<LocalStorageSource>() &&
            Get.find<LocalStorageSource>().getAdminSessionStartedAt() != null;
        final isExpired = authController.isSessionExpired();
        if (currentUser == null || isExpired) {
          if (hasAdminSession &&
              isExpired &&
              (currentUser != null || authController.rxIsLoggedIn.value)) {
            await authController.handleSessionExpired();
          } else {
            authController.rxIsLoggedIn.value = false;
            authController.rxUserRole.value = '';
            authController.rxAdminRole.value = null;
            authController.markAdminBootstrapped(false);
          }
          targetState = isExpired
              ? AppBootstrapState.sessionExpired
              : AppBootstrapState.unauthenticated;
        } else {
          // Restore role and admin metadata
          await authController.checkAuthStatus();

          final role = authController.rxAdminRole.value?.roleType ??
              authController.rxUserRole.value;
          final isStaffOrAdmin = authController.rxAdminRole.value != null ||
              role == AppRoles.superAdmin ||
              role == AppRoles.demoAdmin ||
              role == 'admin' ||
              role == 'manager' ||
              role == 'staff';

          if (isStaffOrAdmin) {
            authController.markAdminBootstrapped(true);
            authController.rxIsLoggedIn.value = true;
            targetState = AppBootstrapState.authenticated;
          } else {
            await authController.handleSessionExpired();
            targetState = AppBootstrapState.authorizationFailed;
          }
        }
      } else if (_isTargetingCustomerProtected()) {
        final customerAuth = Get.find<CustomerAuthController>();
        final localStorage = Get.find<LocalStorageSource>();

        // Step 1 & 2: Restore Firebase Auth state on Flutter Web (IndexedDB / persistence)
        AppLogger.info('[AUTH_STARTUP] Firebase currentUser before auth restoration: ${FirebaseAuth.instance.currentUser?.uid}');
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          try {
            currentUser = await FirebaseAuth.instance
                .authStateChanges()
                .where((user) => user != null)
                .first
                .timeout(
                  const Duration(milliseconds: 3500),
                  onTimeout: () => FirebaseAuth.instance.currentUser,
                );
            AppLogger.info('[AUTH_STARTUP] First authStateChanges() event received: uid=${currentUser?.uid}');
          } catch (_) {
            currentUser = FirebaseAuth.instance.currentUser;
          }
        }
        AppLogger.info('[AUTH_STARTUP] Firebase currentUser after auth restoration: ${currentUser?.uid}');

        // Step 3: Restore and validate session timestamp
        final startedAt = localStorage.getCustomerSessionStartedAt();
        final expiresAt = localStorage.getCustomerSessionExpiresAt();
        final isExpired = localStorage.isCustomerSessionExpired();
        AppLogger.info('[AUTH_STARTUP] Session timestamp validation: startedAt=$startedAt, expiresAt=$expiresAt, isExpired=$isExpired');

        // Step 4: Validate customer role and profile
        final isAdmin = AuthRouteHelper.isCurrentAdminOrStaff();

        if (isAdmin) {
          targetState = AppBootstrapState.authorizationFailed;
          AppLogger.info('[AUTH_STARTUP] Customer role/profile validation result: REJECTED (admin attempting customer lounge)');
          AppLogger.info('[AUTH_SESSION] Redirect reason: admin cannot access client lounge');
          AppLogger.info('[AUTH_SESSION] Middleware decision: redirecting admin to adminDashboard');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.adminDashboard);
          });
        } else if (currentUser == null || currentUser.isAnonymous || isExpired) {
          AppLogger.info('[AUTH_STARTUP] Customer role/profile validation result: REJECTED (currentUser=${currentUser?.uid}, isExpired=$isExpired)');
          if (isExpired && currentUser != null) {
            AppLogger.info('[AUTH_SESSION] Explicit sign-out caller: AppBootstrapGate._runAppBootstrap, reason: 2-hour session expired during startup');
            await customerAuth.handleSessionExpired();
          } else {
            customerAuth.rxIsLoggedIn.value = false;
            customerAuth.rxCustomerProfile.value = null;
          }
          customerAuth.markCustomerBootstrapped(true);
          targetState = isExpired
              ? AppBootstrapState.sessionExpired
              : AppBootstrapState.unauthenticated;

          final reason = isExpired ? 'session expired' : 'unauthenticated customer';
          AppLogger.info('[AUTH_SESSION] Redirect reason: $reason');
          AppLogger.info('[AUTH_SESSION] Middleware decision: redirecting to client-login');

          // Perform redirect to client login preserving destination redirect parameter
          final encoded = Uri.encodeComponent(AppRoutes.customerDashboard);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('${AppRoutes.customerLogin}?redirect=$encoded');
          });
        } else {
          // Step 5: Valid customer within 2 hours -> navigate to / stay on dashboard
          await customerAuth.checkAuthStatus();
          final profileValid = customerAuth.isAuthenticatedCustomer;
          AppLogger.info('[AUTH_STARTUP] Customer role/profile validation result: ${profileValid ? "SUCCESS" : "FALLBACK_PROFILE"}');
          customerAuth.markCustomerBootstrapped(true);
          targetState = AppBootstrapState.authenticated;
          AppLogger.info('[AUTH_SESSION] Middleware decision: customer session active, staying on dashboard');
        }
      } else if (_isTargetingCustomerLogin()) {
        final customerAuth = Get.find<CustomerAuthController>();
        final localStorage = Get.find<LocalStorageSource>();

        // Step 1 & 2: Restore Firebase Auth state on client login page to handle reload
        AppLogger.info('[AUTH_STARTUP] [LoginScreen] Firebase currentUser before auth restoration: ${FirebaseAuth.instance.currentUser?.uid}');
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          try {
            currentUser = await FirebaseAuth.instance
                .authStateChanges()
                .where((user) => user != null)
                .first
                .timeout(
                  const Duration(milliseconds: 3000),
                  onTimeout: () => FirebaseAuth.instance.currentUser,
                );
            AppLogger.info('[AUTH_STARTUP] [LoginScreen] First authStateChanges() event received: uid=${currentUser?.uid}');
          } catch (_) {
            currentUser = FirebaseAuth.instance.currentUser;
          }
        }
        AppLogger.info('[AUTH_STARTUP] [LoginScreen] Firebase currentUser after auth restoration: ${currentUser?.uid}');

        // Step 3 & 4: Validate session and role
        final startedAt = localStorage.getCustomerSessionStartedAt();
        final expiresAt = localStorage.getCustomerSessionExpiresAt();
        final isExpired = localStorage.isCustomerSessionExpired();
        final isAdmin = AuthRouteHelper.isCurrentAdminOrStaff();
        AppLogger.info('[AUTH_STARTUP] [LoginScreen] Session status: startedAt=$startedAt, expiresAt=$expiresAt, isExpired=$isExpired, isAdmin=$isAdmin');

        if (currentUser != null && !currentUser.isAnonymous && !isAdmin && !isExpired) {
          await customerAuth.checkAuthStatus();
          customerAuth.markCustomerBootstrapped(true);
          targetState = AppBootstrapState.authenticated;
          AppLogger.info('[AUTH_STARTUP] [LoginScreen] Customer role/profile validation result: SUCCESS');

          // Seamless redirect from /client-login to requested protected route
          final rawRedirect = Uri.base.queryParameters['redirect'];
          final destination = (rawRedirect != null && rawRedirect.isNotEmpty)
              ? Uri.decodeComponent(rawRedirect)
              : AppRoutes.customerDashboard;
          AppLogger.info('[AUTH_SESSION] Auto-redirecting authenticated customer from login to $destination');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(destination);
          });
        } else {
          if (isExpired && currentUser != null && !isAdmin) {
            AppLogger.info('[AUTH_SESSION] Explicit sign-out caller: AppBootstrapGate._runAppBootstrap (LoginScreen), reason: session expired on login screen');
            await customerAuth.handleSessionExpired();
          }
          customerAuth.markCustomerBootstrapped(true);
          targetState = AppBootstrapState.authenticated;
        }
      } else {
        // Public / non-protected route (e.g. /, /gallery, etc.)
        if (Get.isRegistered<CustomerAuthController>()) {
          final customerAuth = Get.find<CustomerAuthController>();
          final localStorage = Get.find<LocalStorageSource>();
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && !AuthRouteHelper.isCurrentAdminOrStaff()) {
            if (localStorage.isCustomerSessionExpired()) {
              await customerAuth.handleSessionExpired();
            } else {
              customerAuth.checkAuthStatus();
            }
          }
          customerAuth.markCustomerBootstrapped(true);
        }
        targetState = AppBootstrapState.authenticated;
      }

    } catch (e) {
      AppLogger.error(
        'Startup bootstrap error caught',
        e,
      );
      targetState = AppBootstrapState.authenticated; // Safe fallback so app doesn't lock
    } finally {
      // Ensure smooth visual transition for branding (minimum 2500ms splash duration so video plays visibly)
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 2500) {
        await Future.delayed(Duration(milliseconds: 2500 - elapsed));
      }

      if (mounted) {
        setState(() {
          _bootstrapState = targetState;
        });

        AppLogger.success(
          'AppBootstrapGate transitioned to $_bootstrapState in ${stopwatch.elapsedMilliseconds}ms',
          className: 'AppBootstrapGate',
          methodName: '_runAppBootstrap',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapState == AppBootstrapState.initializing) {
      return const VideoSplashScreen(isBootstrapGate: true);
    }

    return widget.child ?? const SizedBox.shrink();
  }
}
