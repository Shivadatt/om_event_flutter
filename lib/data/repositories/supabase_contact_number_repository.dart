import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/contact_number_entity.dart';
import '../../domain/repositories/contact_number_repository.dart';
import '../models/contact_number_model.dart';
import '../mappers/contact_number_mapper.dart';

import 'supabase_settings_repository.dart';

class SupabaseContactNumberRepository implements ContactNumberRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Stream<List<ContactNumberEntity>> streamContactNumbers() {
    return SupabaseSettingsRepository.getSharedStream(_client).map((rows) {
      if (rows.isEmpty) return [];
      final data = rows.firstWhere(
        (row) => row['id'] == 'business',
        orElse: () => <String, dynamic>{},
      );
      if (data.isEmpty) return [];
      final source = data['published'] ?? data['draft'] ?? {};
      final List<dynamic> rawContacts = source['contactNumbers'] ?? [];
      if (rawContacts.isEmpty) return [];
      
      return rawContacts
          .map((c) => ContactNumberModel.fromJson(Map<String, dynamic>.from(c)))
          .map(ContactNumberMapper.toEntity)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    });
  }

  @override
  Future<void> saveContactNumbers(List<ContactNumberEntity> numbers) async {
    final snap = await _client.from('settings').select().eq('id', 'business').maybeSingle();
    final currentData = snap ?? {};
    
    final draft = Map<String, dynamic>.from(currentData['draft'] ?? {});
    draft['contactNumbers'] = numbers
        .map(ContactNumberMapper.toModel)
        .map((m) => m.toJson())
        .toList();

    final payload = {
      'id': 'business',
      'key': 'business',
      'draft': draft,
      'published': draft,
      'meta': {
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    };

    await _client.from('settings').upsert(payload);
  }
}
