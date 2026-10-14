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
    return _firestore
        .collection('settings')
        .doc('business_info')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return BusinessDetailsEntity.defaultVal();
          }
          final data = snapshot.data()!;
          final rootBranches = data['branches'];
          final source = data['published'] ?? data['draft'] ?? data;
          if (source is! Map || source.isEmpty) {
            return BusinessDetailsEntity.defaultVal();
          }
          final Map<String, dynamic> merged = Map<String, dynamic>.from(data);
          merged.addAll(Map<String, dynamic>.from(source));
          // Canonical source of truth: root 'branches' if present
          if (rootBranches != null && rootBranches is List && rootBranches.isNotEmpty) {
            merged['branches'] = rootBranches;
          }
          return BusinessDetailsModel.fromJson(merged);
        });
  }

  @override
  Future<void> saveBusinessDetails(BusinessDetailsEntity details) async {
    final Map<String, dynamic> data = BusinessDetailsModel.toJson(details);
    
    final docRef = _firestore
        .collection('settings')
        .doc('business_info');
        
    final snap = await docRef.get();
    final currentMeta =
        snap.exists
            ? (snap.data()?['meta'] as Map<String, dynamic>? ?? {})
            : {};

    await docRef.set({
      'draft': data,
      'published': data,
      'branches': data['branches'],
      'logo': data['logo'],
      'whiteLogo': data['whiteLogo'],
      'favicon': data['favicon'],
      'instagram_kadi': details.social.instagramKadi,
      'instagram_thangadh': details.social.instagramThangadh,
      'website': details.social.website,
      'google_business': details.social.googleBusinessProfile,
      'google_business_profile': details.social.googleBusinessProfile,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    }, SetOptions(merge: true));
  }
}
