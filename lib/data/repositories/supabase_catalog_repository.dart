import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/category_model.dart';
import '../models/experience_model.dart';
import '../models/review_model.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Categories One-Shot Reads
  // ---------------------------------------------------------------------------

  @override
  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return response
        .map((row) => CategoryModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);

    return response
        .map((row) => CategoryModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  @override
  Future<void> toggleCategoryStatus(String slug, {required bool isActive}) async {
    await _client
        .from('categories')
        .update({'is_active': isActive})
        .eq('slug', slug);
  }

  // ---------------------------------------------------------------------------
  // Experiences (Decoration Items) One-Shot Reads
  // ---------------------------------------------------------------------------

  @override
  Future<List<Experience>> getExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
    bool? activeOnly,
  }) async {
    var query = _client.from('experiences').select();

    if (activeOnly != false) {
      query = query.eq('is_active', true);
    }
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query = query.eq('category_slug', categorySlug);
    }
    if (featuredOnly == true) {
      query = query.eq('is_featured', true);
    }

    final response = await query;
    var list = response
        .map((row) => ExperienceModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();

    // In-memory filters matching legacy FirestoreRemoteSource behavior
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      list = list.where((e) {
        return e.name.toLowerCase().contains(queryLower) ||
            e.description.toLowerCase().contains(queryLower) ||
            e.tags.any((t) => t.toLowerCase().contains(queryLower));
      }).toList();
    }

    if (themeFilter != null && themeFilter.isNotEmpty) {
      final themeLower = themeFilter.toLowerCase();
      list = list.where((e) {
        return e.themes.any((t) => t.toLowerCase() == themeLower);
      }).toList();
    }

    // In-memory sorting matching legacy behavior
    if (sortBy == 'price_low') {
      list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
    } else if (sortBy == 'price_high') {
      list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
    } else if (sortBy == 'latest') {
      // Supabase has created_at field
    } else {
      list.sort((a, b) => b.popularity.compareTo(a.popularity));
    }

    return list;
  }

  @override
  Future<Experience> getExperienceDetail(String slug) async {
    final response = await _client
        .from('experiences')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    if (response == null) {
      throw Exception('Experience details not found.');
    }

    // Increment popularity trigger in background
    unawaited(_client.rpc('increment_experience_popularity', params: {'exp_slug': slug}).catchError((_) {}));

    return ExperienceModel.fromJson(SupabaseMapper.toCamelCase(response), response['id'] ?? '');
  }

  // ---------------------------------------------------------------------------
  // Reviews One-Shot Reads
  // ---------------------------------------------------------------------------

  @override
  Future<List<Review>> getPublishedReviews() async {
    // Limits to 12 as per legacy fetchPublishedReviews
    final response = await _client
        .from('reviews')
        .select()
        .eq('is_published', true)
        .eq('is_active', true)
        .order('is_featured', ascending: false)
        .order('display_order', ascending: true)
        .order('created_at', ascending: false)
        .limit(12);

    return response
        .map((row) => ReviewModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Realtime Streams
  // ---------------------------------------------------------------------------

  @override
  Stream<List<Category>> streamCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .map((rows) => rows
            .map((row) => CategoryModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  @override
  Stream<List<Category>> streamAllCategories() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .order('sort_order', ascending: true)
        .map((rows) => rows
            .map((row) => CategoryModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  @override
  Stream<List<Experience>> streamAllActiveExperiences() {
    return _client
        .from('experiences')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .map((rows) => rows
            .map((row) => ExperienceModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  @override
  Stream<List<Review>> streamPublishedReviews() {
    return _client
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('is_published', true)
        .map((rows) {
          final list = rows
              .where((row) => row['is_active'] == true || row['isActive'] == true)
              .map((row) => ReviewModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
              .toList();

          // Apply complex featured & display order sorting in-memory
          list.sort((a, b) {
            if (a.isFeatured != b.isFeatured) return b.isFeatured ? 1 : -1;
            if (a.displayOrder != b.displayOrder) return a.displayOrder.compareTo(b.displayOrder);
            return b.createdAt.compareTo(a.createdAt);
          });
          return list;
        });
  }

  // ---------------------------------------------------------------------------
  // Admin CRUD
  // ---------------------------------------------------------------------------

  @override
  Future<void> createCategory(Category category) async {
    final payload = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      icon: category.icon,
      color: category.color,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    ).toJson();

    await _client.from('categories').insert(payload);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final payload = CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      icon: category.icon,
      color: category.color,
      imageUrl: category.imageUrl,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    ).toJson();

    await _client.from('categories').update(payload).eq('id', category.id);
  }

  @override
  Future<void> deleteCategory(String slug) async {
    await _client.from('categories').delete().eq('slug', slug);
  }

  @override
  Future<void> createExperience(Experience experience) async {
    final payload = ExperienceModel(
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
    ).toJson();

    await _client.from('experiences').insert(payload);
  }

  @override
  Future<void> updateExperience(Experience experience) async {
    final payload = ExperienceModel(
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
    ).toJson();

    await _client.from('experiences').update(payload).eq('id', experience.id);
  }

  @override
  Future<void> deleteExperience(String slug) async {
    await _client.from('experiences').delete().eq('slug', slug);
  }
}
