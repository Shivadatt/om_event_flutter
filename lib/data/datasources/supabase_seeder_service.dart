import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../core/utils/app_logger.dart';
import 'sql_seed_data.dart';
import 'seeds/booking_seed.dart';

/// Database seeder that seeds Supabase using UPSERT from local static data sources.
class SupabaseSeederService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Migrates all data from local static seeds to Supabase.
  /// Reports progress via [onProgress] callback.
  Future<void> migrateAll({
    required Function(String status, double progress) onProgress,
  }) async {
    try {
      onProgress("Pruning database & checking lock", 0.05);

      // 1. Sync Categories
      onProgress("Migrating Categories...", 0.15);
      await _migrateCollection(
        supabaseTable: 'categories',
        fallbackData: SqlSeedData.categories,
      );

      // 2. Sync Services
      onProgress("Migrating Services (Decoration Items)...", 0.30);
      await _migrateCollection(
        supabaseTable: 'experiences',
        fallbackData: SqlSeedData.decorationItems,
        keyMapper: (doc) {
          final data = Map<String, dynamic>.from(doc);
          if (data.containsKey('categoryId')) {
            data['category_id'] = data['categoryId'];
          }
          return data;
        },
      );

      // 3. Sync Roles & Permissions
      onProgress("Bootstrapping RBAC Roles...", 0.45);
      await _bootstrapRbac();

      // 4. Sync Customers
      onProgress("Migrating Customers CRM...", 0.60);
      await _migrateCollection(
        supabaseTable: 'customers',
        fallbackData: SqlSeedData.customers,
      );

      // 5. Sync Leads
      onProgress("Migrating Leads...", 0.70);
      await _migrateCollection(
        supabaseTable: 'leads',
        fallbackData: SqlSeedData.leads,
      );

      // 6. Sync Bookings
      onProgress("Migrating Bookings...", 0.80);
      await _migrateCollection(
        supabaseTable: 'bookings',
        fallbackData: BookingSeed.bookings,
      );

      // 7. Sync Payments
      onProgress("Migrating Payments...", 0.90);
      await _migrateCollection(
        supabaseTable: 'payments',
        fallbackData: const [],
      );

      onProgress("Database Migration Completed Successfully!", 1.0);
    } catch (e) {
      AppLogger.error("Supabase Seeder Migration Failed", e);
      onProgress("Migration Failed: ${e.toString()}", 0.0);
      rethrow;
    }
  }

  /// Helper to migrate a single collection with PostgreSQL UPSERT logic.
  Future<void> _migrateCollection({
    required String supabaseTable,
    required List<Map<String, dynamic>> fallbackData,
    Map<String, dynamic> Function(Map<String, dynamic> doc)? keyMapper,
  }) async {
    List<Map<String, dynamic>> records = fallbackData;

    for (final record in records) {
      final recordId = record['id'] ?? record['uid'] ?? '';
      if (recordId.toString().isEmpty) continue;

      var data = Map<String, dynamic>.from(record);
      if (keyMapper != null) {
        data = keyMapper(data);
      }

      final payload = SupabaseMapper.toSnakeCase(data);
      // Ensure primary key matches
      payload['id'] = recordId;

      await _client.from(supabaseTable).upsert(payload);
    }
  }

  /// Seed initial RBAC roles and permissions.
  Future<void> _bootstrapRbac() async {
    final roles = [
      {'id': 'super_admin', 'name': 'Super Administrator', 'description': 'Full system override access'},
      {'id': 'admin', 'name': 'Administrator', 'description': 'CRM bookings and payments manager'},
      {'id': 'demo_admin', 'name': 'Demo Account', 'description': 'Read-only profile validator'},
      {'id': 'staff', 'name': 'Decorator Staff', 'description': 'Venue operations coordinator'},
      {'id': 'customer', 'name': 'Portal User', 'description': 'Standard client portal account'}
    ];

    for (final role in roles) {
      await _client.from('roles').upsert(role);
    }

    final permissions = [
      {'id': 'edit_bookings', 'name': 'Edit Bookings', 'description': 'Allows updating event reservations'},
      {'id': 'view_revenue', 'name': 'View Revenue', 'description': 'Allows viewing billing reports'},
      {'id': 'manage_users', 'name': 'Manage Users', 'description': 'Allows editing admin profiles'}
    ];

    for (final perm in permissions) {
      await _client.from('permissions').upsert(perm);
    }
  }
}
