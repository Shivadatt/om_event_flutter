class GalleryItem {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final String serviceId;
  final String serviceName;
  final List<String> tags;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GalleryItem({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl = '',
    required this.title,
    this.description = '',
    this.categoryId = '',
    this.categoryName = '',
    this.serviceId = '',
    this.serviceName = '',
    this.tags = const [],
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get effectiveThumbnail => thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  factory GalleryItem.fromJson(Map<String, dynamic> json, String docId) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      try {
        final toDate = (val as dynamic).toDate();
        if (toDate is DateTime) return toDate;
      } catch (_) {}
      return DateTime.now();
    }

    final tagsRaw = json['tags'];
    final List<String> parsedTags = tagsRaw != null && tagsRaw is List
        ? List<String>.from(tagsRaw.map((e) => e.toString()))
        : [];

    return GalleryItem(
      id: docId,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      categoryName: json['category_name'] ?? json['categoryName'] ?? '',
      serviceId: json['service_id'] ?? json['serviceId'] ?? '',
      serviceName: json['service_name'] ?? json['serviceName'] ?? '',
      tags: parsedTags,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'service_id': serviceId,
      'service_name': serviceName,
      'tags': tags,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
