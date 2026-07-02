class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isActive;
  final int priority;
  final DateTime expiryDate;
  final String branch;

  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    required this.priority,
    required this.expiryDate,
    required this.branch,
  });
}
