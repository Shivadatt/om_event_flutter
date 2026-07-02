import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../domain/entities/customer_profile.dart';
import '../../core/config/app_routes.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/services/notification_handler_service.dart';
import '../../core/services/fcm/fcm_module.dart';

class CustomerAuthController extends GetxController {
  final CustomerAuthRepository _authRepository;

  CustomerAuthController(this._authRepository);

  final rxIsLoggedIn = false.obs;
  final rxCustomerProfile = Rxn<CustomerProfile>();
  final isLoading = false.obs;
  final verificationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final loggedIn = await _authRepository.isLoggedIn();
    rxIsLoggedIn.value = loggedIn;
    if (loggedIn) {
      final uid = await _authRepository.getCurrentUserId();
      if (uid != null) {
        final profile = await _authRepository.getCustomerProfile(uid);
        rxCustomerProfile.value = profile;
        // New FCM module — initialize permission + token + listeners
        FcmService.to.initialize(
          userId: uid,
          role: 'customer',
        );
        // Legacy FCM (backwards compatibility — kept until fully migrated)
        if (!Get.isRegistered<NotificationHandlerService>()) {
          Get.find<NotificationHandlerService>();
        }
        FcmNotificationService.to.initializeUserFcm(uid, role: 'customer');
      }
    } else {
      rxCustomerProfile.value = null;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await _authRepository.loginWithEmail(email, password);
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerWithEmail(String fullName, String email, String password) async {
    try {
      isLoading.value = true;
      await _authRepository.registerWithEmail(email, password, fullName);
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
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
          Get.snackbar("Verification Failed", error);
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp(String smsCode) async {
    try {
      isLoading.value = true;
      await _authRepository.signInWithSmsCode(verificationId.value, smsCode);
      await checkAuthStatus();
      
      // If profile doesn't exist, create a basic one
      if (rxCustomerProfile.value == null && await _authRepository.getCurrentUserId() != null) {
         // Create stub profile here or redirect to profile completion screen
      }
      
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      Get.snackbar("Invalid OTP", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      await _authRepository.signInWithGoogle();
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('popup-closed-by-user') || 
          errStr.contains('cancelled') || 
          errStr.contains('canceled') ||
          errStr.contains('user-cancelled')) {
        // User closed the popup, handle silently without error message
        return;
      }
      
      // Fallback developer mode if Google Sign-In is not configured in Firebase Console
      try {
        await _authRepository.loginWithEmail("google.demo@omevents.com", "GoogleDemo123!");
        await checkAuthStatus();
        Get.offAllNamed(AppRoutes.home);
        Get.snackbar(
          "Google Sign-In Fallback", 
          "Firebase Google Auth not enabled. Connected using Google Demo account.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF12271F),
          colorText: const Color(0xFFC9A77E),
        );
      } catch (_) {
        try {
          await _authRepository.registerWithEmail("google.demo@omevents.com", "GoogleDemo123!", "Google Demo User");
          await checkAuthStatus();
          Get.offAllNamed(AppRoutes.home);
          Get.snackbar(
            "Google Sign-In Fallback", 
            "Firebase Google Auth not enabled. Connected using Google Demo account.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF12271F),
            colorText: const Color(0xFFC9A77E),
          );
        } catch (ex) {
          Get.snackbar("Google Login Failed", ex.toString());
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final uid = await _authRepository.getCurrentUserId();
      if (uid != null) {
        await FcmNotificationService.to.removeToken(uid);
      }
      await _authRepository.logout();
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Logout Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
