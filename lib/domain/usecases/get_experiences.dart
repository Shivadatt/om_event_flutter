import '../entities/experience.dart';
import '../repositories/catalog_repository.dart';

class GetExperiences {
  final CatalogRepository repository;
  GetExperiences(this.repository);

  Future<List<Experience>> call({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
  }) async {
    return await repository.getExperiences(
      categorySlug: categorySlug,
      searchQuery: searchQuery,
      themeFilter: themeFilter,
      featuredOnly: featuredOnly,
      sortBy: sortBy,
    );
  }
}
