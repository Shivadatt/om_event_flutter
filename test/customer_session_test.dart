import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:om_event/data/datasources/local_storage_source.dart';
import 'package:om_event/core/constants/app_strings.dart';

import 'package:om_event/core/utils/browser_tab_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageSource localStorageSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorageSource = LocalStorageSource(prefs);
    BrowserTabSession.clearCustomerTab();
  });


  group('Customer 2-Hour Session Policy & Persistence Tests', () {
    test('1. Newly started session stores start timestamp and exact 2-hour expiry', () async {
      final now = DateTime.now().toUtc();
      final saved = await localStorageSource.saveCustomerSessionStartedAt(now);
      expect(saved, isTrue);

      final startedAt = localStorageSource.getCustomerSessionStartedAt();
      final expiresAt = localStorageSource.getCustomerSessionExpiresAt();

      expect(startedAt, isNotNull);
      expect(expiresAt, isNotNull);

      // Verify that expiry is exactly 2 hours after start
      final difference = expiresAt!.difference(startedAt!);
      expect(difference.inMinutes, equals(120));
      expect(difference.inHours, equals(2));
    });

    test('2. Valid session within 2 hours is active (not expired)', () async {
      final loginTime = DateTime.now().toUtc().subtract(const Duration(minutes: 45));
      await localStorageSource.saveCustomerSessionStartedAt(loginTime);

      expect(localStorageSource.isCustomerSessionExpired(), isFalse);
      final remaining = localStorageSource.getRemainingCustomerSessionDuration();
      expect(remaining.inMinutes, greaterThan(70));
      expect(remaining.inMinutes, lessThanOrEqualTo(75));
    });

    test('3. Session expires when 2 hours have elapsed', () async {
      // 2 hours and 1 minute ago
      final pastLogin = DateTime.now().toUtc().subtract(const Duration(hours: 2, minutes: 1));
      await localStorageSource.saveCustomerSessionStartedAt(pastLogin);

      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
      expect(localStorageSource.getRemainingCustomerSessionDuration(), equals(Duration.zero));
    });

    test('4. Manually setting the stored expiry timestamp to the past triggers expiration', () async {
      final pastExpiry = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppStrings.customerSessionExpiresAtKey,
        pastExpiry.toIso8601String(),
      );
      await prefs.setString(
        AppStrings.customerSessionStartedAtKey,
        pastExpiry.subtract(const Duration(hours: 2)).toIso8601String(),
      );

      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
    });

    test('5. Missing session timestamp returns expired true (safe fallback)', () async {
      await localStorageSource.clearCustomerSession();
      expect(localStorageSource.getCustomerSessionStartedAt(), isNull);
      expect(localStorageSource.getCustomerSessionExpiresAt(), isNull);
      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
    });

    test('6. Clock tamper detection: winding client clock backward before session start triggers expiry', () async {
      // Session says started 10 minutes from now (clock wound back)
      final futureStart = DateTime.now().toUtc().add(const Duration(minutes: 10));
      await localStorageSource.saveCustomerSessionStartedAt(futureStart);

      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
    });

    test('7. Explicit logout / cleanup clears all session timestamps', () async {
      final now = DateTime.now().toUtc();
      await localStorageSource.saveCustomerSessionStartedAt(now);
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);

      final cleared = await localStorageSource.clearCustomerSession();
      expect(cleared, isTrue);

      expect(localStorageSource.getCustomerSessionStartedAt(), isNull);
      expect(localStorageSource.getCustomerSessionExpiresAt(), isNull);
      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
    });

    test('8. Repeated checks, page reloads, and navigation do not advance the deadline', () async {
      final originalLogin = DateTime.now().toUtc().subtract(const Duration(minutes: 30));
      await localStorageSource.saveCustomerSessionStartedAt(originalLogin);

      final initialExpiry = localStorageSource.getCustomerSessionExpiresAt();
      expect(initialExpiry, isNotNull);

      // Simulate route navigation and multiple page reads
      for (int i = 0; i < 5; i++) {
        final currentExpiry = localStorageSource.getCustomerSessionExpiresAt();
        expect(currentExpiry, equals(initialExpiry));
        expect(localStorageSource.isCustomerSessionExpired(), isFalse);
      }

      // Initial expiry remains fixed at exactly 2 hours after originalLogin
      expect(
        initialExpiry!.difference(originalLogin).inMinutes,
        equals(120),
      );
    });

    test('9. Small clock jitter (within 2-minute grace period) does not trigger false expiration', () async {
      // Session starts 1 minute in the future due to minor NTP jitter
      final slightFutureStart = DateTime.now().toUtc().add(const Duration(minutes: 1));
      await localStorageSource.saveCustomerSessionStartedAt(slightFutureStart);

      // Should remain valid within the 2-minute grace period
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);
    });

    test('10. If expiresAt key is missing, calculates fallback 2 hours from startedAt', () async {
      BrowserTabSession.markCustomerTabActive();
      final loginTime = DateTime.now().toUtc().subtract(const Duration(minutes: 30));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppStrings.customerSessionStartedAtKey,
        loginTime.toIso8601String(),
      );
      await prefs.remove(AppStrings.customerSessionExpiresAtKey);

      final fallbackExpiry = localStorageSource.getCustomerSessionExpiresAt();
      expect(fallbackExpiry, isNotNull);
      expect(fallbackExpiry!.difference(loginTime).inHours, equals(2));
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);
    });

    test('11. Corrupted ISO-8601 strings safely return expired without crashing', () async {
      BrowserTabSession.markCustomerTabActive();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppStrings.customerSessionStartedAtKey,
        'not-a-valid-date-string',
      );
      await prefs.setString(
        AppStrings.customerSessionExpiresAtKey,
        'totally-invalid',
      );

      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
      expect(localStorageSource.getRemainingCustomerSessionDuration(), equals(Duration.zero));
    });

    test('12. Simulated future expiry timestamp restores session with correct remaining duration', () async {
      final now = DateTime.now().toUtc();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      await localStorageSource.saveCustomerSessionStartedAt(oneHourAgo);

      expect(localStorageSource.isCustomerSessionExpired(), isFalse);
      final remaining = localStorageSource.getRemainingCustomerSessionDuration();
      expect(remaining.inMinutes, greaterThanOrEqualTo(58));
      expect(remaining.inMinutes, lessThanOrEqualTo(60));
    });

    test('13. Browser tab reload simulation (same tab): tab-scoped session survives reload and remains valid', () async {
      final now = DateTime.now().toUtc();
      await localStorageSource.saveCustomerSessionStartedAt(now);

      // Verify session is active
      expect(BrowserTabSession.isCustomerTabActive(), isTrue);
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);

      // Simulate F5 page reload in the same tab:
      // In same tab, sessionStorage persists, but in-memory objects reload.
      final reloadedStorage = LocalStorageSource(await SharedPreferences.getInstance());
      expect(BrowserTabSession.isCustomerTabActive(), isTrue);
      expect(reloadedStorage.isCustomerSessionExpired(), isFalse);
      expect(reloadedStorage.getCustomerSessionStartedAt(), isNotNull);
    });

    test('14. Tab closure / New tab simulation: new tab lacks tab-scoped session and requires login', () async {
      final now = DateTime.now().toUtc();
      await localStorageSource.saveCustomerSessionStartedAt(now);

      // Verify active in original tab
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);

      // Simulate opening a new browser tab or reopening browser:
      // sessionStorage is tab-isolated, so in the new tab, sessionStorage is completely empty.
      BrowserTabSession.clearCustomerTab();

      final newTabStorage = LocalStorageSource(await SharedPreferences.getInstance());
      expect(BrowserTabSession.isCustomerTabActive(), isFalse);
      expect(newTabStorage.isCustomerSessionExpired(), isTrue);
    });

    test('15. Strict 2-hour boundary: valid at 1h59m, expired at exactly 2h00m', () async {
      final now = DateTime.now().toUtc();

      // At 1 hour 59 minutes: still valid
      final almostExpired = now.subtract(const Duration(hours: 1, minutes: 59));
      await localStorageSource.saveCustomerSessionStartedAt(almostExpired);
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);

      // At exactly 2 hours: expired
      final exactlyTwoHours = now.subtract(const Duration(hours: 2));
      await localStorageSource.saveCustomerSessionStartedAt(exactlyTwoHours);
      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
    });

    test('16. Explicit logout wipes both tab-scoped sessionStorage and SharedPreferences', () async {
      final now = DateTime.now().toUtc();
      await localStorageSource.saveCustomerSessionStartedAt(now);
      expect(localStorageSource.isCustomerSessionExpired(), isFalse);

      await localStorageSource.clearCustomerSession();

      expect(BrowserTabSession.isCustomerTabActive(), isFalse);
      expect(BrowserTabSession.getCustomerSessionStartedAt(), isNull);
      expect(BrowserTabSession.getCustomerSessionExpiresAt(), isNull);
      expect(localStorageSource.getCustomerSessionStartedAt(), isNull);
      expect(localStorageSource.getCustomerSessionExpiresAt(), isNull);
      expect(localStorageSource.isCustomerSessionExpired(), isTrue);
    });
  });
}


