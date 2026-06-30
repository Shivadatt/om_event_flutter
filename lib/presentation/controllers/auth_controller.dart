import 'package:get/get.dart';
import '../../core/config/app_routes.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  AuthController(this.authRepository);

  final rxIsLoggedIn = false.obs;
  final rxUserRole = ''.obs;
  final isLoading = false.obs;

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
      rxUserRole.value = role ?? 'staff';
    } else {
      rxUserRole.value = '';
    }
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
      await authRepository.logout();
      await checkAuthStatus();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
