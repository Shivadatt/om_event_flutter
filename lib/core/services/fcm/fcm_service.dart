import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../utils/app_logger.dart';
import 'notification_permission_service.dart';
import 'notification_token_service.dart';
import 'notification_handler.dart';
import 'notification_local_service.dart';

/// Top-level FCM entry-point service.
///
/// Responsibilities:
///   - Orchestrate permission → token → handler initialization pipeline
///   - Provide a single public API for auth controllers (admin + customer)
///   - Delegate each concern to the appropriate focused sub-service
///
/// Call [initialize] once after a user logs in.
/// Call [cleanup] on logout.
class FcmService extends GetxService {
  static FcmService get to => Get.find<FcmService>();

  // ─── Public reactive state ────────────────────────────────────────────────

  /// Current device FCM token. Empty string when not yet obtained.
  final rxToken = ''.obs;

  /// Whether push notifications are currently enabled for this device.
  final rxPermissionGranted = false.obs;

  // ─── Internal sub-services ────────────────────────────────────────────────

  late final NotificationPermissionService _permissionService;
  late final NotificationTokenService _tokenService;
  late final NotificationHandler _handler;
  late final NotificationLocalService _localService;

  @override
  void onInit() {
    super.onInit();
    _permissionService = Get.find<NotificationPermissionService>();
    _tokenService = Get.find<NotificationTokenService>();
    _handler = Get.find<NotificationHandler>();
    _localService = Get.find<NotificationLocalService>();

    // Register the global background message handler immediately.
    // Must be called before any messaging stream subscriptions.
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    AppLogger.info('FcmService: initialized');
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Full FCM initialization flow for a signed-in user.
  ///
  /// Steps:
  ///   1. Request permission
  ///   2. Fetch and save token
  ///   3. Listen to token refresh
  ///   4. Start foreground + tap listeners
  Future<void> initialize({
    required String userId,
    required String role,
  }) async {
    if (userId.isEmpty) return;

    AppLogger.info('FcmService: starting init for user=$userId role=$role');

    // 1. Permission
    final granted = await _permissionService.requestPermission();
    rxPermissionGranted.value = granted;

    if (!granted) {
      AppLogger.warning('FcmService: permission denied — skipping token fetch');
      return;
    }

    // 2. Token
    final token = await _tokenService.fetchToken();
    if (token != null && token.isNotEmpty) {
      rxToken.value = token;
      await _tokenService.persistToken(
        userId: userId,
        role: role,
        token: token,
      );
    }

    // 3. Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      AppLogger.info('FcmService: token refreshed for user=$userId');
      rxToken.value = newToken;
      await _tokenService.persistToken(
        userId: userId,
        role: role,
        token: newToken,
      );
    });

    // 4. Notification listeners (foreground + taps + terminated)
    _handler.startListening(_localService);

    AppLogger.success('FcmService: fully initialized for user=$userId');
  }

  /// Remove this device's token on logout.
  Future<void> cleanup(String userId) async {
    if (userId.isEmpty) return;
    await _tokenService.removeToken(userId: userId);
    rxToken.value = '';
    rxPermissionGranted.value = false;
    AppLogger.info('FcmService: cleanup done for user=$userId');
  }
}

// ─── Background handler (top-level, isolate-safe) ──────────────────────────

/// Must be a top-level function — Firebase requires this for background isolates.
/// Firebase is already initialized at this point; do NOT call initializeApp here.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Web does not run this handler (service worker handles it instead).
  if (kIsWeb) return;
  AppLogger.info(
      'FcmService BG: ${message.notification?.title} | data: ${message.data}');
}
