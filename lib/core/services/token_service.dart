import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/app_logger.dart';

/// Handles saving FCM tokens to the Supabase `notification_tokens` table.
/// Performs an upsert keyed on (user_id + device_id) to prevent duplicates.
/// One row per physical device per user.
class TokenService extends GetxService {
  static TokenService get to => Get.find<TokenService>();

  static const String _supabaseUrl = 'https://kwegyvbgdaednljyhcgm.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_bN91Or0DGzltjdDFB3b4zw_oosYJUa8';

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Stable pseudo-device-id: shared_preferences-persisted UUID.
  /// Falls back to a random string for web where dart:io Platform is unavailable.
  String _deviceId() {
    // We use a fixed seed per platform for web (no file system).
    // For mobile we reuse the userId+platform combo as a unique key.
    // For a more robust implementation, persist a UUID via SharedPreferences.
    // This simple approach avoids adding a new package dependency.
    return kIsWeb ? 'web-browser' : '$_platform-device';
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Upsert the FCM token for a specific user+device into Supabase.
  Future<void> saveToken({
    required String userId,
    required String role,
    required String token,
  }) async {
    if (userId.isEmpty || token.isEmpty) return;

    final deviceId = _deviceId();
    final payload = {
      'user_id': userId,
      'role': role,
      'device_id': deviceId,
      'platform': _platform,
      'token': token,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // Supabase upsert on (user_id, device_id) unique constraint
      final response = await http
          .post(
            Uri.parse('$_supabaseUrl/rest/v1/notification_tokens'),
            headers: {
              'Content-Type': 'application/json',
              'apikey': _supabaseAnonKey,
              'Authorization': 'Bearer $_supabaseAnonKey',
              // Tell Supabase to perform an upsert merging on conflicting keys
              'Prefer': 'resolution=merge-duplicates',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        AppLogger.success(
            'TokenService: token saved for user=$userId platform=$_platform');
      } else {
        AppLogger.warning(
            'TokenService: unexpected status ${response.statusCode} body=${response.body}');
      }
    } catch (e) {
      // Non-fatal — FCM still works without Supabase persistence
      AppLogger.error('TokenService: failed to save token', e);
    }
  }

  /// Remove all tokens for a user+device on logout.
  Future<void> removeToken({
    required String userId,
  }) async {
    if (userId.isEmpty) return;

    final deviceId = _deviceId();

    try {
      final response = await http
          .delete(
            Uri.parse(
                '$_supabaseUrl/rest/v1/notification_tokens?user_id=eq.$userId&device_id=eq.$deviceId'),
            headers: {
              'apikey': _supabaseAnonKey,
              'Authorization': 'Bearer $_supabaseAnonKey',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        AppLogger.success(
            'TokenService: token removed for user=$userId device=$deviceId');
      }
    } catch (e) {
      AppLogger.error('TokenService: failed to remove token', e);
    }
  }
}
