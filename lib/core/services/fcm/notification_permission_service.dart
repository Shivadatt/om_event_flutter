import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../utils/app_logger.dart';

/// Handles FCM permission negotiation across all platforms.
///
/// Supports:
///   - Web (browser permission dialog)
///   - Android 13+ (POST_NOTIFICATIONS runtime permission)
///   - iOS (UNUserNotificationCenter)
///
/// All four [AuthorizationStatus] states are handled explicitly:
///   authorized   → permission granted
///   provisional  → iOS silent notifications granted (still usable)
///   denied       → user declined — no token will be requested
///   notDetermined → first-launch state, will show dialog next run
class NotificationPermissionService extends GetxService {
  static NotificationPermissionService get to =>
      Get.find<NotificationPermissionService>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Reactive permission state.
  final rxStatus = AuthorizationStatus.notDetermined.obs;

  /// Request push-notification permission.
  ///
  /// Returns `true` if [AuthorizationStatus.authorized] or
  /// [AuthorizationStatus.provisional] — token fetch may proceed.
  /// Returns `false` otherwise — no token fetch attempted.
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false, // set to true for iOS silent provisional
        sound: true,
      );

      rxStatus.value = settings.authorizationStatus;

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          AppLogger.success(
              'NotificationPermissionService: permission AUTHORIZED');
          return true;

        case AuthorizationStatus.provisional:
          AppLogger.info(
              'NotificationPermissionService: permission PROVISIONAL (iOS)');
          return true;

        case AuthorizationStatus.denied:
          AppLogger.warning(
              'NotificationPermissionService: permission DENIED by user');
          return false;

        case AuthorizationStatus.notDetermined:
          AppLogger.warning(
              'NotificationPermissionService: permission NOT DETERMINED — dialog not shown yet');
          return false;
      }
    } catch (e) {
      AppLogger.error(
          'NotificationPermissionService: requestPermission failed', e);
      return false;
    }
  }

  /// Check current permission status without prompting.
  Future<AuthorizationStatus> checkStatus() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      rxStatus.value = settings.authorizationStatus;
      return settings.authorizationStatus;
    } catch (e) {
      AppLogger.error(
          'NotificationPermissionService: checkStatus failed', e);
      return AuthorizationStatus.notDetermined;
    }
  }
}
