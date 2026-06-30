import '../entities/category.dart';
import '../entities/experience.dart';
import '../entities/review.dart';

abstract class CatalogRepository {
  Future<List<Category>> getCategories();
  Future<List<Experience>> getExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
  });
  Future<Experience> getExperienceDetail(String slug);
  Future<List<Review>> getPublishedReviews();
}
