import '../../../domain/entities/experience.dart';
import '../../datasources/firestore_remote_source.dart';
import '../../models/experience_model.dart';

/// Mixin responsibility to handle experiences/decoration items catalog domain.
mixin ItemRepositoryMixin {
  /// Remote database data source.
  FirestoreRemoteSource get remoteSource;

  static final List<Experience> _fallbackExperiences = [
    Experience(
      id: 'pastel-dream-birthday',
      name: 'Baby Shower/Srimant Sanskar',
      slug: 'pastel-dream-birthday',
      categoryId: 'baby',
      categoryName: 'Baby Celebrations',
      categorySlug: 'baby',
      description:
          'A layered pastel balloon wall, personalized neon, plinths and floral accents.',
      price: 18500.0,
      offerPrice: 14900.0,
      durationHours: 3.0,
      popularity: 98,
      rating: 4.8,
      reviewCount: 14,
      availability: 'available',
      tags: ['birthday', 'premium', 'customizable'],
      colors: ['Pastel Pink', 'Lavender Lilac', 'Mint Blue'],
      themes: ['Princess Sparkle', 'Minimalist Elegance', 'Rainbow Cloud'],
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/photos/birthday-balloons.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'wild-one-safari',
      name: 'Balloon Blast',
      slug: 'wild-one-safari',
      categoryId: 'birthday',
      categoryName: 'Birthday Celebrations',
      categorySlug: 'birthday',
      description:
          'Organic balloon styling, illustrated jungle panels, props and cake presentation.',
      price: 24000.0,
      offerPrice: 20900.0,
      durationHours: 3.0,
      popularity: 91,
      rating: 4.8,
      reviewCount: 18,
      availability: 'available',
      tags: ['birthday', 'premium', 'customizable'],
      colors: ['Sage Green', 'Chrome Gold', 'Chocolate Brown'],
      themes: ['Jungle Safari', 'Jungle Animals', 'Nature Backdrop'],
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/photos/birthday.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'ivory-vow-stage',
      name: 'Chhathi Pujan',
      slug: 'ivory-vow-stage',
      categoryId: 'baby',
      categoryName: 'Baby Celebrations',
      categorySlug: 'baby',
      description:
          'An architectural ivory stage with warm lamps, layered florals and premium seating.',
      price: 78000.0,
      offerPrice: 69900.0,
      durationHours: 4.5,
      popularity: 96,
      rating: 4.9,
      reviewCount: 23,
      availability: 'available',
      tags: ['wedding', 'premium', 'customizable'],
      colors: ['Classic Ivory', 'Champagne Gold', 'Blush Pink'],
      themes: ['Royal Palace', 'Floral Enchantment', 'Modern Classic'],
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/photos/wedding-stage.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'saffron-ring-ceremony',
      name: 'Saffron Ring Ceremony',
      slug: 'saffron-ring-ceremony',
      categoryId: 'wedding',
      categoryName: 'Wedding & Engagement',
      categorySlug: 'wedding',
      description:
          'Contemporary marigold geometry, brass accents and ambient candle styling.',
      price: 56000.0,
      offerPrice: 49900.0,
      durationHours: 3.0,
      popularity: 88,
      rating: 4.7,
      reviewCount: 15,
      availability: 'available',
      tags: ['wedding', 'premium', 'customizable'],
      colors: ['Marigold Orange', 'Sunshine Yellow', 'Creamy White'],
      themes: [
        'Traditional Heritage',
        'Modern Geometric Floral',
        'Rustic Brass',
      ],
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/photos/mehndi.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'little-cloud-welcome',
      name: 'vana rasam (Gujarati Wedding Ritual)',
      slug: 'little-cloud-welcome',
      categoryId: 'wedding',
      categoryName: 'Wedding & Engagement',
      categorySlug: 'wedding',
      description:
          'Cloud forms, soft blue balloons, warm lighting and a customized baby name sign.',
      price: 22000.0,
      offerPrice: 18500.0,
      durationHours: 3.0,
      popularity: 93,
      rating: 4.8,
      reviewCount: 20,
      availability: 'available',
      tags: ['baby', 'premium', 'customizable'],
      colors: ['Sky Blue', 'Pure White', 'Metallic Silver'],
      themes: ['Heavenly Clouds', 'Cuddly Teddy Bear', 'Minimal Pastel'],
      imageUrl:
          'https://raw.githubusercontent.com/omevents/assets/main/photos/welcomebaby.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
  ];

  /// Get fallback experiences.
  List<Experience> get fallbackExperiences => _fallbackExperiences;

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
      var list = List<Experience>.from(_fallbackExperiences);

      if (categorySlug != null && categorySlug.isNotEmpty) {
        list = list.where((e) => e.categorySlug == categorySlug).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        list =
            list
                .where(
                  (e) =>
                      e.name.toLowerCase().contains(queryLower) ||
                      e.description.toLowerCase().contains(queryLower) ||
                      e.tags.any((t) => t.toLowerCase().contains(queryLower)),
                )
                .toList();
      }

      if (featuredOnly == true) {
        list = list.where((e) => e.isFeatured).toList();
      }

      // Sort
      if (sortBy == 'price_low') {
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
      } else if (sortBy == 'price_high') {
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
      } else if (sortBy == 'latest') {
        // Mock latest ordering
      } else {
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
      }

      return list;
    }
  }

  /// Retrieve experience detail by its unique slug.
  Future<Experience> getExperienceDetail(String slug) async {
    try {
      final doc = await remoteSource.fetchExperienceDetail(slug);
      return ExperienceModel.fromJson(doc.data()!, doc.id);
    } catch (_) {
      return _fallbackExperiences.firstWhere((e) => e.slug == slug);
    }
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
