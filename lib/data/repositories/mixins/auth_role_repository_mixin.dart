import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/helpers/supabase_mapper.dart';
import '../../../domain/entities/admin_role.dart';
import '../../models/admin_role_model.dart';
import '../../../core/config/rbac_config.dart';

/// Mixin responsibility to handle admin role permissions CRUD and RBAC mappings on Supabase.
mixin AuthRoleRepositoryMixin {
  final SupabaseClient _client = Supabase.instance.client;

  /// Retrieve current active user profile security role type.
  Future<String?> getCurrentUserRole();

  /// Retrieve a specific administrator's active role.
  Future<AdminRole?> getAdminRole(String uid) async {
    final role = await getCurrentUserRole();
    if (role == null) return null;

    final permissions = RbacConfig.getPresetPermissions(role);
    final user = fb.FirebaseAuth.instance.currentUser;

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
    final response = await _client.from('admins').select();
    return response
        .map((row) => AdminRoleModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
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
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    await _client.from('admins').upsert({
      'id': role.uid,
      ...payload,
    });
  }

  /// Delete an administrator team role profile.
  Future<void> deleteAdminRole(String uid) async {
    await _client.from('admins').delete().eq('id', uid);
  }
}
