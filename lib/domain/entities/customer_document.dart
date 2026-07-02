class CustomerDocument {
  final String id;
  final String customerId;
  final String bookingId;
  final String name;
  final String url;
  final String type; // 'Invoice' | 'Quotation' | 'Receipt' | 'Agreement'
  final DateTime createdAt;

  const CustomerDocument({
    required this.id,
    required this.customerId,
    required this.bookingId,
    required this.name,
    required this.url,
    required this.type,
    required this.createdAt,
  });
}
