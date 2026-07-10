import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contact_number_entity.dart';
import '../../domain/repositories/contact_number_repository.dart';
import '../models/contact_number_model.dart';
import '../mappers/contact_number_mapper.dart';
import 'package:om_event/core/constants/app_collections.dart';

class ContactNumberRepositoryImpl implements ContactNumberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ContactNumberEntity>> streamContactNumbers() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('data')
        .collection('public')
        .doc('business')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return [];
          final data = doc.data()!;
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
    final docRef = _firestore
        .collection(AppCollections.settings)
        .doc('data')
        .collection('public')
        .doc('business');
    final snap = await docRef.get();
    final currentData = snap.exists ? snap.data()! : {};
    final draft = Map<String, dynamic>.from(currentData['draft'] ?? {});
    draft['contactNumbers'] = numbers
        .map(ContactNumberMapper.toModel)
        .map((m) => m.toJson())
        .toList();

    await docRef.set({
      'draft': draft,
      'published': draft,
      'meta': {
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': 'admin',
      },
    }, SetOptions(merge: true));
  }
}
