import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';

class LocalStorageSource {
  SharedPreferences? _prefs;
  LocalStorageSource([this._prefs]);

  SharedPreferences? get _safePrefs {
    if (_prefs != null) return _prefs;
    if (Get.isRegistered<SharedPreferences>()) {
      _prefs = Get.find<SharedPreferences>();
    }
    return _prefs;
  }

  // Cart Caching
  Future<bool> saveCart(String cartJson) async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.setString(AppStrings.cartCacheKey, cartJson);
  }

  String? getCart() {
    return _safePrefs?.getString(AppStrings.cartCacheKey);
  }

  Future<bool> clearCart() async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.remove(AppStrings.cartCacheKey);
  }

  // Theme Caching
  Future<bool> saveTheme(String themeName) async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.setString(AppStrings.themeCacheKey, themeName);
  }

  String? getTheme() {
    return _safePrefs?.getString(AppStrings.themeCacheKey);
  }

  // Admin Access Token Caching
  Future<bool> saveAdminToken(String token) async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.setString(AppStrings.adminTokenKey, token);
  }

  String? getAdminToken() {
    return _safePrefs?.getString(AppStrings.adminTokenKey);
  }

  Future<bool> clearAdminToken() async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.remove(AppStrings.adminTokenKey);
  }

  // ── Canonical 24-Hour Admin Session Tracking ────────────────────────────────
  /// Stores the timestamp of a successful administrator login.
  /// This timestamp is immutable across route changes, page refreshes, and API calls.
  Future<bool> saveAdminSessionStartedAt(DateTime timestamp) async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.setString(
      AppStrings.adminSessionStartedAtKey,
      timestamp.toUtc().toIso8601String(),
    );
  }

  /// Retrieves the timestamp when the current admin session was initiated.
  DateTime? getAdminSessionStartedAt() {
    final raw = _safePrefs?.getString(AppStrings.adminSessionStartedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// Clears the admin session timestamp upon explicit logout or expiration.
  Future<bool> clearAdminSessionStartedAt() async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.remove(AppStrings.adminSessionStartedAtKey);
  }

  /// Determines if the current admin session has exceeded the 24-hour lifetime.
  bool isSessionExpired() {
    final startedAt = getAdminSessionStartedAt();
    if (startedAt == null) return true;
    final now = DateTime.now();
    return now.difference(startedAt) >= const Duration(hours: 24);
  }

  // ── Admin Role Caching (Instant authorization on browser reload) ─────────────
  Future<bool> saveAdminCachedRole(String role) async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.setString(AppStrings.adminCachedRoleKey, role);
  }

  String? getAdminCachedRole() {
    return _safePrefs?.getString(AppStrings.adminCachedRoleKey);
  }

  Future<bool> clearAdminCachedRole() async {
    final prefs = _safePrefs;
    if (prefs == null) return false;
    return await prefs.remove(AppStrings.adminCachedRoleKey);
  }
}
