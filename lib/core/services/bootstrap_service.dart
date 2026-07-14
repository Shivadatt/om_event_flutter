import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_roles.dart';
import '../../core/constants/app_permissions.dart';
import '../../core/services/listener_registry_service.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/services/notification_handler_service.dart';
import '../../core/services/fcm/fcm_module.dart';
import '../utils/app_logger.dart';

/// The sole startup orchestrator for authentication, role resolution, and stream listener lifecycle mapping.
class BootstrapService extends GetxService {
  static BootstrapService get to => Get.find<BootstrapService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final rxIsApplicationReady = false.obs;
  final rxUserRole = 'guest'.obs;

  StreamSubscription<User?>? _authSub;
  int _currentAuthSequence = 0; // Sequence lock

  @override
  void onInit() {
    super.onInit();
    _startBootstrapSequence();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  /// Sole authentication listener across the entire codebase.
  /// Resolves the user state and maps database stream registrations accordingly.
  void _startBootstrapSequence() {
    _authSub = _auth.authStateChanges().listen((user) async {
      final sequenceId = ++_currentAuthSequence; // Increment on every emission
      rxIsApplicationReady.value = false;
      AppLogger.info("Auth state changed. User: ${user?.uid}, Sequence: $sequenceId", layer: LogLayer.core, className: "BootstrapService", methodName: "_startBootstrapSequence");
      
      if (!Get.isRegistered<ListenerRegistryService>()) {
        Get.put(ListenerRegistryService());
      }
      final registry = ListenerRegistryService.to;

      if (user == null) {
        if (sequenceId != _currentAuthSequence) return; // Discard stale state
        rxUserRole.value = 'guest';
        registry.registerGuestListeners();
        AppLogger.success("Guest mode initialized.", layer: LogLayer.core, className: "BootstrapService", methodName: "_startBootstrapSequence");
        rxIsApplicationReady.value = true;
        return;
      }

      try {
        final role = await _getUserRole(user.uid);
        if (sequenceId != _currentAuthSequence) {
          AppLogger.warning("Discarding stale role resolution for sequence: $sequenceId", layer: LogLayer.core, className: "BootstrapService", methodName: "_startBootstrapSequence");
          return;
        }

        rxUserRole.value = role;
        AppLogger.success("Resolved User Role. UID: ${user.uid}, Resolved Role: $role", layer: LogLayer.core, className: "BootstrapService", methodName: "_startBootstrapSequence");

        if (role == 'admin' || role == 'staff' || role == 'demo_admin' || role == 'super_admin') {
          registry.registerAdminListeners(user.uid);
        } else {
          registry.registerCustomerListeners(user.uid);
        }

        // Initialize FCM Notifications explicitly here, AFTER role resolution
        FcmService.to.initialize(
          userId: user.uid,
          role: role,
        );
        if (!Get.isRegistered<NotificationHandlerService>()) {
          Get.find<NotificationHandlerService>();
        }
        FcmNotificationService.to.initializeUserFcm(user.uid, role: role);

      } catch (e) {
        AppLogger.errorDetailed("Failed resolving role metadata", layer: LogLayer.core, className: "BootstrapService", methodName: "_startBootstrapSequence", error: e);
      } finally {
        if (sequenceId == _currentAuthSequence) {
          rxIsApplicationReady.value = true;
        }
      }
    });
  }

  /// Resolves user role without triggering unnecessary permission errors.
  Future<String> _getUserRole(String uid) async {
    // Check if the current user has an admin email but no admin/users document (e.g. database was wiped/seeded)
    // If so, bootstrap their role document in Firestore.
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == uid) {
      final emailLower = currentUser.email?.toLowerCase().trim() ?? '';
      final isSuper = emailLower == AppStrings.businessEmail || emailLower == 'admin@omevents.in';
      final isDemo = emailLower == AppStrings.demoAdminEmail || emailLower == 'demo@omevents.in';
      
      if (isSuper || isDemo) {
        try {
          final adminDoc = await _firestore
              .collection(AppCollections.admin)
              .doc(uid)
              .get();
          
          if (!adminDoc.exists) {
            final roleType = isSuper ? AppRoles.superAdmin : AppRoles.demoAdmin;
            final permissions = isSuper
                ? AppPermissions.superAdminPermissions
                : AppPermissions.demoAdminPermissions;
                
            await _firestore.collection(AppCollections.admin).doc(uid).set({
              AppStrings.fieldUid: uid,
              AppStrings.fieldName: isSuper
                  ? AppStrings.superAdminName
                  : AppStrings.demoAdminName,
              AppStrings.fieldEmail: currentUser.email,
              AppStrings.fieldRole: roleType,
              AppStrings.fieldRoleType: roleType,
              AppStrings.fieldIsActive: true,
              AppStrings.fieldCreatedAt: DateTime.now().toIso8601String(),
              AppStrings.fieldUpdatedAt: DateTime.now().toIso8601String(),
              AppStrings.fieldCreatedBy: AppStrings.createdBySystem,
              AppStrings.fieldPermissions: permissions,
            });
            AppLogger.success("Self-bootstrapped admin role document for email: $emailLower", layer: LogLayer.core, className: "BootstrapService", methodName: "_getUserRole");
            return roleType;
          }
        } catch (e) {
          AppLogger.errorDetailed("Failed to self-bootstrap admin document", layer: LogLayer.core, className: "BootstrapService", methodName: "_getUserRole", error: e);
        }
      }
    }

    // STEP 1: Users collection (this is the primary source)
    try {
    final userDoc = await _firestore
        .collection(AppCollections.users)
        .doc(uid)
        .get();

    if (userDoc.exists) {
      final role = userDoc.data()?['role'];

      // Agar role admin/staff hai aur extra metadata chahiye tabhi admin collection check karo
      if (role == 'admin' ||
          role == 'staff' ||
          role == 'super_admin' ||
          role == 'demo_admin') {
        try {
          final adminDoc = await _firestore
              .collection(AppCollections.admin)
              .doc(uid)
              .get();

          if (adminDoc.exists) {
            return adminDoc.data()?['roleType'] ??
                adminDoc.data()?['role'] ??
                role;
          }
        } catch (e) {
          AppLogger.info("Admin metadata unavailable, using users.role", layer: LogLayer.core, className: "BootstrapService", methodName: "_getUserRole");
        }

        return role;
      }

      return role ?? 'customer';
    }
  } catch (e) {
    AppLogger.warning("User role lookup failed", layer: LogLayer.core, className: "BootstrapService", methodName: "_getUserRole", error: e);
  }

  // STEP 2: Fallback only
  try {
    final adminDoc = await _firestore
        .collection(AppCollections.admin)
        .doc(uid)
        .get();

    if (adminDoc.exists) {
      return adminDoc.data()?['roleType'] ??
          adminDoc.data()?['role'] ??
          'admin';
    }
  } catch (_) {}

  return 'customer';
}
}
