import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';

class LocalStorageSource {
  final SharedPreferences _prefs;
  LocalStorageSource(this._prefs);

  // Cart Caching
  Future<bool> saveCart(String cartJson) async {
    return await _prefs.setString(AppStrings.cartCacheKey, cartJson);
  }

  String? getCart() {
    return _prefs.getString(AppStrings.cartCacheKey);
  }

  Future<bool> clearCart() async {
    return await _prefs.remove(AppStrings.cartCacheKey);
  }

  // Theme Caching
  Future<bool> saveTheme(String themeName) async {
    return await _prefs.setString(AppStrings.themeCacheKey, themeName);
  }

  String? getTheme() {
    return _prefs.getString(AppStrings.themeCacheKey);
  }

  // Admin Access Token Caching
  Future<bool> saveAdminToken(String token) async {
    return await _prefs.setString(AppStrings.adminTokenKey, token);
  }

  String? getAdminToken() {
    return _prefs.getString(AppStrings.adminTokenKey);
  }

  Future<bool> clearAdminToken() async {
    return await _prefs.remove(AppStrings.adminTokenKey);
  }

  // ── Canonical 24-Hour Admin Session Tracking ────────────────────────────────
  /// Stores the timestamp of a successful administrator login.
  /// This timestamp is immutable across route changes, page refreshes, and API calls.
  Future<bool> saveAdminSessionStartedAt(DateTime timestamp) async {
    return await _prefs.setString(
      AppStrings.adminSessionStartedAtKey,
      timestamp.toUtc().toIso8601String(),
    );
  }

  /// Retrieves the timestamp when the current admin session was initiated.
  DateTime? getAdminSessionStartedAt() {
    final raw = _prefs.getString(AppStrings.adminSessionStartedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// Clears the admin session timestamp upon explicit logout or expiration.
  Future<bool> clearAdminSessionStartedAt() async {
    return await _prefs.remove(AppStrings.adminSessionStartedAtKey);
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
    return await _prefs.setString(AppStrings.adminCachedRoleKey, role);
  }

  String? getAdminCachedRole() {
    return _prefs.getString(AppStrings.adminCachedRoleKey);
  }

  Future<bool> clearAdminCachedRole() async {
    return await _prefs.remove(AppStrings.adminCachedRoleKey);
  }
}
