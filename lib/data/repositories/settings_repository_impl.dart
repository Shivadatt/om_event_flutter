import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:om_event/core/constants/app_collections.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/entities/contact_number_entity.dart';
import '../models/contact_number_model.dart';
import '../mappers/contact_number_mapper.dart';
import '../../domain/repositories/settings_repository.dart';

part 'parts/settings_business.dart';
part 'parts/settings_marketing.dart';
part 'parts/settings_operations.dart';

class SettingsRepositoryImpl
    with SettingsBusiness, SettingsMarketing, SettingsOperations
    implements SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAdminDoc(String docId) {
    const adminDocs = {
      'migrations',
      'analytics',
      'dashboard',
      'invoice',
      'email_templates',
      'sms_templates',
      'notifications',
      'automation',
      'feature_flags',
    };
    return adminDocs.contains(docId);
  }

  @override
  DocumentReference<Map<String, dynamic>> _getDocRef(String docId) {
    final type = _isAdminDoc(docId) ? 'admin' : 'public';
    return _firestore
        .collection(AppCollections.settings)
        .doc('data')
        .collection(type)
        .doc(docId);
  }

  // Publish / Rollback
  @override
  Future<void> publishSettings(String docId) async {
    final docRef = _getDocRef(docId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final draft = data['draft'];
    final meta = data['meta'] as Map<String, dynamic>? ?? {};

    final currentVersion = (meta['version'] ?? 1) as int;
    final newVersion = currentVersion + 1;
    final now = DateTime.now().toIso8601String();

    await docRef.collection('history').doc(currentVersion.toString()).set({
      'published': data['published'] ?? draft,
      'meta': meta,
    });

    await docRef.update({
      'published': draft,
      'meta': {
        ...meta,
        'version': newVersion,
        'updatedAt': now,
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    });

    await _firestore.collection(AppCollections.activityLogs).add({
      'who_updated': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      'action': 'Publish',
      'what_changed': docId,
      'old_value': 'v$currentVersion',
      'new_value': 'v$newVersion',
      'date': now,
      'device': 'CMS Web Console',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVersionHistory(String docId) async {
    final snap =
        await _getDocRef(docId)
            .collection('history')
            .orderBy('meta.version', descending: true)
            .get();
    return snap.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> rollbackToVersion(String docId, int version) async {
    final docRef = _getDocRef(docId);
    final historyDoc =
        await docRef.collection('history').doc(version.toString()).get();
    if (!historyDoc.exists) return;

    final historyData = historyDoc.data()!;
    final publishedVal = historyData['published'];
    final meta = historyData['meta'] as Map<String, dynamic>? ?? {};

    final now = DateTime.now().toIso8601String();

    await docRef.set({
      'draft': publishedVal,
      'published': publishedVal,
      'meta': {
        ...meta,
        'updatedAt': now,
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    });
  }

  @override
  Future<void> _saveToDraft(
    String docId,
    Map<String, dynamic> draftData,
  ) async {
    final docRef = _getDocRef(docId);
    final snap = await docRef.get();
    final currentMeta =
        snap.exists
            ? (snap.data()?['meta'] as Map<String, dynamic>? ?? {})
            : {};

    await docRef.set({
      'draft': draftData,
      'published': draftData,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    }, SetOptions(merge: true));
  }
}
