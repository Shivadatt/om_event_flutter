import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/admin_role.dart';
import '../../models/admin_role_model.dart';
import '../../../core/config/rbac_config.dart';

/// Mixin responsibility to handle admin role permissions CRUD and RBAC mappings.
mixin AuthRoleRepositoryMixin {
  /// Firestore database source.
  FirebaseFirestore get firestore;

  /// Firebase Auth dependency.
  FirebaseAuth get firebaseAuth;

  /// Retrieve current active user profile security role type.
  Future<String?> getCurrentUserRole();

  /// Retrieve a specific administrator's active role.
  Future<AdminRole?> getAdminRole(String uid) async {
    final role = await getCurrentUserRole();
    if (role == null) return null;

    final permissions = RbacConfig.getPresetPermissions(role);
    final user = firebaseAuth.currentUser;

    return AdminRoleModel(
      uid: uid,
      name: user?.displayName ?? user?.email?.split('@').first ?? 'Admin',
      email: user?.email ?? '',
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'system',
      roleType: role,
      permissions: permissions,
    );
  }

  /// Retrieve all administrator team role configurations.
  Future<List<AdminRole>> getAdminRoles() async {
    final snap = await firestore.collection('admin').get();
    return snap.docs
        .map((doc) => AdminRoleModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Save or update an admin role configuration.
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
      await firestore.collection('admin').doc(role.uid).update(model.toJson());
    } else {
      await firestore.collection('admin').doc(role.uid).set(model.toJson());
    }
  }

  /// Delete an administrator team role profile.
  Future<void> deleteAdminRole(String uid) async {
    await firestore.collection('admin').doc(uid).delete();
  }
}
