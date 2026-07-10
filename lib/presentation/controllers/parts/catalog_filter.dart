// ignore_for_file: avoid_print
part of '../catalog_controller.dart';

extension CatalogFilterExtension on CatalogController {
  /// Filters [_allActiveExperiences] by active categories, selected category,
  /// search query, and sort order, then assigns the result to [rxExperiences].
  void applyExperienceFilters() {
    // Resolve selected category using active slug
    final catFilter = selectedCategorySlug.value;
    final selectedCat = rxCategories.firstWhereOrNull((c) => c.slug == catFilter);
    final selectedId = selectedCat?.id ?? '';

    // Cascade filter using category IDs
    final activeIds = rxCategories.map((c) => c.id).toSet();
    var list =
        activeIds.isEmpty
            ? List<Experience>.from(_allActiveExperiences)
            : _allActiveExperiences
                .where((e) => e.categoryIds.any((id) => activeIds.contains(id)))
                .toList();

    // Category tab filter using ID-based relationship
    if (selectedId.isNotEmpty) {
      list = list.where((e) => e.categoryIds.contains(selectedId)).toList();
    }

    // Keyword search
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      final keywords = query.split(RegExp(r'\s+'));
      list = list.where((e) {
        return keywords.every((keyword) {
          return e.name.toLowerCase().contains(keyword) ||
              e.categoryName.toLowerCase().contains(keyword) ||
              e.categorySlug.toLowerCase().contains(keyword) ||
              e.description.toLowerCase().contains(keyword) ||
              e.tags.any((t) => t.toLowerCase().contains(keyword));
        });
      }).toList();
    }

    // Sort
    switch (sortBy.value) {
      case 'price_low':
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      default:
        // 'popular' and 'latest' both sort by popularity
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
    }

    rxExperiences.assignAll(list);
  }
}
