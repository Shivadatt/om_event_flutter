import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';

class PermissionItem {
  final String id;
  final String name;
  final String description;

  PermissionItem({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PermissionItem.fromJson(Map<String, dynamic> json, String id) {
    return PermissionItem(
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

/// Repository implementing permission configuration CRUD operations on Supabase.
class SupabasePermissionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PermissionItem>> getPermissions() async {
    final response = await _client.from('permissions').select();
    return response
        .map((row) => PermissionItem.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<List<PermissionItem>> getPermissionsByRole(String roleId) async {
    final response = await _client
        .from('role_permissions')
        .select('permissions(*)')
        .eq('role_id', roleId);
    
    return (response as List)
        .map((row) {
          final permData = row['permissions'] as Map<String, dynamic>? ?? {};
          return PermissionItem.fromJson(SupabaseMapper.toCamelCase(permData), permData['id'] ?? '');
        })
        .toList();
  }

  Future<void> savePermission(PermissionItem permission) async {
    final payload = SupabaseMapper.toSnakeCase(permission.toJson());
    await _client.from('permissions').upsert({
      'id': permission.id,
      ...payload,
    });
  }

  Future<void> deletePermission(String id) async {
    await _client.from('permissions').delete().eq('id', id);
  }
}
