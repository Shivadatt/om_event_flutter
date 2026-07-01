class Booking {
  final String id;
  final String bookingNumber;
  final String quotationId;
  final double advanceAmount;
  final String paymentStatus; // 'pending' | 'partially_paid' | 'paid'
  final String
  status; // 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.quotationId,
    required this.advanceAmount,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
