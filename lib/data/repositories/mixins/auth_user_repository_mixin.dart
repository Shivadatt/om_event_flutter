import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/helpers/supabase_mapper.dart';
import '../../models/user_model.dart';

/// Mixin responsibility to handle standard user records CRUD on Supabase.
mixin AuthUserRepositoryMixin {
  final SupabaseClient _client = Supabase.instance.client;

  /// Retrieve all registered mobile app users.
  Future<List<UserModel>> getUsers() async {
    final response = await _client.from('users').select();
    return response
        .map((row) => UserModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  /// Create a new mobile user account index.
  Future<void> createUser(UserModel user) async {
    final payload = SupabaseMapper.toSnakeCase(user.toJson());
    await _client.from('users').upsert({
      'id': user.id,
      ...payload,
    });
  }

  /// Update existing details for a user.
  Future<void> updateUser(UserModel user) async {
    final payload = SupabaseMapper.toSnakeCase(user.toJson());
    await _client.from('users').update(payload).eq('id', user.id);
  }

  /// Delete a user record.
  Future<void> deleteUser(String uid) async {
    await _client.from('users').delete().eq('id', uid);
  }
}
