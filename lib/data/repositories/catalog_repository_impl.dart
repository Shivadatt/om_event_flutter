import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/firestore_remote_source.dart';
import '../models/category_model.dart';
import '../models/experience_model.dart';
import '../models/review_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final FirestoreRemoteSource remoteSource;
  CatalogRepositoryImpl(this.remoteSource);

  // In-Memory Fallbacks for offline / unconfigured demo mode
  static final List<Category> _fallbackCategories = [
    Category(
      id: 'birthday',
      name: 'Birthday Celebrations',
      slug: 'birthday',
      description: 'Joyful themes designed around their favorite things.',
      icon: '🎈',
      color: '#e58b9d',
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/categories/birthday.jpg',
      sortOrder: 0,
      isActive: true,
    ),
    Category(
      id: 'wedding',
      name: 'Wedding & Engagement',
      slug: 'wedding',
      description: 'Elegant stages and entrances for once-in-a-lifetime vows.',
      icon: '💍',
      color: '#c79b61',
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/categories/wedding.jpg',
      sortOrder: 1,
      isActive: true,
    ),
    Category(
      id: 'baby',
      name: 'Baby Celebrations',
      slug: 'baby',
      description: 'Soft, playful worlds for showers and welcome-home moments.',
      icon: '☁',
      color: '#75a9a6',
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/categories/baby.jpg',
      sortOrder: 2,
      isActive: true,
    ),
    Category(
      id: 'corporate',
      name: 'Corporate Events',
      slug: 'corporate',
      description: 'Polished launches, openings, and branded experiences.',
      icon: '✦',
      color: '#7c86bd',
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/categories/corporate.jpg',
      sortOrder: 3,
      isActive: true,
    ),
    Category(
      id: 'proposal',
      name: 'Surprise & Proposal',
      slug: 'proposal',
      description: 'Thoughtful romantic settings with a cinematic reveal.',
      icon: '♡',
      color: '#c96f64',
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/categories/proposal.jpg',
      sortOrder: 4,
      isActive: true,
    ),
    Category(
      id: 'entries',
      name: 'Grand Entries',
      slug: 'entries',
      description: 'Fog, flowers, cold fire, and choreography for impact.',
      icon: '⚡',
      color: '#a483c0',
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/categories/entries.jpg',
      sortOrder: 5,
      isActive: true,
    ),
  ];

  static final List<Experience> _fallbackExperiences = [
    Experience(
      id: 'pastel-dream-birthday',
      name: 'Pastel Dream Birthday',
      slug: 'pastel-dream-birthday',
      categoryId: 'birthday',
      categoryName: 'Birthday Celebrations',
      categorySlug: 'birthday',
      description: 'A layered pastel balloon wall, personalized neon, plinths and floral accents.',
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
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/photos/birthday-balloons.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'wild-one-safari',
      name: 'Wild One Safari',
      slug: 'wild-one-safari',
      categoryId: 'birthday',
      categoryName: 'Birthday Celebrations',
      categorySlug: 'birthday',
      description: 'Organic balloon styling, illustrated jungle panels, props and cake presentation.',
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
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/photos/birthday.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'ivory-vow-stage',
      name: 'Ivory Vow Stage',
      slug: 'ivory-vow-stage',
      categoryId: 'wedding',
      categoryName: 'Wedding & Engagement',
      categorySlug: 'wedding',
      description: 'An architectural ivory stage with warm lamps, layered florals and premium seating.',
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
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/photos/wedding-stage.jpg',
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
      description: 'Contemporary marigold geometry, brass accents and ambient candle styling.',
      price: 56000.0,
      offerPrice: 49900.0,
      durationHours: 3.0,
      popularity: 88,
      rating: 4.7,
      reviewCount: 15,
      availability: 'available',
      tags: ['wedding', 'premium', 'customizable'],
      colors: ['Marigold Orange', 'Sunshine Yellow', 'Creamy White'],
      themes: ['Traditional Heritage', 'Modern Geometric Floral', 'Rustic Brass'],
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/photos/mehndi.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
    Experience(
      id: 'little-cloud-welcome',
      name: 'Little Cloud Welcome',
      slug: 'little-cloud-welcome',
      categoryId: 'baby',
      categoryName: 'Baby Celebrations',
      categorySlug: 'baby',
      description: 'Cloud forms, soft blue balloons, warm lighting and a customized baby name sign.',
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
      imageUrl: 'https://raw.githubusercontent.com/omevents/assets/main/photos/welcomebaby.jpg',
      videoUrl: '',
      isFeatured: true,
      isActive: true,
    ),
  ];

  static final List<Review> _fallbackReviews = [
    Review(
      id: 'rev-1',
      customerName: 'Riya & Aakash',
      eventName: 'Engagement Styling',
      rating: 5,
      comment: 'They understood the mood instantly. Every corner felt intentional, and the quotation stayed completely transparent.',
      imageUrl: '',
      isVerified: true,
      isPublished: true,
      createdAt: DateTime.now(),
    ),
    Review(
      id: 'rev-2',
      customerName: 'Meera Patel',
      eventName: 'First Birthday Celebration',
      rating: 5,
      comment: 'Beautiful execution, calm team, zero last-minute chaos. The pastel setup looked even better in person.',
      imageUrl: '',
      isVerified: true,
      isPublished: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Category>> getCategories() async {
    try {
      // Try fetching from remote database
      await remoteSource.ensureSeeded();
      final docs = await remoteSource.fetchCategories();
      return docs.map((doc) => CategoryModel.fromJson(doc.data(), doc.id)).toList();
    } catch (_) {
      // Fallback to static lists in offline/demo mode
      return _fallbackCategories;
    }
  }

  @override
  Future<List<Experience>> getExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
  }) async {
    try {
      final docs = await remoteSource.fetchExperiences(
        categorySlug: categorySlug,
        searchQuery: searchQuery,
        themeFilter: themeFilter,
        featuredOnly: featuredOnly,
        sortBy: sortBy,
      );
      return docs.map((doc) => ExperienceModel.fromJson(doc.data(), doc.id)).toList();
    } catch (_) {
      // In-Memory search/filtering for unconfigured/offline environment
      var list = _fallbackExperiences;

      if (categorySlug != null && categorySlug.isNotEmpty) {
        list = list.where((e) => e.categorySlug == categorySlug).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        list = list.where((e) =>
            e.name.toLowerCase().contains(queryLower) ||
            e.description.toLowerCase().contains(queryLower) ||
            e.tags.any((t) => t.toLowerCase().contains(queryLower))).toList();
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
        // popular
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
      }

      return list;
    }
  }

  @override
  Future<Experience> getExperienceDetail(String slug) async {
    try {
      final doc = await remoteSource.fetchExperienceDetail(slug);
      return ExperienceModel.fromJson(doc.data()!, doc.id);
    } catch (_) {
      final match = _fallbackExperiences.firstWhere((e) => e.slug == slug);
      return match;
    }
  }

  @override
  Future<List<Review>> getPublishedReviews() async {
    try {
      final docs = await remoteSource.fetchPublishedReviews();
      return docs.map((doc) => ReviewModel.fromJson(doc.data(), doc.id)).toList();
    } catch (_) {
      return _fallbackReviews;
    }
  }

  @override
  Future<void> createCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      icon: category.icon,
      color: category.color,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      itemCount: category.itemCount,
      isActive: category.isActive,
    );
    await remoteSource.createCategory(model.toJson());
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      icon: category.icon,
      color: category.color,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      itemCount: category.itemCount,
      isActive: category.isActive,
    );
    await remoteSource.updateCategory(category.slug, model.toJson());
  }

  @override
  Future<void> deleteCategory(String slug) async {
    await remoteSource.deleteCategory(slug);
  }

  @override
  Future<void> createExperience(Experience experience) async {
    final model = ExperienceModel(
      id: experience.id,
      categoryId: experience.categoryId,
      categoryName: experience.categoryName,
      categorySlug: experience.categorySlug,
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

  @override
  Future<void> updateExperience(Experience experience) async {
    final model = ExperienceModel(
      id: experience.id,
      categoryId: experience.categoryId,
      categoryName: experience.categoryName,
      categorySlug: experience.categorySlug,
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

  @override
  Future<void> deleteExperience(String slug) async {
    await remoteSource.deleteExperience(slug);
  }
}
