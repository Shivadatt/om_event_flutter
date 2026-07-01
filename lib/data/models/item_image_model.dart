import '../../core/utils/date_parser.dart';

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
      decorationItemId:
          json['decoration_item_id'] ?? json['decorationItemId'] ?? '',
      url: json['url'] ?? '',
      altText: json['alt_text'] ?? json['altText'] ?? '',
      sortOrder: (json['sort_order'] ?? json['sortOrder']) as int? ?? 0,
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decoration_item_id': decorationItemId,
      'url': url,
      'alt_text': altText,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
