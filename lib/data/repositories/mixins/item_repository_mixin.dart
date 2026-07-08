import '../../../domain/entities/experience.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/experience_model.dart';

/// Mixin responsibility to handle experiences/decoration items catalog domain.
mixin ItemRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

  /// Retrieve decoration experiences with filters.
  /// Experiences whose parent category is inactive are automatically excluded.
  Future<List<Experience>> getExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
    bool? activeOnly,
  }) async {
    try {
      // Fetch active category slugs first so we can cascade the is_active filter
      // to experiences regardless of whether the experience itself is active.
      final activeCategoryDocs = await remoteSource.fetchCategories();
      final activeCategorySlugs = activeCategoryDocs
          .map((doc) => doc.data()['slug'] as String? ?? '')
          .where((slug) => slug.isNotEmpty)
          .toSet();

      final docs = await remoteSource.fetchExperiences(
        categorySlug: categorySlug,
        searchQuery: searchQuery,
        themeFilter: themeFilter,
        featuredOnly: featuredOnly,
        sortBy: sortBy,
        activeOnly: activeOnly,
      );

      final list = docs.map<Experience>((doc) => ExperienceModel.fromJson(doc.data(), doc.id));

      if (activeOnly != false) {
        return list.where((e) => activeCategorySlugs.contains(e.categorySlug)).toList();
      } else {
        return list.toList();
      }
    } catch (_) {
      return const [];
    }
  }

  /// Retrieve experience detail by its unique slug.
  Future<Experience> getExperienceDetail(String slug) async {
    final doc = await remoteSource.fetchExperienceDetail(slug);
    if (doc.exists && doc.data() != null) {
      return ExperienceModel.fromJson(doc.data()!, doc.id);
    }
    throw Exception("Experience detail not found in Firestore for slug: $slug");
  }

  /// Create a new event decoration experience.
  Future<void> createExperience(Experience experience) async {
    final model = ExperienceModel(
      id: experience.id,
      categoryId: experience.categoryId,
      categoryName: experience.categoryName,
      categorySlug: experience.categorySlug,
      categoryIds: experience.categoryIds,
      name: experience.name,
      slug: experience.slug,
      description: experience.description,
      price: experience.price,
      offerPrice: experience.offerPrice,
      durationHours: experience.durationHours,
      popularity: experience.popularity,
      rating: experience.rating,
      reviewCount: experience.reviewCount,
      availability: experience.availability,
      tags: experience.tags,
      colors: experience.colors,
      themes: experience.themes,
      imageUrl: experience.imageUrl,
      videoUrl: experience.videoUrl,
      isFeatured: experience.isFeatured,
      isActive: experience.isActive,
    );
    await remoteSource.createExperience(model.toJson());
  }

  /// Update details of an existing experience.
  Future<void> updateExperience(Experience experience) async {
    final model = ExperienceModel(
      id: experience.id,
      categoryId: experience.categoryId,
      categoryName: experience.categoryName,
      categorySlug: experience.categorySlug,
      categoryIds: experience.categoryIds,
      name: experience.name,
      slug: experience.slug,
      description: experience.description,
      price: experience.price,
      offerPrice: experience.offerPrice,
      durationHours: experience.durationHours,
      popularity: experience.popularity,
      rating: experience.rating,
      reviewCount: experience.reviewCount,
      availability: experience.availability,
      tags: experience.tags,
      colors: experience.colors,
      themes: experience.themes,
      imageUrl: experience.imageUrl,
      videoUrl: experience.videoUrl,
      isFeatured: experience.isFeatured,
      isActive: experience.isActive,
    );
    await remoteSource.updateExperience(experience.slug, model.toJson());
  }

  /// Remove an experience from catalog indexes.
  Future<void> deleteExperience(String slug) async {
    await remoteSource.deleteExperience(slug);
  }

  // ── Realtime Streams ─────────────────────────────────────────────────────

  /// Realtime stream of all active experiences (unfiltered).
  /// The CatalogController applies category cascade, search, and sort in-memory.
  /// Emits a new list automatically whenever Firestore changes.
  Stream<List<Experience>> streamAllActiveExperiences() {
    return remoteSource.streamAllActiveItems().map<List<Experience>>(
      (docs) => docs
          .map<Experience>((doc) => ExperienceModel.fromJson(doc.data(), doc.id))
          .toList(),
    );
  }
}
