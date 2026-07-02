import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../utils/app_logger.dart';
import 'notification_router.dart';

/// Displays local notifications while the app is in the foreground.
///
/// Uses `flutter_local_notifications` to show a native notification
/// overlay with title, body, optional image, and an action payload
/// that is routed via [NotificationRouter] on tap.
///
/// Web: `flutter_local_notifications` is not supported on web;
/// foreground messages are shown as GetX snackbars instead.
class NotificationLocalService extends GetxService {
  static NotificationLocalService get to =>
      Get.find<NotificationLocalService>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'om_events_default';
  static const String _channelName = 'Om Events Notifications';
  static const String _channelDescription =
      'Booking, payment, and event updates from Om Events.';

  // Unique notification ID seed — cycles 0-9999
  int _notifId = 0;

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) {
      _initializePlugin();
    }
  }

  // ─── Initialization ──────────────────────────────────────────────────────

  Future<void> _initializePlugin() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // handled by NotificationPermissionService
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel (required for Android 8+)
    await _createAndroidChannel();

    AppLogger.success('NotificationLocalService: initialized');
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    AppLogger.info('NotificationLocalService: Android channel created');
  }

  // ─── Show Notification ───────────────────────────────────────────────────

  /// Display a foreground notification overlay.
  ///
  /// On Web: shows a GetX snackbar fallback (local_notifications not supported).
  /// On Android/iOS: shows a native push-style overlay.
  void show({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic> payload = const {},
  }) {
    if (kIsWeb) {
      // Web fallback: styled GetX snackbar
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        isDismissible: true,
      );
      return;
    }

    _showNative(title: title, body: body, imageUrl: imageUrl, payload: payload);
  }

  Future<void> _showNative({
    required String title,
    required String body,
    String? imageUrl,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final id = _notifId++ % 9999;

      // Build big picture style if image URL provided, otherwise big text
      AndroidNotificationDetails androidDetails;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final bigPicture = BigPictureStyleInformation(
          DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          contentTitle: title,
          summaryText: body,
        );
        androidDetails = AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigPicture,
        );
      } else {
        androidDetails = const AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        );
      }

      final notifDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.show(
        id,
        title,
        body,
        notifDetails,
        payload: _encodePayload(payload),
      );
    } catch (e) {
      AppLogger.error('NotificationLocalService: show failed', e);
    }
  }

  // ─── Tap Handler ─────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final rawPayload = response.payload;
    if (rawPayload == null || rawPayload.isEmpty) return;

    AppLogger.info('NotificationLocalService: tap payload=$rawPayload');

    // Parse encoded payload and route
    final data = _decodePayload(rawPayload);
    NotificationRouter.navigate(data);
  }

  // ─── Payload helpers ─────────────────────────────────────────────────────

  String _encodePayload(Map<String, dynamic> data) {
    if (data.isEmpty) return '';
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, dynamic> _decodePayload(String raw) {
    try {
      final map = <String, dynamic>{};
      for (final part in raw.split('&')) {
        final idx = part.indexOf('=');
        if (idx > 0) {
          map[part.substring(0, idx)] = part.substring(idx + 1);
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }
}
