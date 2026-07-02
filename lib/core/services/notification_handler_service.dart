import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/config/app_routes.dart';
import '../../core/utils/app_logger.dart';

/// Isolate-safe background handler — must be a top-level function.
/// Called by Firebase when the app is completely terminated.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // NOTE: Firebase is already initialized by Flutter at this point.
  // We do NOT call Firebase.initializeApp() here — it causes double-init crashes.
  AppLogger.info(
      'BG Message: ${message.notification?.title} | data: ${message.data}');
}

/// Handles foreground, background-tap, and terminated-state FCM events.
/// This service is separate from [FcmNotificationService] to keep
/// token management and notification routing concerns clearly split.
class NotificationHandlerService extends GetxService {
  static NotificationHandlerService get to =>
      Get.find<NotificationHandlerService>();

  @override
  void onInit() {
    super.onInit();
    // Register the top-level background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    _setupForegroundListener();
    _setupNotificationOpenedListener();
    _handleTerminatedState();
  }

  // ─── Foreground ──────────────────────────────────────────────────────────

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      AppLogger.info(
          'FG Message: ${notification.title} | body: ${notification.body}');

      // Show a themed GetX snackbar while app is open
      Get.snackbar(
        notification.title ?? 'Om Events',
        notification.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        isDismissible: true,
      );
    });
  }

  // ─── Background Tap ──────────────────────────────────────────────────────

  void _setupNotificationOpenedListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info(
          'Notification tapped (background): ${message.notification?.title}');
      _handleNavigation(message.data);
    });
  }

  // ─── Terminated State ────────────────────────────────────────────────────

  void _handleTerminatedState() {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message == null) return;
      AppLogger.info(
          'Initial message (terminated): ${message.notification?.title}');
      // Delay navigation slightly so routing is ready
      Future.delayed(const Duration(milliseconds: 800), () {
        _handleNavigation(message.data);
      });
    }).catchError((e) {
      AppLogger.error('getInitialMessage error', e);
    });
  }

  // ─── Navigation Router ────────────────────────────────────────────────────

  void _handleNavigation(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    final url = data['url'] ?? '';

    if (!kIsWeb) {
      // On native, only navigate if Get routing is active
      if (!Get.isRegistered<dynamic>()) return;
    }

    if (type == 'booking' || url.contains('/dashboard')) {
      Get.toNamed(AppRoutes.customerDashboard);
    } else if (type == 'admin' || url.contains('/admin')) {
      Get.toNamed(AppRoutes.adminDashboard);
    } else if (url.isNotEmpty) {
      Get.toNamed(url);
    }
    // No navigation for unknown types — keeps app stable
  }
}
