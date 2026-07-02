class BookingGallery {
  final String id;
  final String customerId;
  final String bookingId;
  final List<String> mediaUrls;
  final DateTime createdAt;

  const BookingGallery({
    required this.id,
    required this.customerId,
    required this.bookingId,
    required this.mediaUrls,
    required this.createdAt,
  });
}
