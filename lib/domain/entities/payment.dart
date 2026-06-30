class Payment {
  final String id;
  final String bookingId;
  final String provider; // 'razorpay' | 'cash' | 'upi'
  final String reference; // Razorpay payment ID
  final double amount;
  final String status; // 'pending' | 'captured' | 'failed'
  final DateTime? paidAt;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.provider,
    required this.reference,
    required this.amount,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });
}
