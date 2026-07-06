import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';

class RoleItem {
  final String id;
  final String name;
  final String description;

  RoleItem({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RoleItem.fromJson(Map<String, dynamic> json, String id) {
    return RoleItem(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

/// Repository implementing role configuration CRUD operations on Supabase.
class SupabaseRoleRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<RoleItem>> getRoles() async {
    final response = await _client.from('roles').select();
    return response
        .map((row) => RoleItem.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<void> saveRole(RoleItem role) async {
    final payload = SupabaseMapper.toSnakeCase(role.toJson());
    await _client.from('roles').upsert({
      'id': role.id,
      ...payload,
    });
  }

  Future<void> deleteRole(String id) async {
    await _client.from('roles').delete().eq('id', id);
  }

  Future<void> assignPermissionToRole(String roleId, String permissionId) async {
    await _client.from('role_permissions').upsert({
      'role_id': roleId,
      'permission_id': permissionId,
    });
  }

  Future<void> revokePermissionFromRole(String roleId, String permissionId) async {
    await _client
        .from('role_permissions')
        .delete()
        .eq('role_id', roleId)
        .eq('permission_id', permissionId);
  }
}
