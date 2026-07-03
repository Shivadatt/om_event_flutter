import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'notification_local_service.dart';
import 'notification_router.dart';

/// Coordinates all FCM message event listeners:
///   - Foreground   → [FirebaseMessaging.onMessage]
///   - Background tap → [FirebaseMessaging.onMessageOpenedApp]
///   - Terminated state → [FirebaseMessaging.instance.getInitialMessage]
///
/// Foreground messages are displayed via [NotificationLocalService].
/// All notification taps are routed via [NotificationRouter].
class NotificationHandler extends GetxService {
  static NotificationHandler get to => Get.find<NotificationHandler>();

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Activate all three message listeners.
  /// Must be called after the user logs in so routing context is available.
  void startListening(NotificationLocalService localService) {
    _listenForeground(localService);
    _listenBackgroundTap();
    _handleTerminatedState();
  }

  // ─── Foreground ──────────────────────────────────────────────────────────

  void _listenForeground(NotificationLocalService localService) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      print("INFO: NotificationHandler FG message received: title=${notification.title} | body=${notification.body} | data=${message.data}");

      // Show using flutter_local_notifications overlay
      localService.show(
        title: notification.title ?? 'Om Events',
        body: notification.body ?? '',
        imageUrl: notification.android?.imageUrl ??
            notification.apple?.imageUrl,
        payload: message.data,
      );
    });
  }

  // ─── Background Tap ──────────────────────────────────────────────────────

  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("INFO: NotificationHandler tapped in background: title=${message.notification?.title} | data=${message.data}");
      NotificationRouter.navigate(message.data);
    });
  }

  // ─── Terminated State ────────────────────────────────────────────────────

  void _handleTerminatedState() {
    FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) {
        if (message == null) return;
        print("INFO: NotificationHandler terminated tap: title=${message.notification?.title} | data=${message.data}");
        // Delay slightly so GetX routing stack is ready
        Future.delayed(
          const Duration(milliseconds: 800),
          () => NotificationRouter.navigate(message.data),
        );
      }).catchError((Object e) {
        print("ERROR: NotificationHandler: getInitialMessage error: $e");
      });
  }
}
