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
    final selectedName = selectedCat?.name ?? (catFilter.isEmpty ? 'All' : 'Unknown');
    final selectedSlug = selectedCat?.slug ?? (catFilter.isEmpty ? 'N/A' : catFilter);

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

    // Temporary debug logs for filter investigation
    print("Selected Category: $selectedName");
    print("ID: ${selectedId.isEmpty ? 'N/A' : selectedId}");
    print("Slug: $selectedSlug");
    print("Name: $selectedName");

    for (final e in _allActiveExperiences) {
      final relationExists = e.categoryIds.any((id) => rxCategories.any((c) => c.id == id));
      final matchesSelected = selectedId.isEmpty || e.categoryIds.contains(selectedId);
      print("Experience: ${e.name}");
      print("Category ID: ${e.categoryId}");
      print("Category Name: ${e.categoryName}");
      print("Category Slug: ${e.categorySlug}");
      print("Relation Loaded: ${relationExists ? 'YES' : 'NO'}");
      print("Matches Selected Category: ${matchesSelected ? 'YES' : 'NO'}");
    }

    print("Total Experiences Loaded: ${_allActiveExperiences.length}");
    print("Filtered Experiences: ${list.length}");
    print("IDs Returned: ${list.map((e) => e.id).join(', ')}");

    rxExperiences.assignAll(list);
  }
}
