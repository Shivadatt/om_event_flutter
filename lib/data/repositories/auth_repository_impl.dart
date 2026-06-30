import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/admin_role.dart';
import '../datasources/local_storage_source.dart';
import '../models/user_model.dart';
import '../models/admin_role_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalStorageSource _localStorage;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore, this._localStorage);

  @override
  Future<void> loginAdmin(String email, String password) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credentials.user;
      if (user == null) {
        throw const AuthenticationFailure("User authentication failed.");
      }

      // Check admin collection to verify RBAC authority
      var adminRoleDoc = await _firestore.collection('admin').doc(user.uid).get();
      if (!adminRoleDoc.exists) {
        final emailLower = user.email?.toLowerCase().trim() ?? '';
        final isSuper = emailLower == 'omeventsanddecorators@gmail.com';
        final isDemo = emailLower == 'admin@gmail.com';
        final roleType = isSuper
            ? 'super_admin'
            : (isDemo ? 'demo_admin' : 'customer');

        await _firestore.collection('admin').doc(user.uid).set({
          'uid': user.uid,
          'name': isSuper ? 'Super Admin' : (isDemo ? 'Demo Admin' : (user.displayName ?? user.email?.split('@').first ?? 'Customer')),
          'email': user.email,
          'role': roleType,
          'role_type': roleType,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'created_by': 'system',
          'permissions': isSuper
              ? {
                  'can_manage_everything': true,
                  'can_manage_categories': true,
                  'can_manage_items': true,
                  'can_manage_customers': true,
                  'can_manage_users': true,
                  'can_manage_reviews': true,
                  'can_manage_quotes': true,
                  'can_manage_leads': true,
                  'can_manage_settings': true,
                  'can_delete': true,
                  'can_create': true,
                  'can_edit': true,
                }
              : (isDemo
                  ? {
                      'can_manage_categories': true,
                      'can_manage_items': true,
                      'can_manage_customers': true,
                      'can_manage_users': false,
                      'can_manage_reviews': false,
                      'can_manage_quotes': true,
                      'can_manage_leads': true,
                      'can_manage_settings': false,
                      'can_delete': false,
                      'can_create': true,
                      'can_edit': true,
                    }
                  : {
                      'can_manage_categories': false,
                      'can_manage_items': false,
                      'can_manage_customers': false,
                      'can_manage_users': false,
                      'can_manage_reviews': false,
                      'can_manage_quotes': false,
                      'can_manage_leads': false,
                      'can_manage_settings': false,
                      'can_delete': false,
                      'can_create': false,
                      'can_edit': false,
                    }),
        });
        adminRoleDoc = await _firestore.collection('admin').doc(user.uid).get();
      }

      // If the role type is customer, they shouldn't access the admin dashboard.
      final data = adminRoleDoc.data()!;
      final roleType = data['role_type'] ?? data['role'] ?? 'customer';
      if (roleType == 'customer') {
        await _firebaseAuth.signOut();
        throw const AuthenticationFailure("Admin profile not found.");
      }

      final isActive = (data['is_active'] ?? data['isActive']) as bool? ?? true;
      if (!isActive) {
        await _firebaseAuth.signOut();
        throw const AuthenticationFailure("Your account has been disabled.");
      }

      // Fetch JWT ID token
      final token = await user.getIdToken();
      if (token != null) {
        await _localStorage.saveAdminToken(token);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const AuthenticationFailure("Invalid email or password.");
      }
      throw AuthenticationFailure(e.message ?? "Authentication failed.");
    } catch (e) {
      if (e is AuthenticationFailure) rethrow;
      throw AuthenticationFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _localStorage.clearAdminToken();
  }

  @override
  Future<String?> getCurrentUserToken() async {
    final cached = _localStorage.getAdminToken();
    if (cached != null) return cached;
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        await _localStorage.saveAdminToken(token);
        return token;
      }
    }
    return null;
  }

  @override
  Future<String?> getCurrentUserRole() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('admin').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['role_type'] as String?;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final snap = await _firestore.collection('users').get();
    return snap.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // RBAC Admin Roles CRUD Implementations
  @override
  Future<AdminRole?> getAdminRole(String uid) async {
    final doc = await _firestore.collection('admin').doc(uid).get();
    if (!doc.exists) return null;
    return AdminRoleModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<List<AdminRole>> getAdminRoles() async {
    final snap = await _firestore.collection('admin').get();
    return snap.docs.map((doc) => AdminRoleModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> saveAdminRole(AdminRole role, {required bool isEdit}) async {
    final model = AdminRoleModel(
      uid: role.uid,
      name: role.name,
      email: role.email,
      role: role.role,
      isActive: role.isActive,
      createdAt: role.createdAt,
      updatedAt: role.updatedAt,
      createdBy: role.createdBy,
      roleType: role.roleType,
      permissions: role.permissions,
    );
    if (isEdit) {
      await _firestore.collection('admin').doc(role.uid).update(model.toJson());
    } else {
      await _firestore.collection('admin').doc(role.uid).set(model.toJson());
    }
  }

  @override
  Future<void> deleteAdminRole(String uid) async {
    await _firestore.collection('admin').doc(uid).delete();
  }
}
