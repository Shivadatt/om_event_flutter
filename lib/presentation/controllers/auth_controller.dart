import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/app_routes.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/admin_role.dart';
import '../../data/repositories/admin_repository.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/services/notification_handler_service.dart';
import '../../core/services/fcm/fcm_module.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  AuthController(this.authRepository);

  final rxIsLoggedIn = false.obs;
  final rxUserRole = ''.obs;
  final rxAdminRole = Rxn<AdminRole>();
  final isLoading = false.obs;
  final isProfileSaving = false.obs;
  final isPhotoUploading = false.obs;
  final isPasswordChanging = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final loggedIn = await authRepository.isLoggedIn();
    rxIsLoggedIn.value = loggedIn;
    if (loggedIn) {
      final role = await authRepository.getCurrentUserRole();
      rxUserRole.value = role ?? 'demo_admin';
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final adminData = await authRepository.getAdminRole(currentUser.uid);
        rxAdminRole.value = adminData;
        // New FCM module — initialize permission + token + listeners
        FcmService.to.initialize(
          userId: currentUser.uid,
          role: 'admin',
        );
        // Legacy FCM (backwards compatibility — kept until fully migrated)
        if (!Get.isRegistered<NotificationHandlerService>()) {
          Get.find<NotificationHandlerService>();
        }
        FcmNotificationService.to.initializeUserFcm(currentUser.uid, role: 'admin');
      }
    } else {
      rxUserRole.value = '';
      rxAdminRole.value = null;
    }
  }

  bool hasPermission(String permissionKey) {
    final role = rxAdminRole.value;
    if (role == null) return false;
    return role.hasPermission(permissionKey);
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in all email and password fields.");
      return false;
    }

    try {
      isLoading.value = true;
      await authRepository.loginAdmin(email, password);
      await checkAuthStatus();
      Get.offNamed(AppRoutes.adminDashboard);
      return true;
    } catch (e) {
      Get.snackbar("Access Denied", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FcmService.to.cleanup(currentUser.uid);
        await FcmNotificationService.to.removeToken(currentUser.uid);
      }
      await authRepository.logout();
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Full admin role update (used by admin management)
  Future<void> updateAdminProfile(AdminRole profile) async {
    try {
      isLoading.value = true;
      await authRepository.saveAdminRole(profile, isEdit: true);
      await checkAuthStatus();
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Partial profile fields update (name, phone, designation, bio, address)
  Future<bool> updateProfileFields({
    required String name,
    required String phone,
    required String designation,
    required String bio,
    required String address,
  }) async {
    final admin = rxAdminRole.value;
    if (admin == null) return false;

    try {
      isProfileSaving.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.updateAdminProfileFields(admin.uid, {
        'name': name.trim(),
        'display_name': name.trim(),
        'phone': phone.trim(),
        'designation': designation.trim(),
        'bio': bio.trim(),
        'address': address.trim(),
      });
      await checkAuthStatus();
      return true;
    } catch (e) {
      Get.snackbar(
        "Save Failed",
        "Could not save profile: ${e.toString()}",
        backgroundColor: const Color(0xFF2D1515),
      );
      return false;
    } finally {
      isProfileSaving.value = false;
    }
  }

  /// Update photo URL in Firestore after Supabase upload
  Future<bool> updateProfilePhotoUrl(String photoUrl) async {
    final admin = rxAdminRole.value;
    if (admin == null) return false;

    try {
      isPhotoUploading.value = true;
      final adminRepo = Get.find<AdminRepository>();
      await adminRepo.updateAdminPhotoUrl(admin.uid, photoUrl);
      await checkAuthStatus();
      return true;
    } catch (e) {
      Get.snackbar(
        "Upload Failed",
        "Could not update photo URL: ${e.toString()}",
        backgroundColor: const Color(0xFF2D1515),
      );
      return false;
    } finally {
      isPhotoUploading.value = false;
    }
  }

  /// Re-authenticate with current password then update to new password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      Get.snackbar("Error", "No authenticated user found.");
      return false;
    }

    try {
      isPasswordChanging.value = true;

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Then update password
      await user.updatePassword(newPassword);
      Get.snackbar(
        "Password Updated",
        "Your password was changed successfully.",
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        Get.snackbar(
          "Incorrect Password",
          "The current password you entered is wrong.",
          backgroundColor: const Color(0xFF2D1515),
        );
      } else if (e.code == 'weak-password') {
        Get.snackbar(
          "Weak Password",
          "Please choose a stronger password.",
          backgroundColor: const Color(0xFF2D1515),
        );
      } else {
        Get.snackbar(
          "Password Error",
          e.message ?? "Failed to change password.",
          backgroundColor: const Color(0xFF2D1515),
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unexpected error: ${e.toString()}",
        backgroundColor: const Color(0xFF2D1515),
      );
      return false;
    } finally {
      isPasswordChanging.value = false;
    }
  }
}
