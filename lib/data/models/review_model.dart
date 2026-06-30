import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.customerName,
    required super.eventName,
    required super.rating,
    required super.comment,
    required super.imageUrl,
    required super.isVerified,
    required super.isPublished,
    super.experienceId,
    required super.createdAt,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      if (value.runtimeType.toString().contains('Timestamp')) {
        return value.toDate();
      }
    } catch (_) {}
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ReviewModel(
      id: documentId,
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      eventName: json['event_name'] ?? json['eventName'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isPublished: json['is_published'] ?? json['isPublished'] ?? false,
      experienceId: json['experience_id'] ?? json['experienceId'],
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'event_name': eventName,
      'rating': rating,
      'comment': comment,
      'image_url': imageUrl,
      'is_verified': isVerified,
      'is_published': isPublished,
      'experience_id': experienceId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
