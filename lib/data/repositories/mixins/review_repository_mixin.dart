import '../../../domain/entities/review.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/review_model.dart';

/// Mixin responsibility to handle reviews domain.
mixin ReviewRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

  static final List<Review> _fallbackReviews = [
    Review(
      id: 'rev-1',
      customerName: 'Riya & Aakash',
      eventName: 'Engagement Styling',
      rating: 5,
      comment:
          'They understood the mood instantly. Every corner felt intentional, and the quotation stayed completely transparent.',
      imageUrl: '',
      isVerified: true,
      isPublished: true,
      createdAt: DateTime.now(),
    ),
    Review(
      id: 'rev-2',
      customerName: 'Meera Patel',
      eventName: 'First Birthday Celebration',
      rating: 5,
      comment:
          'Beautiful execution, calm team, zero last-minute chaos. The pastel setup looked even better in person.',
      imageUrl: '',
      isVerified: true,
      isPublished: true,
      createdAt: DateTime.now(),
    ),
  ];

  /// Get fallback reviews.
  List<Review> get fallbackReviews => _fallbackReviews;

  /// Retrieve all verified, published customer reviews.
  Future<List<Review>> getPublishedReviews() async {
    try {
      final docs = await remoteSource.fetchPublishedReviews();
      return docs
          .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return _fallbackReviews;
    }
  }
}
