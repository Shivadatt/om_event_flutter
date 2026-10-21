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
        final isExpired = authController.isSessionExpired();
        if (currentUser == null || isExpired) {
          if (isExpired &&
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

        // Await Firebase Auth state restoration on Flutter Web (IndexedDB / persistence)
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null && !localStorage.isCustomerSessionExpired()) {
          try {
            currentUser = await FirebaseAuth.instance
                .authStateChanges()
                .where((user) => user != null)
                .first
                .timeout(
                  const Duration(milliseconds: 3000),
                  onTimeout: () => FirebaseAuth.instance.currentUser,
                );
          } catch (_) {
            currentUser = FirebaseAuth.instance.currentUser;
          }
        }

        AppLogger.info('[AUTH_SESSION] Initial auth state received: uid=${currentUser?.uid}');
        AppLogger.info('[AUTH_SESSION] Current user exists: ${currentUser != null}');

        final isAdmin = AuthRouteHelper.isCurrentAdminOrStaff();
        final isExpired = localStorage.isCustomerSessionExpired();

        if (isAdmin) {
          // Admin trying to enter client lounge -> redirect to admin dashboard
          targetState = AppBootstrapState.authorizationFailed;
          AppLogger.info('[AUTH_SESSION] Redirect reason: admin cannot access client lounge');
          AppLogger.info('[AUTH_SESSION] Middleware decision: redirecting admin to adminDashboard');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.adminDashboard);
          });
        } else if (currentUser == null || currentUser.isAnonymous || isExpired) {
          if (isExpired && currentUser != null) {
            AppLogger.info('[AUTH_SESSION] Explicit sign-out reason: 2-hour session expired during startup');
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
          // Restore customer profile and validate session
          await customerAuth.checkAuthStatus();
          customerAuth.markCustomerBootstrapped(true);
          targetState = AppBootstrapState.authenticated;
          AppLogger.info('[AUTH_SESSION] Middleware decision: customer session active, staying on dashboard');
        }
      } else {
        // Public / non-protected route (e.g. /client-login, /, /gallery, etc.)
        if (Get.isRegistered<CustomerAuthController>()) {
          final customerAuth = Get.find<CustomerAuthController>();
          final localStorage = Get.find<LocalStorageSource>();
          if (FirebaseAuth.instance.currentUser != null && !AuthRouteHelper.isCurrentAdminOrStaff()) {
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
