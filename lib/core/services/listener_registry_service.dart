import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/services/local_notification_trigger_service.dart';
import '../../core/services/app_config_service.dart';
import '../utils/app_logger.dart';

/// Centralized registry managing ALL active Firestore stream subscriptions.
/// Controllers and services must register their streams here to prevent listener leaks and permission conflicts.
class ListenerRegistryService extends GetxService {
  static ListenerRegistryService get to => Get.find<ListenerRegistryService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active listener subscriptions registry map
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  /// Attaches a stream listener, registering it under a specific key to handle lifecycle tracking automatically.
  void registerAndListen<T>(String key, Stream<T> stream, void Function(T) onData, {void Function(Object e, StackTrace s)? onError}) {
    _activeSubscriptions[key]?.cancel();
    final sub = stream.listen(
      onData,
      onError: (e, stack) {
        AppLogger.errorDetailed("LISTENER REGISTRY ERROR [$key]", error: e, stack: stack, layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerAndListen");
        if (onError != null) {
          onError(e, stack);
        }
      },
    );
    _activeSubscriptions[key] = sub;
    AppLogger.info("LISTENER REGISTRY: Registered stream listener '$key'", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerAndListen");
  }

  void registerListener(String key, StreamSubscription sub) {
    _activeSubscriptions[key]?.cancel();
    _activeSubscriptions[key] = sub;
    AppLogger.info("LISTENER REGISTRY: Registered stream listener '$key'", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerListener");
  }

  void pauseListener(String key) {
    if (_activeSubscriptions.containsKey(key)) {
      _activeSubscriptions[key]!.pause();
      AppLogger.info("LISTENER REGISTRY: Paused stream listener '$key'", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "pauseListener");
    }
  }

  void resumeListener(String key) {
    if (_activeSubscriptions.containsKey(key)) {
      _activeSubscriptions[key]!.resume();
      AppLogger.info("LISTENER REGISTRY: Resumed stream listener '$key'", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "resumeListener");
    }
  }

  void disposeListener(String key) {
    _activeSubscriptions[key]?.cancel();
    _activeSubscriptions.remove(key);
    AppLogger.info("LISTENER REGISTRY: Disposed stream listener '$key'", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "disposeListener");
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
    AppLogger.success("LISTENER REGISTRY: Cleaned up all active listeners on logout.", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "cleanupOnLogout");
  }

  /// Guest mode: Zero protected streams attached
  void registerGuestListeners() {
    cleanupOnLogout();
    AppLogger.success("LISTENER REGISTRY: Guest mode listeners initialized (zero protected streams).", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerGuestListeners");
  }

  /// Admin mode: register global admin dashboard streams
  void registerAdminListeners(String adminId) {
    cleanupOnLogout();
    AppLogger.info("LISTENER REGISTRY: Registering admin-scoped listeners for admin ID: $adminId", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerAdminListeners");

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
      onError: (e) => AppLogger.errorDetailed("LISTENER REGISTRY ERROR [leads]", error: e, layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerAdminListeners"),
    );
    registerListener('leads', leadsSub);

    // 3. Quotation listener (Global, delegated to LocalNotificationTriggerService)
    final quotesSub = _firestore.collection(AppCollections.quotations).snapshots().listen(
      (snap) {
        if (Get.isRegistered<LocalNotificationTriggerService>()) {
          LocalNotificationTriggerService.to.handleQuotationsSnapshot(snap);
        }
      },
      onError: (e) => AppLogger.errorDetailed("LISTENER REGISTRY ERROR [quotations]", error: e, layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerAdminListeners"),
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
        onError: (e) => AppLogger.errorDetailed("LISTENER REGISTRY ERROR [queue]", error: e, layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerAdminListeners"),
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
    AppLogger.info("LISTENER REGISTRY: Registering customer-scoped listeners for customer ID: $customerId", layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerCustomerListeners");

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
      onError: (e) => AppLogger.errorDetailed("LISTENER REGISTRY ERROR [customer_quotations]", error: e, layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerCustomerListeners"),
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
      onError: (e) => AppLogger.errorDetailed("LISTENER REGISTRY ERROR [customer_notifications]", error: e, layer: LogLayer.core, className: "ListenerRegistryService", methodName: "registerCustomerListeners"),
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
