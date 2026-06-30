class Experience {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categorySlug;
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

  const Experience({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
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
  });

  double get effectivePrice => offerPrice != null ? offerPrice! : price;
}
