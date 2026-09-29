import 'package_option.dart';

class Experience {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categorySlug;
  final List<String> categoryIds;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double? offerPrice;
  final double durationHours;
  final int popularity;
  final double rating;
  final int reviewCount;
  final String availability; // 'available' | 'unavailable' | 'booked'
  final List<String> tags;
  final List<String> colors;
  final List<String> themes;
  final String imageUrl;
  final String videoUrl;
  final bool isFeatured;
  final bool isActive;
  final List<PackageOption> packages;

  const Experience({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
    this.categoryIds = const [],
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.offerPrice,
    required this.durationHours,
    required this.popularity,
    required this.rating,
    required this.reviewCount,
    required this.availability,
    required this.tags,
    required this.colors,
    required this.themes,
    required this.imageUrl,
    required this.videoUrl,
    required this.isFeatured,
    required this.isActive,
    this.packages = const [],
  });

  double get effectivePrice => offerPrice != null ? offerPrice! : price;

  List<PackageOption> get dynamicPackages => packages.isNotEmpty
      ? packages
      : PackageOption.generateDefaults(
          serviceId: id,
          serviceName: name,
          basePrice: effectivePrice,
          baseDuration: durationHours,
        );

  Experience copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? categorySlug,
    List<String>? categoryIds,
    String? name,
    String? slug,
    String? description,
    double? price,
    double? offerPrice,
    double? durationHours,
    int? popularity,
    double? rating,
    int? reviewCount,
    String? availability,
    List<String>? tags,
    List<String>? colors,
    List<String>? themes,
    String? imageUrl,
    String? videoUrl,
    bool? isFeatured,
    bool? isActive,
    List<PackageOption>? packages,
  }) {
    return Experience(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categorySlug: categorySlug ?? this.categorySlug,
      categoryIds: categoryIds ?? this.categoryIds,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      durationHours: durationHours ?? this.durationHours,
      popularity: popularity ?? this.popularity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      availability: availability ?? this.availability,
      tags: tags ?? this.tags,
      colors: colors ?? this.colors,
      themes: themes ?? this.themes,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      packages: packages ?? this.packages,
    );
  }
}
