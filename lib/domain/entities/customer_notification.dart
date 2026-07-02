class CustomerNotification {
  final String id;
  final String customerId;
  final String title;
  final String body;
  final String type; // 'Booking' | 'Quotation' | 'Payment' | 'Review' | 'Offer' | 'Reminder' | 'Announcement'
  final bool isRead;
  final String branch;
  final DateTime createdAt;

  const CustomerNotification({
    required this.id,
    required this.customerId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.branch = '',
    required this.createdAt,
  });
}
