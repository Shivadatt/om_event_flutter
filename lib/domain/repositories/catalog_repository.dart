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

  // Admin CRUD Operations
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String slug);

  Future<void> createExperience(Experience experience);
  Future<void> updateExperience(Experience experience);
  Future<void> deleteExperience(String slug);
}
