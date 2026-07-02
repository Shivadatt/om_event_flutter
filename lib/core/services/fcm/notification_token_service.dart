import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_collections.dart';
import '../../utils/app_logger.dart';

/// Manages FCM token lifecycle:
///   - fetch from Firebase
///   - persist to Supabase (primary) + Firestore (fallback)
///   - remove on logout
///   - generate a stable device-id without extra packages
///
/// Supabase table: `notification_tokens`
/// Columns: id, user_id, role, platform, device_id, token, created_at, updated_at
/// Unique constraint: (user_id, device_id)
class NotificationTokenService extends GetxService {
  static NotificationTokenService get to =>
      Get.find<NotificationTokenService>();

  static const String _supabaseUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_bN91Or0DGzltjdDFB3b4zw_oosYJUa8';

  // VAPID key for Web Push
  static const String _webVapidKey =
      'BA8YCsOHz6N170MnJPPNybn3S2Bj_57d6rHY9NZJrAtbOI5acdkVa_GuRNUlzwHz3TUN3x_dLgYzeTpqxcf3k7k';

  static const String _deviceIdPrefKey = 'fcm_device_id';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Platform helpers ─────────────────────────────────────────────────────

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Returns a stable device-id persisted in SharedPreferences.
  /// Generates once on first call; reused on subsequent calls.
  Future<String> _getDeviceId() async {
    if (kIsWeb) return 'web-browser';
    try {
      final prefs = Get.find<SharedPreferences>();
      final existing = prefs.getString(_deviceIdPrefKey);
      if (existing != null && existing.isNotEmpty) return existing;

      // Generate a simple UUID-like ID from current time + platform
      final generated =
          '$_platform-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_deviceIdPrefKey, generated);
      return generated;
    } catch (_) {
      return '$_platform-device-fallback';
    }
  }

  // ─── Token Fetch ─────────────────────────────────────────────────────────

  /// Fetch an FCM registration token from Firebase.
  /// Returns `null` on failure — caller handles the null case gracefully.
  Future<String?> fetchToken() async {
    try {
      final String? token = kIsWeb
          ? await _messaging.getToken(vapidKey: _webVapidKey)
          : await _messaging.getToken();

      if (token == null || token.isEmpty) {
        AppLogger.warning('NotificationTokenService: getToken returned null');
        return null;
      }

      AppLogger.info('NotificationTokenService: token fetched');
      return token;
    } catch (e) {
      AppLogger.error('NotificationTokenService: fetchToken failed', e);
      return null;
    }
  }

  // ─── Persist ─────────────────────────────────────────────────────────────

  /// Upsert token to Supabase (primary) and Firestore (fallback).
  Future<void> persistToken({
    required String userId,
    required String role,
    required String token,
  }) async {
    if (userId.isEmpty || token.isEmpty) return;

    final deviceId = await _getDeviceId();

    await Future.wait([
      _saveToSupabase(
          userId: userId, role: role, token: token, deviceId: deviceId),
      _saveToFirestore(
          userId: userId, role: role, token: token, deviceId: deviceId),
    ]);
  }

  Future<void> _saveToSupabase({
    required String userId,
    required String role,
    required String token,
    required String deviceId,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'role': role,
        'device_id': deviceId,
        'platform': _platform,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse('$_supabaseUrl/rest/v1/notification_tokens'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': _supabaseAnonKey,
              'Authorization': 'Bearer $_supabaseAnonKey',
              'Prefer': 'resolution=merge-duplicates',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        AppLogger.success(
            'NotificationTokenService: Supabase token saved for user=$userId platform=$_platform');
      } else {
        AppLogger.warning(
            'NotificationTokenService: Supabase unexpected status=${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error(
          'NotificationTokenService: Supabase saveToken failed', e);
    }
  }

  Future<void> _saveToFirestore({
    required String userId,
    required String role,
    required String token,
    required String deviceId,
  }) async {
    try {
      await _firestore
          .collection(AppCollections.notificationTokens)
          .doc(userId)
          .set({
        'userId': userId,
        'deviceToken': token,
        'role': role,
        'platform': _platform,
        'deviceId': deviceId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      AppLogger.success(
          'NotificationTokenService: Firestore token saved for user=$userId');
    } catch (e) {
      AppLogger.error(
          'NotificationTokenService: Firestore saveToken failed', e);
    }
  }

  // ─── Remove ──────────────────────────────────────────────────────────────

  /// Remove token from both stores on logout.
  Future<void> removeToken({required String userId}) async {
    if (userId.isEmpty) return;

    final deviceId = await _getDeviceId();

    await Future.wait([
      _removeFromSupabase(userId: userId, deviceId: deviceId),
      _removeFromFirestore(userId: userId),
    ]);
  }

  Future<void> _removeFromSupabase({
    required String userId,
    required String deviceId,
  }) async {
    try {
      await http.delete(
        Uri.parse(
            '$_supabaseUrl/rest/v1/notification_tokens?user_id=eq.$userId&device_id=eq.$deviceId'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      ).timeout(const Duration(seconds: 10));
      AppLogger.success(
          'NotificationTokenService: Supabase token removed for user=$userId');
    } catch (e) {
      AppLogger.error(
          'NotificationTokenService: Supabase removeToken failed', e);
    }
  }

  Future<void> _removeFromFirestore({required String userId}) async {
    try {
      await _firestore
          .collection(AppCollections.notificationTokens)
          .doc(userId)
          .delete();
      AppLogger.success(
          'NotificationTokenService: Firestore token removed for user=$userId');
    } catch (_) {
      // Non-fatal
    }
  }
}
