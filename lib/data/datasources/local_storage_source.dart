import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/browser_tab_session.dart';
import '../../core/utils/app_logger.dart';

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

  // ── Canonical 2-Hour Customer Session Tracking ──────────────────────────────
  /// Stores the UTC timestamp of a successful customer authentication and its absolute 2-hour expiry.
  /// This session deadline is absolute and immutable across route navigation, page refreshes, and token refreshes.
  Future<bool> saveCustomerSessionStartedAt(DateTime timestamp) async {
    final utcTimestamp = timestamp.toUtc();
    final expiresAt = utcTimestamp.add(const Duration(hours: 2));

    // 1. Store in tab-scoped sessionStorage (survives reload in current tab, wiped on tab close)
    BrowserTabSession.saveCustomerSession(utcTimestamp, expiresAt);

    // 2. Store in SharedPreferences as fallback for current tab
    final prefs = _safePrefs;
    bool ok1 = false;
    bool ok2 = false;
    if (prefs != null) {
      ok1 = await prefs.setString(
        AppStrings.customerSessionStartedAtKey,
        utcTimestamp.toIso8601String(),
      );
      ok2 = await prefs.setString(
        AppStrings.customerSessionExpiresAtKey,
        expiresAt.toIso8601String(),
      );
    }
    AppLogger.info('[AUTH_SESSION] Session start timestamp: ${utcTimestamp.toIso8601String()}');
    AppLogger.info('[AUTH_SESSION] Session expiry timestamp: ${expiresAt.toIso8601String()}');
    return ok1 && ok2;
  }

  /// Retrieves the UTC timestamp when the customer session was initiated.
  DateTime? getCustomerSessionStartedAt() {
    // 1. Check tab-scoped sessionStorage first
    final tabRaw = BrowserTabSession.getCustomerSessionStartedAt();
    if (tabRaw != null && tabRaw.isNotEmpty) {
      return DateTime.tryParse(tabRaw)?.toUtc();
    }
    // 2. If tab is active, fallback to SharedPreferences
    if (BrowserTabSession.isCustomerTabActive()) {
      final raw = _safePrefs?.getString(AppStrings.customerSessionStartedAtKey);
      if (raw != null && raw.isNotEmpty) {
        return DateTime.tryParse(raw)?.toUtc();
      }
    }
    return null;
  }

  /// Retrieves the UTC timestamp when the customer session expires (exactly 2 hours after authentication).
  DateTime? getCustomerSessionExpiresAt() {
    // 1. Check tab-scoped sessionStorage first
    final tabRaw = BrowserTabSession.getCustomerSessionExpiresAt();
    if (tabRaw != null && tabRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(tabRaw)?.toUtc();
      if (parsed != null) return parsed;
    }
    // 2. If tab is active, fallback to SharedPreferences
    if (BrowserTabSession.isCustomerTabActive()) {
      final raw = _safePrefs?.getString(AppStrings.customerSessionExpiresAtKey);
      if (raw != null && raw.isNotEmpty) {
        final parsed = DateTime.tryParse(raw)?.toUtc();
        if (parsed != null) return parsed;
      }
    }
    // 3. Direct calculation fallback: calculate 2 hours from startedAt
    final startedAt = getCustomerSessionStartedAt();
    if (startedAt != null) {
      return startedAt.add(const Duration(hours: 2));
    }
    return null;
  }

  /// Clears customer session metadata upon explicit logout or 2-hour expiration.
  Future<bool> clearCustomerSession() async {
    BrowserTabSession.clearCustomerTab();
    final prefs = _safePrefs;
    if (prefs == null) return false;
    final r1 = await prefs.remove(AppStrings.customerSessionStartedAtKey);
    final r2 = await prefs.remove(AppStrings.customerSessionExpiresAtKey);
    return r1 && r2;
  }

  /// Determines if the customer session is expired, missing, or corrupted.
  /// Implements absolute 2-hour cutoff with client clock rollback detection and tab lifecycle validation.
  bool isCustomerSessionExpired() {
    // 1. Tab validation: if not active in this browser tab, session is expired
    if (!BrowserTabSession.isCustomerTabActive()) {
      AppLogger.info('[AUTH_SESSION] Expiry validation result: isExpired=true (new tab or tab was closed)');
      return true;
    }

    final startedAt = getCustomerSessionStartedAt();
    final expiresAt = getCustomerSessionExpiresAt();
    AppLogger.info('[AUTH_SESSION] Session start timestamp: $startedAt');
    AppLogger.info('[AUTH_SESSION] Session expiry timestamp: $expiresAt');

    if (startedAt == null || expiresAt == null) {
      AppLogger.info('[AUTH_SESSION] Expiry validation result: isExpired=true (missing session metadata)');
      return true;
    }

    final nowUtc = DateTime.now().toUtc();

    // 2. Clock tamper detection: if local clock was wound back before session start (allow 2 min grace)
    if (nowUtc.isBefore(startedAt.subtract(const Duration(minutes: 2)))) {
      AppLogger.info('[AUTH_SESSION] Expiry validation result: isExpired=true (clock rollback detected)');
      return true;
    }

    // 3. Absolute 2-hour cutoff
    if (nowUtc.isAfter(expiresAt) || nowUtc.isAtSameMomentAs(expiresAt)) {
      AppLogger.info('[AUTH_SESSION] Expiry validation result: isExpired=true (exceeded 2 hours deadline)');
      return true;
    }

    // 4. Redundant elapsed duration verification (allowing 2-minute client clock jitter)
    final elapsed = nowUtc.difference(startedAt);
    if (elapsed.inSeconds < -120 || elapsed >= const Duration(hours: 2)) {
      AppLogger.info('[AUTH_SESSION] Expiry validation result: isExpired=true (elapsed >= 2 hours or clock rollback)');
      return true;
    }

    AppLogger.info('[AUTH_SESSION] Expiry validation result: isExpired=false (valid session with ${expiresAt.difference(nowUtc).inMinutes}m remaining)');
    return false;
  }


  /// Returns remaining duration for the active customer session, or Duration.zero if expired.
  Duration getRemainingCustomerSessionDuration() {
    final expiresAt = getCustomerSessionExpiresAt();
    if (expiresAt == null) return Duration.zero;
    final nowUtc = DateTime.now().toUtc();
    final remaining = expiresAt.difference(nowUtc);
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
