import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../models/category_model.dart';
import '../models/experience_model.dart';

/// Repository implementing catalog services and categories CRUD operations on Supabase.
class SupabaseServiceRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Service Categories ───────────────────────────────────────────────────

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

  Future<void> saveCategory(Category category) async {
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

    await _client.from('categories').upsert(payload);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // ── Services (Decoration experiences) ────────────────────────────────────

  Future<List<Experience>> getServices() async {
    final response = await _client
        .from('experiences')
        .select()
        .eq('is_active', true);

    return response
        .map((row) => ExperienceModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<void> saveService(Experience experience) async {
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

    await _client.from('experiences').upsert(payload);
  }

  Future<void> deleteService(String id) async {
    await _client.from('experiences').delete().eq('id', id);
  }
}
