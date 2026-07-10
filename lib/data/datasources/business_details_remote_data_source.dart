import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/business_details_entity.dart';
import '../models/business_details_model.dart';

abstract class BusinessDetailsRemoteDataSource {
  Stream<BusinessDetailsEntity> streamBusinessDetails();
  Future<void> saveBusinessDetails(BusinessDetailsEntity details);
}

class BusinessDetailsRemoteDataSourceImpl implements BusinessDetailsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<BusinessDetailsEntity> streamBusinessDetails() {
    // Restructured settings collection path: settings/data/public/business
    return _firestore
        .collection('settings')
        .doc('data')
        .collection('public')
        .doc('business')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return BusinessDetailsEntity.defaultVal();
          }
          final data = snapshot.data()!;
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
    
    // Restructured settings collection path: settings/data/public/business
    final docRef = _firestore
        .collection('settings')
        .doc('data')
        .collection('public')
        .doc('business');
        
    final snap = await docRef.get();
    final currentMeta =
        snap.exists
            ? (snap.data()?['meta'] as Map<String, dynamic>? ?? {})
            : {};

    await docRef.set({
      'draft': data,
      'published': data,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    }, SetOptions(merge: true));
  }
}
