abstract class AuthRepository {
  Future<void> loginAdmin(String email, String password);
  Future<void> logout();
  Future<String?> getCurrentUserToken();
  Future<String?> getCurrentUserRole();
  Future<bool> isLoggedIn();
}
