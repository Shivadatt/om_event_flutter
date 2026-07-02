class CustomerActivity {
  final String id;
  final String customerId;
  final String status; // 'Registered' | 'Lead Created' | 'Quotation' | 'Booking' | 'Payment' | 'Gallery' | 'Review' | 'Completed'
  final DateTime updatedAt;
  final String details;

  const CustomerActivity({
    required this.id,
    required this.customerId,
    required this.status,
    required this.updatedAt,
    this.details = '',
  });
}
