class Review {
  final String id;
  final String customerName;
  final String eventName;
  final int rating;
  final String comment;
  final String imageUrl;
  final bool isVerified;
  final bool isPublished;
  final String? experienceId;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.customerName,
    required this.eventName,
    required this.rating,
    required this.comment,
    required this.imageUrl,
    required this.isVerified,
    required this.isPublished,
    this.experienceId,
    required this.createdAt,
  });
}
