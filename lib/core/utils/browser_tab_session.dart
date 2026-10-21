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

  /// Whether the customer session is marked as active in the current browser tab's sessionStorage.
  static bool isCustomerTabActive() {
    return impl.isTabSessionActiveImpl(customerTabKey);
  }

  /// Marks the current browser tab as having an active customer session.
  static void markCustomerTabActive() {
    impl.setTabSessionActiveImpl(customerTabKey);
  }

  /// Clears the tab session marker upon logout or 2-hour expiration.
  static void clearCustomerTab() {
    impl.clearTabSessionImpl(customerTabKey);
  }
}
