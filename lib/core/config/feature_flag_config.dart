import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

/// Manages feature flags for the backend migration.
/// Allows dynamic switching between Firebase/Firestore and Supabase engines at runtime.
class FeatureFlagConfig {
  FeatureFlagConfig._();

  static const String _useSupabaseKey = 'use_supabase_backend';

  /// Returns true if the app should use the Supabase backend engine.
  /// If not set or SharedPreferences is unavailable, defaults to false (Firestore).
  static bool get useSupabase {
    try {
      final prefs = Get.find<SharedPreferences>();
      return prefs.getBool(_useSupabaseKey) ?? false;
    } catch (_) {
      return false; // Fallback to Firestore legacy
    }
  }

  /// Sets the backend toggle state.
  static Future<void> setUseSupabase(bool value) async {
    try {
      final prefs = Get.find<SharedPreferences>();
      await prefs.setBool(_useSupabaseKey, value);
    } catch (_) {}
  }
}
