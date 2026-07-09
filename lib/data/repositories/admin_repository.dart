import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/constants/app_status.dart';
import '../../core/constants/app_strings.dart';
import '../models/review_model.dart';

/// Manages application-wide business records from Firestore (reviews, bookings, payments, settings).
class AdminRepository {
  final FirebaseFirestore _firestore;

  /// Creates an [AdminRepository] instance.
  AdminRepository(this._firestore);

  // ── Reviews ───────────────────────────────────────────────────────────────

  /// Retrieve all customer reviews ordered by creation date descending.
  Future<List<ReviewModel>> getReviews() async {
    final snap =
        await _firestore
            .collection(AppCollections.reviews)
            .orderBy(AppStrings.fieldCreatedAt, descending: true)
            .get();
    return snap.docs
        .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Save or update a review record.
  Future<void> saveReview(ReviewModel review, {required bool isEdit}) async {
    if (isEdit) {
      await _firestore
          .collection(AppCollections.reviews)
          .doc(review.id)
          .update(review.toJson());
    } else {
      await _firestore
          .collection(AppCollections.reviews)
          .doc(review.id)
          .set(review.toJson());
    }
  }

  /// Delete a review record by document ID.
  Future<void> deleteReview(String id) async {
    await _firestore.collection(AppCollections.reviews).doc(id).delete();
  }



  // ── Settings ──────────────────────────────────────────────────────────────

  /// Retrieve business-wide settings from Firestore.
  Future<Map<String, dynamic>> getSettings() async {
    final doc =
        await _firestore
            .collection(AppCollections.settings)
            .doc(AppStatus.settingsBusinessDoc)
            .get();
    return doc.data() ?? {};
  }

  /// Save business-wide settings to Firestore.
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _firestore
        .collection(AppCollections.settings)
        .doc(AppStatus.settingsBusinessDoc)
        .set(settings, SetOptions(merge: true));
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  /// Update admin photo URL in the admin collection.
  Future<void> updateAdminPhotoUrl(String uid, String photoUrl) async {
    await _firestore.collection(AppCollections.admin).doc(uid).update({
      AppStrings.fieldPhotoUrl: photoUrl,
      AppStrings.fieldUpdatedAt: DateTime.now().toIso8601String(),
    });
  }

  /// Update editable admin profile fields.
  Future<void> updateAdminProfileFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    await _firestore.collection(AppCollections.admin).doc(uid).update({
      ...fields,
      AppStrings.fieldUpdatedAt: DateTime.now().toIso8601String(),
    });
  }
}
