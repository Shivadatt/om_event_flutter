import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.description,
    required super.icon,
    required super.color,
    required super.imageUrl,
    required super.sortOrder,
    super.itemCount,
    required super.isActive,
  });

  static String sanitizeImageUrl(String slug, String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('assets/images/')) {
      final fileName = url.split('/').last;
      return 'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/thumbnails/images/$fileName';
    }

    if (url.startsWith('http')) {
      if (url.contains('/gallery/images/')) {
        return url.replaceAll('/gallery/images/', '/thumbnails/images/');
      }
      return url;
    }

    return url;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json, String documentId) {
    final slug = json['slug'] ?? documentId;
    final rawUrl = json['image_url'] ?? json['imageUrl'] ?? '';
    return CategoryModel(
      id: documentId,
      name: json['name'] ?? '',
      slug: slug,
      description: json['description'] ?? '',
      icon: json['icon'] ?? '✦',
      color: json['color'] ?? '#c79b61',
      imageUrl: sanitizeImageUrl(slug, rawUrl),
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
      itemCount: json['item_count'] ?? json['itemCount'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'color': color,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'item_count': itemCount,
      'is_active': isActive,
    };
  }
}
