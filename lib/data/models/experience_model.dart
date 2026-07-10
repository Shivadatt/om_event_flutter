import '../../domain/entities/experience.dart';

class ExperienceModel extends Experience {
  const ExperienceModel({
    required super.id,
    required super.categoryId,
    required super.categoryName,
    required super.categorySlug,
    super.categoryIds = const [],
    required super.name,
    required super.slug,
    required super.description,
    required super.price,
    super.offerPrice,
    required super.durationHours,
    required super.popularity,
    required super.rating,
    required super.reviewCount,
    required super.availability,
    required super.tags,
    required super.colors,
    required super.themes,
    required super.imageUrl,
    required super.videoUrl,
    required super.isFeatured,
    required super.isActive,
  });

  factory ExperienceModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    String catId = json['category_id'] ?? json['categoryId'] ?? '';
    String catName = json['category_name'] ?? json['categoryName'] ?? '';
    String catSlug =
        json['category_slug'] ??
        json['categorySlug'] ??
        json['category_id'] ??
        json['categoryId'] ??
        '';

    final categoryIdsRaw = json['category_ids'] ?? json['categoryIds'];
    final List<String> categoryIds = categoryIdsRaw != null
        ? List<String>.from(categoryIdsRaw)
        : (catId.isNotEmpty ? [catId] : []);

    double? parseDouble(dynamic val1, [dynamic val2]) {
      final val = val1 ?? val2;
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return ExperienceModel(
      id: documentId,
      categoryId: catId,
      categoryName: catName,
      categorySlug: catSlug,
      categoryIds: categoryIds,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: parseDouble(json['price']) ?? 0.0,
      offerPrice: parseDouble(json['offer_price'], json['offerPrice']),
      durationHours: parseDouble(json['duration_hours'], json['durationHours']) ?? 3.0,
      popularity: json['popularity'] ?? 0,
      rating: parseDouble(json['rating']) ?? 5.0,
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      availability: json['availability'] ?? 'available',
      tags: List<String>.from(json['tags'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      themes: List<String>.from(json['themes'] ?? []),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'category_slug': categorySlug,
      'category_ids': categoryIds,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'offer_price': offerPrice,
      'duration_hours': durationHours,
      'popularity': popularity,
      'rating': rating,
      'review_count': reviewCount,
      'availability': availability,
      'tags': tags,
      'colors': colors,
      'themes': themes,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_featured': isFeatured,
      'is_active': isActive,
    };
  }
}
