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
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String documentId) {
    return CategoryModel(
      id: documentId,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '✦',
      color: json['color'] ?? '#c79b61',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
      itemCount: json['item_count'] ?? json['itemCount'] ?? 0,
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
    };
  }
}
