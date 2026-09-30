import 'package:get/get.dart';
import '../../data/datasources/seeds/category_seed.dart';
import '../../data/datasources/seeds/items_seed.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/customer_lead.dart';
import '../../domain/entities/experience.dart';
import '../../presentation/controllers/catalog_controller.dart';
import '../utils/app_logger.dart';

/// Result container for catalog match operations.
class CatalogMatchResult {
  final String serviceId;
  final String serviceSlug;
  final String imageUrl;
  final String videoUrl;
  final String categoryId;
  final String source;

  const CatalogMatchResult({
    this.serviceId = '',
    this.serviceSlug = '',
    this.imageUrl = '',
    this.videoUrl = '',
    this.categoryId = '',
    this.source = 'fallback',
  });
}

/// Authoritative resolver that maps an inquiry to its canonical catalog image.
///
/// Follows strict resolution priority:
/// 1. Stored / historical image URL on the inquiry (`lead.imageUrl`)
/// 2. Canonical service / item ID lookup (`lead.serviceId`)
/// 3. Canonical service slug lookup (`lead.serviceSlug`)
/// 4. Canonical category ID / relation lookup (`lead.categoryId`)
/// 5. Controlled tokenized matching against canonical in-memory catalog
/// 6. Empty string fallback (triggers project branded placeholder widget)
///
/// Designed with zero N+1 Firestore queries, instant synchronous resolution,
/// and in-memory memoization cache for smooth 60fps scrolling.
class InquiryImageResolver {
  // In-memory cache to guarantee O(1) resolution without repeat iterations on widget rebuilds.
  static final Map<String, String> _resolvedImageCache = <String, String>{};
  static final Map<String, CatalogMatchResult> _catalogMatchCache = <String, CatalogMatchResult>{};

  /// Clears the in-memory resolution caches (e.g. when catalog is refreshed).
  static void clearCache() {
    _resolvedImageCache.clear();
    _catalogMatchCache.clear();
  }

  /// Resolves the canonical image URL for a given [CustomerLead].
  /// Returns empty string if no valid catalog image could be determined.
  static String resolve(CustomerLead lead) {
    final cacheKey = '${lead.id}_${lead.leadNumber}_${lead.serviceId}_${lead.serviceSlug}_${lead.service}';
    if (_resolvedImageCache.containsKey(cacheKey)) {
      return _resolvedImageCache[cacheKey]!;
    }

    String resolvedUrl = '';
    String resolvedSource = 'none';

    // ── Priority 1: Historical / stored image reference on inquiry ───────────
    if (lead.imageUrl.trim().isNotEmpty && _isValidImageUrl(lead.imageUrl)) {
      resolvedUrl = lead.imageUrl.trim();
      resolvedSource = 'lead.imageUrl (historical)';
    }

    // ── Priority 2: Canonical service / item ID ─────────────────────────────
    if (resolvedUrl.isEmpty && lead.serviceId.trim().isNotEmpty) {
      final item = _findItemById(lead.serviceId.trim());
      if (item != null && item.imageUrl.trim().isNotEmpty && _isValidImageUrl(item.imageUrl)) {
        resolvedUrl = item.imageUrl.trim();
        resolvedSource = 'catalog item.id (${item.id})';
      }
    }

    // ── Priority 3: Canonical service slug ──────────────────────────────────
    if (resolvedUrl.isEmpty && lead.serviceSlug.trim().isNotEmpty) {
      final item = _findItemBySlug(lead.serviceSlug.trim());
      if (item != null && item.imageUrl.trim().isNotEmpty && _isValidImageUrl(item.imageUrl)) {
        resolvedUrl = item.imageUrl.trim();
        resolvedSource = 'catalog item.slug (${item.slug})';
      } else {
        final cat = _findCategoryBySlug(lead.serviceSlug.trim());
        if (cat != null && cat.imageUrl.trim().isNotEmpty && _isValidImageUrl(cat.imageUrl)) {
          resolvedUrl = cat.imageUrl.trim();
          resolvedSource = 'catalog category.slug (${cat.slug})';
        }
      }
    }

    // ── Priority 4: Canonical category ID / relation ─────────────────────────
    if (resolvedUrl.isEmpty && lead.categoryId.trim().isNotEmpty) {
      final cat = _findCategoryById(lead.categoryId.trim());
      if (cat != null && cat.imageUrl.trim().isNotEmpty && _isValidImageUrl(cat.imageUrl)) {
        resolvedUrl = cat.imageUrl.trim();
        resolvedSource = 'catalog category.id (${cat.id})';
      }
    }

    // ── Priority 5: Controlled normalized matching against catalog ──────────
    if (resolvedUrl.isEmpty && lead.service.trim().isNotEmpty) {
      final match = findBestCatalogMatch(lead.service.trim());
      if (match.imageUrl.isNotEmpty && _isValidImageUrl(match.imageUrl)) {
        resolvedUrl = match.imageUrl;
        resolvedSource = match.source;
      }
    }

    // Verification logging (audit trail)
    AppLogger.debug(
      "INQUIRY IMAGE RESOLUTION -> "
      "Inquiry ID: ${lead.leadNumber.isNotEmpty ? lead.leadNumber : lead.id} | "
      "Service: '${lead.service}' | "
      "Service ID: '${lead.serviceId}' | "
      "Item ID: '${lead.serviceId}' | "
      "Slug: '${lead.serviceSlug}' | "
      "Resolved Image Source: $resolvedSource | "
      "Resolved Image URL: $resolvedUrl",
      layer: LogLayer.service,
      className: "InquiryImageResolver",
      methodName: "resolve",
    );

    _resolvedImageCache[cacheKey] = resolvedUrl;
    return resolvedUrl;
  }

  /// Finds the best matching canonical item or category from the existing catalog
  /// for a given service requirement text.
  static CatalogMatchResult findBestCatalogMatch(String serviceName) {
    final normalizedInput = _normalize(serviceName);
    if (normalizedInput.isEmpty) {
      return const CatalogMatchResult();
    }

    if (_catalogMatchCache.containsKey(normalizedInput)) {
      return _catalogMatchCache[normalizedInput]!;
    }

    final allItems = _getAllCatalogItems();
    final allCategories = _getAllCatalogCategories();

    // 1. Try exact or high-confidence match on catalog items
    Experience? bestItem;
    int highestItemScore = 0;

    for (final item in allItems) {
      final score = _calculateScore(normalizedInput, item);
      if (score > highestItemScore) {
        highestItemScore = score;
        bestItem = item;
      }
    }

    // 2. Try match on catalog categories
    Category? bestCategory;
    int highestCategoryScore = 0;

    for (final cat in allCategories) {
      final score = _calculateCategoryScore(normalizedInput, cat);
      if (score > highestCategoryScore) {
        highestCategoryScore = score;
        bestCategory = cat;
      }
    }

    CatalogMatchResult result;

    // Prefer item over category if item score is competitive (item score >= 40 and >= category score - 10)
    if (bestItem != null && highestItemScore >= 40 && highestItemScore >= (highestCategoryScore - 10)) {
      result = CatalogMatchResult(
        serviceId: bestItem.id,
        serviceSlug: bestItem.slug,
        imageUrl: bestItem.imageUrl,
        videoUrl: bestItem.videoUrl,
        categoryId: bestItem.categoryId,
        source: "catalog item '${bestItem.name}' (score: $highestItemScore)",
      );
    } else if (bestCategory != null && highestCategoryScore >= 35) {
      result = CatalogMatchResult(
        serviceId: '',
        serviceSlug: bestCategory.slug,
        imageUrl: bestCategory.imageUrl,
        videoUrl: '',
        categoryId: bestCategory.id,
        source: "catalog category '${bestCategory.name}' (score: $highestCategoryScore)",
      );
    } else if (bestItem != null && highestItemScore > 0) {
      result = CatalogMatchResult(
        serviceId: bestItem.id,
        serviceSlug: bestItem.slug,
        imageUrl: bestItem.imageUrl,
        videoUrl: bestItem.videoUrl,
        categoryId: bestItem.categoryId,
        source: "catalog item partial '${bestItem.name}' (score: $highestItemScore)",
      );
    } else {
      result = const CatalogMatchResult();
    }

    _catalogMatchCache[normalizedInput] = result;
    return result;
  }

  // ── Helper Catalog Accessors ────────────────────────────────────────────────

  static List<Experience> _getAllCatalogItems() {
    // 1. Check live in-memory stream from CatalogController
    if (Get.isRegistered<CatalogController>()) {
      final catalogCtrl = Get.find<CatalogController>();
      if (catalogCtrl.rxExperiences.isNotEmpty) {
        return catalogCtrl.rxExperiences;
      }
    }

    // 2. Immediate fallback to canonical project seeds
    return ItemsSeed.decorationItems.map((map) {
      return Experience(
        id: map['id']?.toString() ?? '',
        categoryId: map['category_id']?.toString() ?? '',
        categoryName: map['category_name']?.toString() ?? '',
        categorySlug: map['category_slug']?.toString() ?? '',
        categoryIds: (map['category_ids'] as List?)?.cast<String>() ?? [],
        name: map['name']?.toString() ?? '',
        slug: map['slug']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        offerPrice: (map['offer_price'] as num?)?.toDouble(),
        durationHours: (map['duration_hours'] as num?)?.toDouble() ?? 3.0,
        popularity: map['popularity'] as int? ?? 0,
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        reviewCount: map['review_count'] as int? ?? 0,
        availability: map['availability']?.toString() ?? 'available',
        tags: (map['tags'] as List?)?.cast<String>() ?? [],
        colors: (map['colors'] as List?)?.cast<String>() ?? [],
        themes: (map['themes'] as List?)?.cast<String>() ?? [],
        imageUrl: map['image_url']?.toString() ?? '',
        videoUrl: map['video_url']?.toString() ?? '',
        isFeatured: map['is_featured'] as bool? ?? false,
        isActive: map['is_active'] as bool? ?? true,
      );
    }).toList();
  }

  static List<Category> _getAllCatalogCategories() {
    // 1. Check live in-memory stream from CatalogController
    if (Get.isRegistered<CatalogController>()) {
      final catalogCtrl = Get.find<CatalogController>();
      if (catalogCtrl.rxCategories.isNotEmpty) {
        return catalogCtrl.rxCategories;
      }
    }

    // 2. Immediate fallback to canonical project seeds
    return CategorySeed.categories.map((map) {
      return Category(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        slug: map['slug']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        icon: map['icon']?.toString() ?? '✦',
        color: map['color']?.toString() ?? '#c79b61',
        imageUrl: map['image_url']?.toString() ?? '',
        sortOrder: map['sort_order'] as int? ?? 0,
        isActive: map['is_active'] as bool? ?? true,
      );
    }).toList();
  }

  static Experience? _findItemById(String id) {
    final items = _getAllCatalogItems();
    for (final it in items) {
      if (it.id.toLowerCase() == id.toLowerCase()) return it;
    }
    return null;
  }

  static Experience? _findItemBySlug(String slug) {
    final items = _getAllCatalogItems();
    for (final it in items) {
      if (it.slug.toLowerCase() == slug.toLowerCase()) return it;
    }
    return null;
  }

  static Category? _findCategoryById(String id) {
    final cats = _getAllCatalogCategories();
    for (final c in cats) {
      if (c.id.toLowerCase() == id.toLowerCase() || c.slug.toLowerCase() == id.toLowerCase()) {
        return c;
      }
    }
    return null;
  }

  static Category? _findCategoryBySlug(String slug) {
    final cats = _getAllCatalogCategories();
    for (final c in cats) {
      if (c.slug.toLowerCase() == slug.toLowerCase()) return c;
    }
    return null;
  }

  // ── Matching & Scoring Logic ────────────────────────────────────────────────

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('poojan', 'pujan')
        .replaceAll('puja', 'pujan')
        .replaceAll('shaadi', 'wedding')
        .replaceAll('shadi', 'wedding')
        .replaceAll('vivah', 'wedding')
        .trim();
  }

  static Set<String> _extractKeywords(String normalized) {
    const stopWords = {
      'service',
      'services',
      'decoration',
      'decorations',
      'decor',
      'celebration',
      'celebrations',
      'event',
      'events',
      'setup',
      'setups',
      'package',
      'packages',
      'party',
      'parties',
      'and',
      'or',
      'for',
      'with',
      'the',
      'a',
      'an',
    };

    return normalized
        .split(' ')
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toSet();
  }

  static int _calculateScore(String queryNormalized, Experience item) {
    final itemNameNorm = _normalize(item.name);
    final itemSlugNorm = _normalize(item.slug);
    final catNameNorm = _normalize(item.categoryName);
    final catSlugNorm = _normalize(item.categorySlug);

    // Exact name match
    if (queryNormalized == itemNameNorm) return 100;
    // Exact slug match
    if (queryNormalized == itemSlugNorm) return 95;

    final queryKeywords = _extractKeywords(queryNormalized);
    if (queryKeywords.isEmpty) return 0;

    int score = 0;
    int matchedKeywords = 0;

    for (final kw in queryKeywords) {
      bool matchedInItem = false;

      if (itemNameNorm.contains(kw)) {
        score += 35;
        matchedInItem = true;
      } else if (itemSlugNorm.contains(kw)) {
        score += 25;
        matchedInItem = true;
      } else if (catNameNorm.contains(kw) || catSlugNorm.contains(kw)) {
        score += 20;
        matchedInItem = true;
      } else if (item.tags.any((t) => _normalize(t).contains(kw))) {
        score += 15;
        matchedInItem = true;
      } else if (item.themes.any((th) => _normalize(th).contains(kw))) {
        score += 10;
        matchedInItem = true;
      }

      if (matchedInItem) matchedKeywords++;
    }

    // Boost score if all significant keywords were matched
    if (matchedKeywords == queryKeywords.length && queryKeywords.isNotEmpty) {
      score += 30;
    }

    return score;
  }

  static int _calculateCategoryScore(String queryNormalized, Category cat) {
    final catNameNorm = _normalize(cat.name);
    final catSlugNorm = _normalize(cat.slug);

    if (queryNormalized == catNameNorm) return 100;
    if (queryNormalized == catSlugNorm) return 95;

    final queryKeywords = _extractKeywords(queryNormalized);
    if (queryKeywords.isEmpty) return 0;

    int score = 0;
    int matchedKeywords = 0;

    for (final kw in queryKeywords) {
      if (catNameNorm.contains(kw)) {
        score += 30;
        matchedKeywords++;
      } else if (catSlugNorm.contains(kw)) {
        score += 25;
        matchedKeywords++;
      }
    }

    if (matchedKeywords == queryKeywords.length && queryKeywords.isNotEmpty) {
      score += 25;
    }

    return score;
  }

  static bool _isValidImageUrl(String url) {
    final trimmed = url.trim();
    return trimmed.startsWith('assets/') ||
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://');
  }
}
