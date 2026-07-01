import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/admin_role.dart';
import '../../models/admin_role_model.dart';

/// Mixin responsibility to handle admin role permissions CRUD and RBAC mappings.
mixin AuthRoleRepositoryMixin {
  /// Firestore database source.
  FirebaseFirestore get firestore;

  /// Retrieve a specific administrator's active role.
  Future<AdminRole?> getAdminRole(String uid) async {
    final doc = await firestore.collection('admin').doc(uid).get();
    if (!doc.exists) return null;
    return AdminRoleModel.fromJson(doc.data()!, doc.id);
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
