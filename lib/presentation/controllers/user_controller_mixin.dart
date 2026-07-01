import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/admin_role.dart';
import '../../domain/repositories/auth_repository.dart';

/// Mixin containing User & RBAC Role management state and logic for AdminController.
mixin UserControllerMixin on GetxController {
  final rxUsers = <UserModel>[].obs;
  final isLoadingUsers = false.obs;

  final rxAdminRoles = <AdminRole>[].obs;
  final isLoadingAdminRoles = false.obs;

  /// Loads all staff users.
  Future<void> loadUsers() async {
    try {
      isLoadingUsers.value = true;
      final authRepository = Get.find<AuthRepository>();
      final list = await authRepository.getUsers();
      rxUsers.assignAll(list);
    } catch (e) {
      Get.snackbar("Users Error", e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Saves a user record.
  Future<void> saveUser(UserModel user, {bool isEdit = false}) async {
    try {
      isLoadingUsers.value = true;
      final authRepository = Get.find<AuthRepository>();
      if (isEdit) {
        await authRepository.updateUser(user);
      } else {
        await authRepository.createUser(user);
      }
      await loadUsers();
      Get.snackbar("User Saved", "User profile saved successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Deletes a user record by UID.
  Future<void> deleteUser(String uid) async {
    try {
      isLoadingUsers.value = true;
      final authRepository = Get.find<AuthRepository>();
      await authRepository.deleteUser(uid);
      await loadUsers();
      Get.snackbar("User Deleted", "User removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Loads all administrative roles.
  Future<void> loadAdminRoles() async {
    try {
      isLoadingAdminRoles.value = true;
      final authRepository = Get.find<AuthRepository>();
      final list = await authRepository.getAdminRoles();
      rxAdminRoles.assignAll(list);
    } catch (e) {
      Get.snackbar("RBAC Error", "Failed to load admin roles: ${e.toString()}");
    } finally {
      isLoadingAdminRoles.value = false;
    }
  }

  /// Saves an administrative role record.
  Future<void> saveAdminRole(AdminRole role, {required bool isEdit}) async {
    try {
      isLoadingAdminRoles.value = true;
      final authRepository = Get.find<AuthRepository>();
      await authRepository.saveAdminRole(role, isEdit: isEdit);
      await loadAdminRoles();
      Get.snackbar(
        "Role Saved",
        "Administrator permissions updated successfully.",
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingAdminRoles.value = false;
    }
  }

  /// Deletes an administrative role record by UID.
  Future<void> deleteAdminRole(String uid) async {
    try {
      isLoadingAdminRoles.value = true;
      final authRepository = Get.find<AuthRepository>();
      await authRepository.deleteAdminRole(uid);
      await loadAdminRoles();
      Get.snackbar("Role Deleted", "Administrator removed successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingAdminRoles.value = false;
    }
  }
}
