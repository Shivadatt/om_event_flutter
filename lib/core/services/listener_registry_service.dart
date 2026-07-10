import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/services/local_notification_trigger_service.dart';
import '../../core/services/app_config_service.dart';

/// Centralized registry managing ALL active Firestore stream subscriptions.
/// Controllers and services must register their streams here to prevent listener leaks and permission conflicts.
class ListenerRegistryService extends GetxService {
  static ListenerRegistryService get to => Get.find<ListenerRegistryService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active listener subscriptions registry map
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  /// Attaches a stream listener, registering it under a specific key to handle lifecycle tracking automatically.
  void registerAndListen<T>(String key, Stream<T> stream, void Function(T) onData) {
    _activeSubscriptions[key]?.cancel();
    final sub = stream.listen(
      onData,
      onError: (e, stack) {
        debugPrint("LISTENER REGISTRY ERROR [$key]: $e");
      },
    );
    _activeSubscriptions[key] = sub;
    debugPrint("LISTENER REGISTRY: Registered stream listener '$key'");
  }

  void registerListener(String key, StreamSubscription sub) {
    _activeSubscriptions[key]?.cancel();
    _activeSubscriptions[key] = sub;
    debugPrint("LISTENER REGISTRY: Registered stream listener '$key'");
  }

  void pauseListener(String key) {
    if (_activeSubscriptions.containsKey(key)) {
      _activeSubscriptions[key]!.pause();
      debugPrint("LISTENER REGISTRY: Paused stream listener '$key'");
    }
  }

  void resumeListener(String key) {
    if (_activeSubscriptions.containsKey(key)) {
      _activeSubscriptions[key]!.resume();
      debugPrint("LISTENER REGISTRY: Resumed stream listener '$key'");
    }
  }

  void disposeListener(String key) {
    _activeSubscriptions[key]?.cancel();
    _activeSubscriptions.remove(key);
    debugPrint("LISTENER REGISTRY: Disposed stream listener '$key'");
  }

  /// Cancels all active subscriptions on logout
  void cleanupOnLogout() {
    for (final sub in _activeSubscriptions.values) {
      sub.cancel();
    }
    _activeSubscriptions.clear();
    
    // Unbind admin-only settings streams on logout
    if (Get.isRegistered<AppConfigService>()) {
      AppConfigService.to.unbindAdminStreams();
    }

    if (Get.isRegistered<LocalNotificationTriggerService>()) {
      LocalNotificationTriggerService.to.teardown();
    }
    debugPrint("LISTENER REGISTRY: Cleaned up all active listeners on logout.");
  }

  /// Guest mode: Zero protected streams attached
  void registerGuestListeners() {
    cleanupOnLogout();
    debugPrint("LISTENER REGISTRY: Guest mode listeners initialized (zero protected streams).");
  }

  /// Admin mode: register global admin dashboard streams
  void registerAdminListeners(String adminId) {
    cleanupOnLogout();
    debugPrint("LISTENER REGISTRY: Registering admin-scoped listeners for admin ID: $adminId");

    // 1. Bind sensitive admin configuration settings streams
    if (Get.isRegistered<AppConfigService>()) {
      AppConfigService.to.bindAdminStreams();
    }

    // 2. Leads Listener (delegated to LocalNotificationTriggerService)
    final leadsSub = _firestore.collection(AppCollections.leads).snapshots().listen(
      (snap) {
        if (Get.isRegistered<LocalNotificationTriggerService>()) {
          LocalNotificationTriggerService.to.handleLeadsSnapshot(snap);
        }
      },
      onError: (e) => debugPrint("LISTENER REGISTRY ERROR [leads]: $e"),
    );
    registerListener('leads', leadsSub);

    // 3. Quotation listener (Global, delegated to LocalNotificationTriggerService)
    final quotesSub = _firestore.collection(AppCollections.quotations).snapshots().listen(
      (snap) {
        if (Get.isRegistered<LocalNotificationTriggerService>()) {
          LocalNotificationTriggerService.to.handleQuotationsSnapshot(snap);
        }
      },
      onError: (e) => debugPrint("LISTENER REGISTRY ERROR [quotations]: $e"),
    );
    registerListener('quotations', quotesSub);

    // 4. Notification Queue Listener (Debug Mode only, delegated to LocalNotificationTriggerService)
    if (kDebugMode) {
      final queueSub = _firestore
          .collection(AppCollections.notificationQueue)
          .where('status', whereIn: ['pending', 'paused_dnd'])
          .snapshots()
          .listen(
        (snap) {
          if (Get.isRegistered<LocalNotificationTriggerService>()) {
            LocalNotificationTriggerService.to.handleQueueSnapshot(snap);
          }
        },
        onError: (e) => debugPrint("LISTENER REGISTRY ERROR [queue]: $e"),
      );
      registerListener('queue', queueSub);
    }

    // 5. Initialize background/local trigger tasks
    if (Get.isRegistered<LocalNotificationTriggerService>()) {
      LocalNotificationTriggerService.to.initForUser(adminId, 'admin');
    }
  }

  /// Customer mode: register customer-scoped streams
  void registerCustomerListeners(String customerId) {
    cleanupOnLogout();
    debugPrint("LISTENER REGISTRY: Registering customer-scoped listeners for customer ID: $customerId");

    // 1. Customer Quotation Listener (scoped to customerId)
    final quotesSub = _firestore
        .collection(AppCollections.quotations)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .listen(
      (snap) {
        if (Get.isRegistered<LocalNotificationTriggerService>()) {
          LocalNotificationTriggerService.to.handleQuotationsSnapshot(snap);
        }
      },
      onError: (e) => debugPrint("LISTENER REGISTRY ERROR [customer_quotations]: $e"),
    );
    registerListener('quotations', quotesSub);

    // 2. Scoped notifications
    final notifSub = _firestore
        .collection(AppCollections.customerNotifications)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .listen(
      (snap) {
        // Scoped notifications sync
      },
      onError: (e) => debugPrint("LISTENER REGISTRY ERROR [customer_notifications]: $e"),
    );
    registerListener('notifications', notifSub);

    // 3. Initialize background trigger tasks
    if (Get.isRegistered<LocalNotificationTriggerService>()) {
      LocalNotificationTriggerService.to.initForUser(customerId, 'customer');
    }
  }

  @override
  void onClose() {
    cleanupOnLogout();
    super.onClose();
  }
}
