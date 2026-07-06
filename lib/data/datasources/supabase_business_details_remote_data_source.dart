import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/business_details_entity.dart';
import '../models/business_details_model.dart';
import 'business_details_remote_data_source.dart';

import '../repositories/supabase_settings_repository.dart';

class SupabaseBusinessDetailsRemoteDataSourceImpl implements BusinessDetailsRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Stream<BusinessDetailsEntity> streamBusinessDetails() {
    return SupabaseSettingsRepository.getSharedStream(_client).map((rows) {
      if (rows.isEmpty) {
        return BusinessDetailsEntity.defaultVal();
      }
      final data = rows.firstWhere(
        (row) => row['id'] == 'business',
        orElse: () => <String, dynamic>{},
      );
      if (data.isEmpty) {
        return BusinessDetailsEntity.defaultVal();
      }
      final source = data['published'] ?? data['draft'] ?? {};
      if (source.isEmpty) {
        return BusinessDetailsEntity.defaultVal();
      }
      return BusinessDetailsModel.fromJson(Map<String, dynamic>.from(source));
    });
  }

  @override
  Future<void> saveBusinessDetails(BusinessDetailsEntity details) async {
    final Map<String, dynamic> data = BusinessDetailsModel.toJson(details);

    final snap = await _client.from('settings').select('meta').eq('id', 'business').maybeSingle();
    final currentMeta = snap != null ? (snap['meta'] as Map<String, dynamic>? ?? {}) : {};

    final payload = {
      'id': 'business',
      'key': 'business',
      'draft': data,
      'published': data,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    };

    await _client.from('settings').upsert(payload);
  }
}
