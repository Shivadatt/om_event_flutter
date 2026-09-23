import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_collections.dart';
import '../../../domain/entities/review.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/review_model.dart';

/// Mixin responsibility to handle reviews domain.
mixin ReviewRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Retrieve all verified, published customer reviews.
  Future<List<Review>> getPublishedReviews() async {
    try {
      final docs = await remoteSource.fetchPublishedReviews();
      return docs
          .map<Review>((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Realtime Streams ─────────────────────────────────────────────────────

  /// Realtime stream of published customer reviews.
  /// Emits a new list automatically whenever Firestore changes.
  Stream<List<Review>> streamPublishedReviews() {
    return remoteSource.streamPublishedReviews().map<List<Review>>(
      (docs) => docs
          .map<Review>((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList(),
    );
  }

  /// Realtime stream of ALL reviews (published + unpublished) for the Admin Panel.
  Stream<List<Review>> streamAllReviews() {
    return _firestore
        .collection(AppCollections.reviews)
        .snapshots()
        .map((snap) {
      final docs = snap.docs
          .map<Review>((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();
      docs.sort((a, b) {
        if (a.isFeatured != b.isFeatured) return b.isFeatured ? 1 : -1;
        if (a.displayOrder != b.displayOrder) return a.displayOrder.compareTo(b.displayOrder);
        return b.createdAt.compareTo(a.createdAt);
      });
      return docs;
    });
  }

  // ── Admin CRUD ───────────────────────────────────────────────────────────

  /// Creates a new customer review document in Firestore.
  Future<void> createReview(Review review) async {
    final model = ReviewModel(
      id: review.id,
      customerName: review.customerName,
      eventName: review.eventName,
      rating: review.rating,
      comment: review.comment,
      imageUrl: review.imageUrl,
      isVerified: review.isVerified,
      isPublished: review.isPublished,
      experienceId: review.experienceId,
      createdAt: review.createdAt,
      isFeatured: review.isFeatured,
      displayOrder: review.displayOrder,
      isActive: review.isActive,
    );
    final data = model.toJson();
    data['created_at'] = FieldValue.serverTimestamp();
    await _firestore.collection(AppCollections.reviews).add(data);
  }

  /// Updates an existing customer review document.
  Future<void> updateReview(Review review) async {
    final model = ReviewModel(
      id: review.id,
      customerName: review.customerName,
      eventName: review.eventName,
      rating: review.rating,
      comment: review.comment,
      imageUrl: review.imageUrl,
      isVerified: review.isVerified,
      isPublished: review.isPublished,
      experienceId: review.experienceId,
      createdAt: review.createdAt,
      isFeatured: review.isFeatured,
      displayOrder: review.displayOrder,
      isActive: review.isActive,
    );
    final data = model.toJson();
    data['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection(AppCollections.reviews).doc(review.id).update(data);
  }

  /// Soft-deletes a review by setting [is_active] to false.
  Future<void> deleteReview(String id) async {
    await _firestore.collection(AppCollections.reviews).doc(id).update({
      'is_active': false,
      'is_published': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
