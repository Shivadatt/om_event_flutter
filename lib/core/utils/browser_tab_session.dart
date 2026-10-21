import 'browser_tab_session_stub.dart'
    if (dart.library.html) 'browser_tab_session_web.dart' as impl;

/// Helper managing tab-scoped lifecycle persistence for web browser tabs.
///
/// Ensures:
/// - Active customer sessions survive browser reloads (F5) and dev server restarts within the SAME tab.
/// - When a tab is closed, browser `sessionStorage` is automatically wiped by the browser engine.
class BrowserTabSession {
  BrowserTabSession._();

  static const String customerTabKey = 'oe-customer-tab-active';
  static const String customerSessionStartedKey = 'oe-customer-session-started-at';
  static const String customerSessionExpiresKey = 'oe-customer-session-expires-at';

  /// Whether the customer session is marked as active in the current browser tab's sessionStorage.
  static bool isCustomerTabActive() {
    return impl.isTabSessionActiveImpl(customerTabKey);
  }

  /// Marks the current browser tab as having an active customer session.
  static void markCustomerTabActive() {
    impl.setTabSessionActiveImpl(customerTabKey);
  }

  /// Retrieves the tab-scoped session start timestamp string (ISO-8601 UTC).
  static String? getCustomerSessionStartedAt() {
    return impl.getTabSessionStringImpl(customerSessionStartedKey);
  }

  /// Retrieves the tab-scoped session expiry timestamp string (ISO-8601 UTC).
  static String? getCustomerSessionExpiresAt() {
    return impl.getTabSessionStringImpl(customerSessionExpiresKey);
  }

  /// Stores the immutable session start and 2-hour expiry timestamps into tab-scoped sessionStorage.
  static void saveCustomerSession(DateTime startedAt, DateTime expiresAt) {
    impl.setTabSessionStringImpl(
      customerSessionStartedKey,
      startedAt.toUtc().toIso8601String(),
    );
    impl.setTabSessionStringImpl(
      customerSessionExpiresKey,
      expiresAt.toUtc().toIso8601String(),
    );
    impl.setTabSessionActiveImpl(customerTabKey);
  }

  /// Clears the tab session marker and timestamps upon logout or 2-hour expiration.
  static void clearCustomerTab() {
    impl.clearTabSessionImpl(customerTabKey);
    impl.clearTabSessionImpl(customerSessionStartedKey);
    impl.clearTabSessionImpl(customerSessionExpiresKey);
  }
}

