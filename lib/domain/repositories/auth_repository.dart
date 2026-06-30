import '../../data/models/user_model.dart';
import '../entities/admin_role.dart';

abstract class AuthRepository {
  Future<void> loginAdmin(String email, String password);
  Future<void> logout();
  Future<String?> getCurrentUserToken();
  Future<String?> getCurrentUserRole();
  Future<bool> isLoggedIn();

  // Admin User CRUD Operations
  Future<List<UserModel>> getUsers();
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String uid);

  // RBAC Admin Roles CRUD Operations
  Future<AdminRole?> getAdminRole(String uid);
  Future<List<AdminRole>> getAdminRoles();
  Future<void> saveAdminRole(AdminRole role, {required bool isEdit});
  Future<void> deleteAdminRole(String uid);
}
