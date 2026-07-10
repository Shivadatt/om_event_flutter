import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/services/listener_registry_service.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/services/notification_handler_service.dart';
import '../../core/services/fcm/fcm_module.dart';

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
      debugPrint("BOOTSTRAP: Auth state changed. User: ${user?.uid}, Sequence: $sequenceId");
      
      if (!Get.isRegistered<ListenerRegistryService>()) {
        Get.put(ListenerRegistryService());
      }
      final registry = ListenerRegistryService.to;

      if (user == null) {
        if (sequenceId != _currentAuthSequence) return; // Discard stale state
        rxUserRole.value = 'guest';
        registry.registerGuestListeners();
        debugPrint("BOOTSTRAP: Guest mode initialized.");
        rxIsApplicationReady.value = true;
        return;
      }

      try {
        final role = await _getUserRole(user.uid);
        if (sequenceId != _currentAuthSequence) {
          debugPrint("BOOTSTRAP: Discarding stale role resolution for sequence: $sequenceId");
          return;
        }

        rxUserRole.value = role;
        debugPrint("BOOTSTRAP: Authenticated UID: ${user.uid}, Resolved Role: $role");

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
        debugPrint("BOOTSTRAP ERROR: Failed resolving role metadata: $e");
      } finally {
        if (sequenceId == _currentAuthSequence) {
          rxIsApplicationReady.value = true;
        }
      }
    });
  }

  /// Resolves user role without triggering unnecessary permission errors.
Future<String> _getUserRole(String uid) async {
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
          debugPrint(
              "BOOTSTRAP INFO: Admin metadata unavailable, using users.role");
        }

        return role;
      }

      return role ?? 'customer';
    }
  } catch (e) {
    debugPrint("BOOTSTRAP WARNING: User role lookup failed - $e");
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
