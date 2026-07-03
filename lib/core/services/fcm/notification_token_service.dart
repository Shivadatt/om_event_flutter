import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_collections.dart';

/// Manages FCM token lifecycle:
///   - fetch from Firebase
///   - persist to Supabase (primary Edge Function) + Firestore (fallback)
///   - remove on logout
///   - generate a stable device-id without extra packages
///
/// Supabase Edge Function: `register-token`
class NotificationTokenService extends GetxService {
  static NotificationTokenService get to =>
      Get.find<NotificationTokenService>();

  static const String _supabaseUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co';

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
    print("INFO: Fetching FCM token...");
    try {
      final String? token = kIsWeb
          ? await _messaging.getToken(vapidKey: _webVapidKey)
          : await _messaging.getToken();

      if (token == null || token.isEmpty) {
        print("WARNING: NotificationTokenService: getToken returned null");
        return null;
      }

      print("SUCCESS: NotificationTokenService: token fetched: $token");
      return token;
    } catch (e) {
      print("ERROR: NotificationTokenService: fetchToken failed: $e");
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("WARNING: NotificationTokenService: No current Firebase user. Skipping Supabase save.");
        return;
      }
      final idToken = await currentUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        print("WARNING: NotificationTokenService: Failed to retrieve Firebase ID Token. Skipping Supabase save.");
        return;
      }

      final payload = {
        'action': 'upsert',
        'token': token,
        'device_id': deviceId,
        'platform': _platform,
        'role': role,
      };

      final url = '$_supabaseUrl/functions/v1/register-token';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      print("INFO: Saving token to Supabase Edge Function...");
      print("DEBUG HTTP Request URL: $url");
      print("DEBUG HTTP Request Headers: ${jsonEncode(headers)}");
      print("DEBUG HTTP Request Payload: ${jsonEncode(payload)}");

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      print("DEBUG HTTP Response Status: ${response.statusCode}");
      print("DEBUG HTTP Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        print("SUCCESS: NotificationTokenService: Supabase Edge Function saved token for user=$userId");
      } else {
        print("WARNING: NotificationTokenService: Supabase Edge Function unexpected status=${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("ERROR: NotificationTokenService: Supabase Edge Function saveToken failed: $e");
      print("DEBUG HTTP Error Stack: $stackTrace");
    }
  }

  Future<void> _saveToFirestore({
    required String userId,
    required String role,
    required String token,
    required String deviceId,
  }) async {
    print("INFO: Saving token to Firestore...");
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
      print("SUCCESS: NotificationTokenService: Firestore token saved for user=$userId");
    } catch (e) {
      print("ERROR: NotificationTokenService: Firestore saveToken failed: $e");
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("WARNING: NotificationTokenService: No current Firebase user. Skipping Supabase removal.");
        return;
      }
      final idToken = await currentUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        print("WARNING: NotificationTokenService: Failed to retrieve Firebase ID Token. Skipping Supabase removal.");
        return;
      }

      final payload = {
        'action': 'delete',
        'device_id': deviceId,
      };

      final url = '$_supabaseUrl/functions/v1/register-token';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      print("INFO: Removing token from Supabase Edge Function...");
      print("DEBUG HTTP Request URL: $url");
      print("DEBUG HTTP Request Headers: ${jsonEncode(headers)}");
      print("DEBUG HTTP Request Payload: ${jsonEncode(payload)}");

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      print("DEBUG HTTP Response Status: ${response.statusCode}");
      print("DEBUG HTTP Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("SUCCESS: NotificationTokenService: Supabase Edge Function token removed for user=$userId");
      } else {
        print("WARNING: NotificationTokenService: Supabase Edge Function unexpected status=${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("ERROR: NotificationTokenService: Supabase Edge Function removeToken failed: $e");
      print("DEBUG HTTP Error Stack: $stackTrace");
    }
  }

  Future<void> _removeFromFirestore({required String userId}) async {
    print("INFO: Removing token from Firestore...");
    try {
      await _firestore
          .collection(AppCollections.notificationTokens)
          .doc(userId)
          .delete();
      print("SUCCESS: NotificationTokenService: Firestore token removed for user=$userId");
    } catch (e) {
      print("ERROR: NotificationTokenService: Firestore removeToken failed: $e");
    }
  }
}
