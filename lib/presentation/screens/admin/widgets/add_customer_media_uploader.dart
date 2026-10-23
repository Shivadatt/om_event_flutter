import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/supabase_storage_source.dart';

/// Service for uploading customer profile photos to Supabase Storage and updating Firestore.
class AddCustomerMediaUploader {
  static Future<bool> uploadPhoto({
    required String normalizedPhone,
    required String authUid,
    required Uint8List photoBytes,
    required String photoName,
    required DocumentReference customerDocRef,
  }) async {
    try {
      final ext = photoName.split('.').last.toLowerCase();
      final sanitizedExt = (ext == 'png' || ext == 'webp' || ext == 'pdf') ? ext : 'jpg';
      final contentType = ext == 'png'
          ? 'image/png'
          : (ext == 'webp' ? 'image/webp' : (ext == 'pdf' ? 'application/pdf' : 'image/jpeg'));

      if (!Get.isRegistered<SupabaseStorageSource>()) {
        return false;
      }

      final storage = Get.find<SupabaseStorageSource>();
      final path = 'customers/${normalizedPhone}_${DateTime.now().millisecondsSinceEpoch}.$sanitizedExt';
      final uploadedPhotoUrl = await storage.uploadFile(
        path,
        photoBytes,
        contentType,
        bucket: 'thumbnails',
      );

      await customerDocRef.update({
        'profile_image_url': uploadedPhotoUrl,
        'profileImageUrl': uploadedPhotoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));

      if (authUid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('customer_profiles')
            .doc(authUid)
            .update({
          'profile_image_url': uploadedPhotoUrl,
          'updated_at': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5)).catchError((_) {});
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
