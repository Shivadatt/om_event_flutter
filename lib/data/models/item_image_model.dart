class ItemImageModel {
  final String id;
  final String decorationItemId;
  final String url;
  final String altText;
  final int sortOrder;
  final DateTime createdAt;

  ItemImageModel({
    required this.id,
    required this.decorationItemId,
    required this.url,
    required this.altText,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json, String id) {
    return ItemImageModel(
      id: id,
      decorationItemId: json['decorationItemId'] ?? '',
      url: json['url'] ?? '',
      altText: json['altText'] ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decorationItemId': decorationItemId,
      'url': url,
      'altText': altText,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
