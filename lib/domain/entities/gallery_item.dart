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
  final bool isFeatured;
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
    this.isFeatured = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get effectiveThumbnail => thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  GalleryItem copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    String? serviceId,
    String? serviceName,
    List<String>? tags,
    bool? isActive,
    bool? isFeatured,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GalleryItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

    final rawSort = json['sort_order'] ?? json['sortOrder'] ?? json['popularity'] ?? json['display_order'] ?? json['displayOrder'] ?? 0;
    final int parsedSort = rawSort is int ? rawSort : (int.tryParse(rawSort.toString()) ?? 0);

    return GalleryItem(
      id: docId,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      categoryName: json['category_name'] ?? json['categoryName'] ?? '',
      serviceId: json['service_id'] ?? json['serviceId'] ?? '',
      serviceName: json['service_name'] ?? json['serviceName'] ?? json['name'] ?? '',
      tags: parsedTags,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      sortOrder: parsedSort,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'name': title,
      'description': description,
      'category_id': categoryId,
      'categoryId': categoryId,
      'category_name': categoryName,
      'categoryName': categoryName,
      'service_id': serviceId,
      'serviceName': serviceName,
      'tags': tags,
      'is_active': isActive,
      'isActive': isActive,
      'is_featured': isFeatured,
      'isFeatured': isFeatured,
      'sort_order': sortOrder,
      'sortOrder': sortOrder,
      'popularity': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
