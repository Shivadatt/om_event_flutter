import '../../../domain/entities/review.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/review_model.dart';

/// Mixin responsibility to handle reviews domain.
mixin ReviewRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

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
}
