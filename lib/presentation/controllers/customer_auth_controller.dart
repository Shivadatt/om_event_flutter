import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../domain/entities/customer_profile.dart';
import '../../core/config/app_routes.dart';
import '../../core/services/bootstrap_service.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/auth_route_helper.dart';
import 'cart_controller.dart';
import 'quotation_controller.dart';

class CustomerAuthController extends GetxController
    with WidgetsBindingObserver {
  final CustomerAuthRepository _authRepository;

  CustomerAuthController(this._authRepository);

  final rxIsLoggedIn = false.obs;
  final rxCustomerProfile = Rxn<CustomerProfile>();
  final rxCustomerBootstrapped = false.obs;
  final isLoading = false.obs;
  final verificationId = ''.obs;

  StreamSubscription<User?>? _authSubscription;
  Timer? _sessionTimer;

  void markCustomerBootstrapped(bool value) {
    rxCustomerBootstrapped.value = value;
  }

  /// Checks if the canonical 2-hour customer session has expired.
  bool isSessionExpired() {
    if (!Get.isRegistered<LocalStorageSource>()) return true;
    return Get.find<LocalStorageSource>().isCustomerSessionExpired();
  }

  /// Whether there is an active Firebase customer with a non-expired 2-hour session.
  bool get isCurrentCustomerSessionValid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return false;
    if (AuthRouteHelper.isCurrentAdminOrStaff()) return false;
    if (isSessionExpired()) return false;
    return true;
  }

  bool get isAuthenticatedCustomer {
    final loggedIn = rxIsLoggedIn.value;
    if (!loggedIn) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return false;
    // Admins and staff are strictly forbidden from having customer lounge access
    if (AuthRouteHelper.isCurrentAdminOrStaff()) return false;
    // Session expiry check: absolute 2-hour session lifetime
    if (isSessionExpired()) return false;
    final profile = rxCustomerProfile.value;
    if (profile != null && profile.id.startsWith('guest_')) return false;
    return true;
  }

  bool get isLoggedIn => isAuthenticatedCustomer;

  void _armSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    if (!Get.isRegistered<LocalStorageSource>()) return;
    final storage = Get.find<LocalStorageSource>();
    if (storage.isCustomerSessionExpired()) return;

    final remaining = storage.getRemainingCustomerSessionDuration();
    if (remaining <= Duration.zero) {
      handleSessionExpired();
      return;
    }
    _sessionTimer = Timer(remaining, () {
      handleSessionExpired();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-validate 2-hour deadline immediately upon returning from sleep/tab switch
      if (isCurrentCustomerSessionValid) {
        _armSessionTimer();
      } else if (rxIsLoggedIn.value && isSessionExpired()) {
        handleSessionExpired();
      }
    }
  }

  void navigateToPostLoginDestination() {
    final rawRedirect = Get.parameters['redirect'];
    if (rawRedirect != null && rawRedirect.isNotEmpty) {
      final decoded = Uri.decodeComponent(rawRedirect);
      if (decoded.startsWith('/') &&
          !decoded.startsWith('/client-login') &&
          !decoded.startsWith('/admin')) {
        Get.offAllNamed(decoded);
        return;
      }
    }
    Get.offAllNamed(AppRoutes.customerDashboard);
  }

  bool _isHandlingExpiry = false;

  /// Terminates an expired 2-hour customer session cleanly and redirects to client login.
  Future<void> handleSessionExpired() async {
    if (_isHandlingExpiry) return;
    _isHandlingExpiry = true;
    try {
      AppLogger.info(
        '[AUTH_SESSION] Explicit sign-out reason: customer session expired',
      );
      _sessionTimer?.cancel();
      _sessionTimer = null;

      try {
        if (Get.isRegistered<LocalStorageSource>()) {
          await Get.find<LocalStorageSource>().clearCustomerSession();
        }
      } catch (_) {}
      try {
        await _authRepository.logout();
      } catch (_) {}
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
        }
      } catch (_) {}

      rxIsLoggedIn.value = false;
      rxCustomerProfile.value = null;
      rxCustomerBootstrapped.value = true;

      // Reset customer-scoped reactive states to isolate sessions
      if (Get.isRegistered<QuotationController>()) {
        Get.find<QuotationController>().rxCreatedQuotation.value = null;
      }
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }

      if (Get.currentRoute != AppRoutes.customerLogin) {
        Get.snackbar(
          "Session Expired",
          "Your 2-hour client lounge session has expired. Please sign in again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          duration: const Duration(seconds: 5),
        );
        final redirect = Uri.encodeComponent(AppRoutes.customerDashboard);
        Get.offAllNamed('${AppRoutes.customerLogin}?redirect=$redirect');
      }
    } finally {
      _isHandlingExpiry = false;
    }
  }


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Fast synchronous prefill from local storage to prevent reload flicker
    _prefillFromLocalStorage();

    // Listen to real-time auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      AppLogger.info(
        '[AUTH_SESSION] Initial auth state received: uid=${user?.uid}',
      );
      AppLogger.info('[AUTH_SESSION] Current user exists: ${user != null}');
      final isAdmin = AuthRouteHelper.isCurrentAdminOrStaff();
      final expired = isSessionExpired();
      final loggedIn =
          user != null && !user.isAnonymous && !isAdmin && !expired;

      if (rxIsLoggedIn.value != loggedIn) {
        rxIsLoggedIn.value = loggedIn;
      }

      if (loggedIn) {
        _armSessionTimer();
        _authRepository
            .getCustomerProfile(user.uid)
            .then((profile) {
              rxCustomerProfile.value =
                  profile ?? _createFallbackCustomerProfile(user);
            })
            .catchError((e) {
              AppLogger.warning("Customer profile load error: $e");
              rxCustomerProfile.value = _createFallbackCustomerProfile(user);
            });
      } else {
        rxCustomerProfile.value = null;
      }
    });

    // React to BootstrapService state to avoid race conditions
    ever(BootstrapService.to.rxIsApplicationReady, (isReady) {
      if (isReady && rxCustomerBootstrapped.value) {
        checkAuthStatus();
      }
    });
    if (BootstrapService.to.rxIsApplicationReady.value &&
        rxCustomerBootstrapped.value) {
      checkAuthStatus();
    }
  }

  CustomerProfile _createFallbackCustomerProfile(User user) {
    return CustomerProfile(
      id: user.uid,
      fullName:
          user.displayName?.isNotEmpty == true
              ? user.displayName!
              : 'Valued Client',
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      gender: '',
      address: 'thol',
      city: 'Ahmedabad',
      state: 'Gujarat',
      pincode: '',
      branch: '',
      profileImageUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  void _prefillFromLocalStorage() {
    if (Get.isRegistered<LocalStorageSource>()) {
      final storage = Get.find<LocalStorageSource>();
      if (!storage.isCustomerSessionExpired()) {
        final user = FirebaseAuth.instance.currentUser;
        final isAdmin = AuthRouteHelper.isCurrentAdminOrStaff();
        if (user != null && !user.isAnonymous && !isAdmin) {
          rxIsLoggedIn.value = true;
          _armSessionTimer();
        }
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final expired = isSessionExpired();

      if (user == null ||
          user.isAnonymous ||
          AuthRouteHelper.isCurrentAdminOrStaff() ||
          expired) {
        if (expired &&
            user != null &&
            !AuthRouteHelper.isCurrentAdminOrStaff() &&
            rxCustomerBootstrapped.value) {
          AppLogger.info(
            '[AUTH_SESSION] Explicit sign-out reason: checkAuthStatus detected expired session',
          );
          await handleSessionExpired();
          return;
        }
        rxIsLoggedIn.value = false;
        rxCustomerProfile.value = null;
        return;
      }

      final loggedIn = await _authRepository.isLoggedIn();
      rxIsLoggedIn.value = loggedIn;
      if (loggedIn) {
        _armSessionTimer();
        final uid = await _authRepository.getCurrentUserId();
        if (uid != null) {
          final profile = await _authRepository.getCustomerProfile(uid);
          rxCustomerProfile.value =
              profile ?? _createFallbackCustomerProfile(user);
        }
      } else {
        rxCustomerProfile.value = null;
      }
    } catch (e) {
      AppLogger.warning("checkAuthStatus error: $e");
    }
  }

  Future<bool> loginWithEmail(
    String email,
    String password, {
    bool navigateHome = true,
  }) async {
    try {
      isLoading.value = true;
      await _authRepository.loginWithEmail(email, password);

      // Strict role boundary: Admin/Staff credentials cannot access Client Portal
      if (AuthRouteHelper.isCurrentAdminOrStaff()) {
        await _authRepository.logout();
        rxIsLoggedIn.value = false;
        rxCustomerProfile.value = null;
        Get.snackbar(
          "Access Denied",
          "Admin accounts cannot access the Client Portal. Please use a customer account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      // Record immutable 2-hour session start timestamp
      if (Get.isRegistered<LocalStorageSource>()) {
        await Get.find<LocalStorageSource>().saveCustomerSessionStartedAt(
          DateTime.now().toUtc(),
        );
      }
      _armSessionTimer();

      await checkAuthStatus();
      if (!isAuthenticatedCustomer) {
        await _authRepository.logout();
        if (Get.isRegistered<LocalStorageSource>()) {
          await Get.find<LocalStorageSource>().clearCustomerSession();
        }
        rxIsLoggedIn.value = false;
        rxCustomerProfile.value = null;
        Get.snackbar(
          "Access Denied",
          "A valid customer account is required to access the Client Portal.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      if (navigateHome) {
        navigateToPostLoginDestination();
      }
      return true;
    } catch (e) {
      Get.snackbar("Login Failed", AppErrorMapper.mapAuthError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerWithEmail(
    String fullName,
    String email,
    String password, {
    bool navigateHome = true,
  }) async {
    try {
      isLoading.value = true;
      final cleanEmail = email.trim().toLowerCase();

      // Duplicate prevention (Phase 8): Check if customer was already provisioned by Admin
      final existingCustSnap =
          await FirebaseFirestore.instance
              .collection('customers')
              .where('email', isEqualTo: cleanEmail)
              .limit(1)
              .get();

      if (existingCustSnap.docs.isNotEmpty) {
        final custData = existingCustSnap.docs.first.data();
        if (custData['login_enabled'] == true) {
          Get.snackbar(
            "Account Already Exists",
            "Client Portal access is already enabled for this email. Please use Login, or use Forgot Password to set your password.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF231B1B),
            colorText: const Color(0xFFFFAA99),
            duration: const Duration(seconds: 6),
          );
          return false;
        }
      }

      await _authRepository.registerWithEmail(email, password, fullName);

      if (AuthRouteHelper.isCurrentAdminOrStaff()) {
        await _authRepository.logout();
        rxIsLoggedIn.value = false;
        rxCustomerProfile.value = null;
        Get.snackbar(
          "Access Denied",
          "Admin accounts cannot access the Client Portal. Please use a customer account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      // Record immutable 2-hour session start timestamp
      if (Get.isRegistered<LocalStorageSource>()) {
        await Get.find<LocalStorageSource>().saveCustomerSessionStartedAt(
          DateTime.now().toUtc(),
        );
      }
      _armSessionTimer();

      await checkAuthStatus();
      if (navigateHome) {
        navigateToPostLoginDestination();
      }
      return true;
    } catch (e) {
      Get.snackbar("Registration Failed", AppErrorMapper.mapAuthError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _authRepository.verifyPhoneNumber(
        phoneNumber,
        (vid) {
          verificationId.value = vid;
          Get.snackbar("OTP Sent", "Please check your messages.");
        },
        (error) {
          Get.snackbar(
            "Verification Failed",
            AppErrorMapper.mapAuthError(error),
          );
        },
      );
    } catch (e) {
      Get.snackbar("Error", AppErrorMapper.mapAuthError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp(String smsCode, {bool navigateHome = true}) async {
    try {
      isLoading.value = true;
      await _authRepository.signInWithSmsCode(verificationId.value, smsCode);

      if (AuthRouteHelper.isCurrentAdminOrStaff()) {
        await _authRepository.logout();
        rxIsLoggedIn.value = false;
        rxCustomerProfile.value = null;
        Get.snackbar(
          "Access Denied",
          "Admin accounts cannot access the Client Portal. Please use a customer account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      // Record immutable 2-hour session start timestamp
      if (Get.isRegistered<LocalStorageSource>()) {
        await Get.find<LocalStorageSource>().saveCustomerSessionStartedAt(
          DateTime.now().toUtc(),
        );
      }
      _armSessionTimer();

      await checkAuthStatus();
      if (navigateHome) {
        navigateToPostLoginDestination();
      }
      return true;
    } catch (e) {
      Get.snackbar("Invalid OTP", AppErrorMapper.mapAuthError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle({bool navigateHome = true}) async {
    try {
      isLoading.value = true;
      await _authRepository.signInWithGoogle();

      if (AuthRouteHelper.isCurrentAdminOrStaff()) {
        await _authRepository.logout();
        rxIsLoggedIn.value = false;
        rxCustomerProfile.value = null;
        Get.snackbar(
          "Access Denied",
          "Admin accounts cannot access the Client Portal. Please use a customer account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Record immutable 2-hour session start timestamp
      if (Get.isRegistered<LocalStorageSource>()) {
        await Get.find<LocalStorageSource>().saveCustomerSessionStartedAt(
          DateTime.now().toUtc(),
        );
      }
      _armSessionTimer();

      await checkAuthStatus();
      if (navigateHome) {
        navigateToPostLoginDestination();
      }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('popup-closed-by-user') ||
          errStr.contains('cancelled') ||
          errStr.contains('canceled') ||
          errStr.contains('user-cancelled')) {
        return;
      }

      // Fallback developer mode if Google Sign-In is not configured in Firebase Console
      try {
        await _authRepository.loginWithEmail(
          "google.demo@omevents.com",
          "GoogleDemo123!",
        );
        if (Get.isRegistered<LocalStorageSource>()) {
          await Get.find<LocalStorageSource>().saveCustomerSessionStartedAt(
            DateTime.now().toUtc(),
          );
        }
        _armSessionTimer();
        await checkAuthStatus();
        if (navigateHome) {
          navigateToPostLoginDestination();
        }
        Get.snackbar(
          "Google Sign-In Fallback",
          "Firebase Google Auth not enabled. Connected using Google Demo account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF12271F),
          colorText: const Color(0xFFC9A77E),
        );
      } catch (_) {
        try {
          await _authRepository.registerWithEmail(
            "google.demo@omevents.com",
            "GoogleDemo123!",
            "Google Demo User",
          );
          if (Get.isRegistered<LocalStorageSource>()) {
            await Get.find<LocalStorageSource>().saveCustomerSessionStartedAt(
              DateTime.now().toUtc(),
            );
          }
          _armSessionTimer();
          await checkAuthStatus();
          if (navigateHome) {
            navigateToPostLoginDestination();
          }
          Get.snackbar(
            "Google Sign-In Fallback",
            "Firebase Google Auth not enabled. Connected using Google Demo account.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF12271F),
            colorText: const Color(0xFFC9A77E),
          );
        } catch (ex) {
          Get.snackbar("Google Login Failed", AppErrorMapper.mapAuthError(ex));
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info(
        '[AUTH_SESSION] Explicit sign-out reason: user initiated explicit customer logout',
      );
      isLoading.value = true;
      _sessionTimer?.cancel();
      _sessionTimer = null;

      // Clear customer session timestamp from localStorage
      if (Get.isRegistered<LocalStorageSource>()) {
        await Get.find<LocalStorageSource>().clearCustomerSession();
      }

      final uid = await _authRepository.getCurrentUserId();
      if (uid != null && uid.isNotEmpty) {
        try {
          if (Get.isRegistered<FcmNotificationService>()) {
            await FcmNotificationService.to.removeToken(uid);
          }
        } catch (e) {
          AppLogger.warning(
            "Customer FCM notification token removal warning on logout: $e",
          );
        }
      }
      // Reset customer-scoped reactive states to isolate sessions
      if (Get.isRegistered<QuotationController>()) {
        Get.find<QuotationController>().rxCreatedQuotation.value = null;
      }
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }
      try {
        await _authRepository.logout();
      } catch (e) {
        AppLogger.warning("Customer auth repository logout warning: $e");
      }
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
        }
      } catch (_) {}

      rxIsLoggedIn.value = false;
      rxCustomerProfile.value = null;
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppLogger.error("Customer logout unexpected error: $e");
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isLoading.value = false;
    }
  }

  Future<CustomerProfile> ensureGuestSession({
    required String name,
    required String phone,
    String? email,
  }) async {
    final profile = await _authRepository.ensureGuestSession(
      name: name,
      phone: phone,
      email: email,
    );
    rxCustomerProfile.value = profile;
    rxIsLoggedIn.value = false;
    return profile;
  }
}
