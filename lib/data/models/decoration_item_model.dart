import '../../domain/entities/decoration_item.dart';

class DecorationItemModel extends DecorationItem {
  const DecorationItemModel({
    required super.id,
    required super.categoryId,
    required super.categoryName,
    required super.categorySlug,
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
    required super.createdAt,
  });

  factory DecorationItemModel.fromJson(Map<String, dynamic> json, String documentId) {
    return DecorationItemModel(
      id: documentId,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categorySlug: json['categorySlug'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 3.0,
      popularity: json['popularity'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['reviewCount'] ?? 0,
      availability: json['availability'] ?? 'available',
      tags: List<String>.from(json['tags'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      themes: List<String>.from(json['themes'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categorySlug': categorySlug,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'offerPrice': offerPrice,
      'durationHours': durationHours,
      'popularity': popularity,
      'rating': rating,
      'reviewCount': reviewCount,
      'availability': availability,
      'tags': tags,
      'colors': colors,
      'themes': themes,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
