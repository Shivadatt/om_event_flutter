import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/utils/app_logger.dart';
import 'token_service.dart';

/// Manages FCM permission requests, token lifecycle, and refresh.
/// Delegates:
///   - Token persistence → [TokenService] (Supabase)
///   - Firestore fallback → notification_tokens collection
///   - Message routing   → [NotificationHandlerService]
class FcmNotificationService extends GetxService {
  static FcmNotificationService get to => Get.find<FcmNotificationService>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reactive current FCM token for the active device.
  final rxToken = ''.obs;

  // VAPID key for Web Push — configured in Firebase Console → Cloud Messaging
  static const String _webVapidKey =
      'BA8YCsOHz6N170MnJPPNybn3S2Bj_57d6rHY9NZJrAtbOI5acdkVa_GuRNUlzwHz3TUN3x_dLgYzeTpqxcf3k7k';

  // ─── Permission ──────────────────────────────────────────────────────────

  /// Request push-notification permission.
  /// Returns true if granted or provisional; false if denied.
  Future<bool> requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final status = settings.authorizationStatus;
      switch (status) {
        case AuthorizationStatus.authorized:
          AppLogger.success('FCM: Permission granted');
          return true;
        case AuthorizationStatus.provisional:
          AppLogger.info('FCM: Provisional permission granted');
          return true;
        case AuthorizationStatus.denied:
          AppLogger.warning('FCM: Permission denied by user');
          return false;
        case AuthorizationStatus.notDetermined:
          AppLogger.warning('FCM: Permission not yet determined');
          return false;
      }
    } catch (e) {
      AppLogger.error('FCM: requestPermission failed', e);
      return false;
    }
  }

  // ─── Token ───────────────────────────────────────────────────────────────

  /// Full FCM init for a signed-in user.
  /// - Requests permission (shows browser dialog if not yet decided)
  /// - Fetches token and saves to Supabase + Firestore
  /// - Listens for automatic token refresh
  Future<void> initializeUserFcm(String userId, {String role = 'customer'}) async {
    if (userId.isEmpty) return;

    final granted = await requestPermissions();
    if (!granted) {
      AppLogger.warning('FCM: Skipping token fetch — permission not granted');
      return;
    }

    await _fetchAndPersistToken(userId, role);

    // Auto-refresh: update storage whenever the token rotates
    _fcm.onTokenRefresh.listen((newToken) async {
      AppLogger.info('FCM: Token refreshed for user=$userId');
      rxToken.value = newToken;
      await _persistToken(userId, role, newToken);
    });
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  Future<void> _fetchAndPersistToken(String userId, String role) async {
    try {
      String? token;
      if (kIsWeb) {
        token = await _fcm.getToken(vapidKey: _webVapidKey);
      } else {
        token = await _fcm.getToken();
      }

      if (token == null || token.isEmpty) {
        AppLogger.warning('FCM: getToken returned null');
        return;
      }

      rxToken.value = token;
      AppLogger.info('FCM: Token obtained for user=$userId');
      await _persistToken(userId, role, token);
    } catch (e) {
      AppLogger.error('FCM: getToken failed', e);
    }
  }

  /// Saves token to both Supabase (primary) and Firestore (fallback).
  Future<void> _persistToken(String userId, String role, String token) async {
    // 1. Supabase notification_tokens (per-device upsert, no duplicates)
    try {
      if (Get.isRegistered<TokenService>()) {
        await TokenService.to.saveToken(
          userId: userId,
          role: role,
          token: token,
        );
      }
    } catch (e) {
      AppLogger.error('FCM: Supabase token save failed', e);
    }

    // 2. Firestore notification_tokens (backwards-compatible fallback)
    try {
      await _firestore
          .collection(AppCollections.notificationTokens)
          .doc(userId)
          .set({
        'userId': userId,
        'deviceToken': token,
        'role': role,
        'platform': kIsWeb ? 'web' : 'mobile',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('FCM: Firestore token save failed', e);
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────

  /// Clears the FCM token from Supabase, Firestore and local state on logout.
  Future<void> removeToken(String userId) async {
    if (userId.isEmpty) return;

    try {
      if (Get.isRegistered<TokenService>()) {
        await TokenService.to.removeToken(userId: userId);
      }
    } catch (e) {
      AppLogger.error('FCM: Supabase token removal failed', e);
    }

    try {
      await _firestore
          .collection(AppCollections.notificationTokens)
          .doc(userId)
          .delete();
    } catch (_) {
      // Non-fatal
    }

    rxToken.value = '';
    AppLogger.info('FCM: token cleared for user=$userId');
  }
}
