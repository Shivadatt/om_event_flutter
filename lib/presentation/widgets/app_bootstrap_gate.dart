import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_roles.dart';
import '../../core/utils/app_logger.dart';
import '../controllers/auth_controller.dart';
import '../screens/splash/video_splash_screen.dart';

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
/// entry to an admin route (/admin, /admin-dashboard, /admin/*), the luxury OM Events
/// Splash Screen is the FIRST visible screen rendered before ANY admin UI or data loading.
///
/// While the splash is visible:
/// 1. Firebase Auth restoration is completed.
/// 2. Canonical 24-hour admin session lifetime is validated.
/// 3. Staff / Super Admin role authorization is verified.
/// 4. Routing decision is established before mounting the Navigator.
///
/// Normal in-app route changes between already-running admin screens do NOT re-trigger splash.
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
}

class _AppBootstrapGateState extends State<AppBootstrapGate> {
  AppBootstrapState _bootstrapState = AppBootstrapState.initializing;

  @override
  void initState() {
    super.initState();
    if (_isTargetingAdmin()) {
      _bootstrapState = AppBootstrapState.initializing;
      _runAdminBootstrap();
    } else {
      // Customer / public pages bypass admin startup gate
      _bootstrapState = AppBootstrapState.authenticated;
    }
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

  /// Executes the canonical startup authentication and session validation sequence.
  Future<void> _runAdminBootstrap() async {
    final stopwatch = Stopwatch()..start();

    try {
      final authController = Get.find<AuthController>();

      // 1. Await Firebase Auth state restoration on Flutter Web (IndexedDB)
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        try {
          currentUser = await FirebaseAuth.instance
              .authStateChanges()
              .first
              .timeout(
                const Duration(milliseconds: 1500),
                onTimeout: () => FirebaseAuth.instance.currentUser,
              );
        } catch (_) {
          currentUser = FirebaseAuth.instance.currentUser;
        }
      }

      // 2. Validate Canonical 24-hour admin session
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
        _bootstrapState = isExpired
            ? AppBootstrapState.sessionExpired
            : AppBootstrapState.unauthenticated;
      } else {
        // 3. Restore role and admin metadata
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
          _bootstrapState = AppBootstrapState.authenticated;
        } else {
          // User is authenticated in Firebase but does not have admin permissions
          await authController.handleSessionExpired();
          _bootstrapState = AppBootstrapState.authorizationFailed;
        }
      }
    } catch (e) {
      AppLogger.error('Admin startup bootstrap error', e);
      _bootstrapState = AppBootstrapState.error;
    } finally {
      // Ensure smooth visual transition for branding (minimum 1400ms splash duration)
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 1400) {
        await Future.delayed(Duration(milliseconds: 1400 - elapsed));
      }

      if (mounted) {
        setState(() {});
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
