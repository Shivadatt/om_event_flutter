class BookingTimeline {
  final String id;
  final String bookingId;
  final String status;
  final DateTime updatedTime;
  final String notes;

  const BookingTimeline({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.updatedTime,
    this.notes = '',
  });
}
