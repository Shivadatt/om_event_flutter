import '../entities/category.dart';
import '../entities/experience.dart';
import '../entities/review.dart';

abstract class CatalogRepository {
  // ── One-shot reads (kept for admin CRUD compatibility) ──────────────────

  Future<List<Category>> getCategories();
  Future<List<Experience>> getExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
    bool? activeOnly,
  });
  Future<Experience> getExperienceDetail(String slug);
  Future<List<Review>> getPublishedReviews();

  /// Fetch ALL categories (active + inactive) — for the Admin Panel only.
  Future<List<Category>> getAllCategories();

  /// Patch the [is_active] field on a single category without a full update.
  Future<void> toggleCategoryStatus(String slug, {required bool isActive});

  // ── Realtime Streams (customer-facing) ──────────────────────────────────

  /// Realtime stream of active categories for the customer website.
  Stream<List<Category>> streamCategories();

  /// Realtime stream of ALL categories (active + inactive) for the Admin Panel.
  Stream<List<Category>> streamAllCategories();

  /// Realtime stream of all active experiences (unfiltered).
  /// Filtering by category, search, and sort is performed in-memory by the controller.
  Stream<List<Experience>> streamAllActiveExperiences();

  /// Realtime stream of published customer reviews.
  Stream<List<Review>> streamPublishedReviews();

  // ── Admin CRUD Operations ────────────────────────────────────────────────

  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String slug);

  Future<void> createExperience(Experience experience);
  Future<void> updateExperience(Experience experience);
  Future<void> deleteExperience(String slug);
}
