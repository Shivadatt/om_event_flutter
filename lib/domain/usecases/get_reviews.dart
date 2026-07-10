import '../entities/review.dart';
import '../repositories/catalog_repository.dart';

class GetReviews {
  final CatalogRepository repository;
  GetReviews(this.repository);

  Future<List<Review>> call() async {
    return await repository.getPublishedReviews();
  }

  Stream<List<Review>> executeStream() {
    return repository.streamPublishedReviews();
  }
}
