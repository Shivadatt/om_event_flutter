class Category {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final String color;
  final String imageUrl;
  final int sortOrder;
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.color,
    required this.imageUrl,
    required this.sortOrder,
    this.itemCount = 0,
  });
}
