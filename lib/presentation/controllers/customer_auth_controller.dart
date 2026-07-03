import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../domain/repositories/customer_auth_repository.dart';
import '../../domain/entities/customer_profile.dart';
import '../../core/config/app_routes.dart';
import '../../core/services/fcm/fcm_module.dart';
import '../../data/datasources/local_storage_source.dart';
import '../../core/utils/app_logger.dart';

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

        // Fetch and cache user role
        final role = await _fetchAndCacheRole() ?? 'customer';

        // FCM initialization
        await FcmService.to.initialize(
          userId: uid,
          role: role,
        );
      }
    } else {
      rxCustomerProfile.value = null;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await _authRepository.loginWithEmail(email, password);
      await _fetchAndCacheRole();
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
      await _fetchAndCacheRole();
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
      await _fetchAndCacheRole();
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
      await _fetchAndCacheRole();
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
        await _fetchAndCacheRole();
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
          await _fetchAndCacheRole();
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
        await FcmService.to.cleanup(uid);
      }
      final localStorage = Get.find<LocalStorageSource>();
      await localStorage.clearUserRole();
      await _authRepository.logout();
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Logout Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user role from Supabase Edge Function and cache it locally.
  Future<String?> _fetchAndCacheRole() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final token = await currentUser.getIdToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('https://kwegyvbgdaednljyhcgm.supabase.co/functions/v1/verify-firebase-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['user'] != null) {
          final role = data['user']['role'] as String?;
          if (role != null) {
            final localStorage = Get.find<LocalStorageSource>();
            await localStorage.saveUserRole(role);
            return role;
          }
        }
      }
    } catch (e) {
      AppLogger.error('Failed to fetch customer role from Edge Function', e);
    }
    return null;
  }
}
