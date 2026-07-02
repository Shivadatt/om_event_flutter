class CustomerQuotation {
  final String id;
  final String customerId;
  final String quotationNumber;
  final DateTime date;
  final double amount;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'expired' | 'revision_requested'
  final DateTime expiryDate;
  final String pdfUrl;
  final String notes;
  final List<String> versionHistory;

  const CustomerQuotation({
    required this.id,
    required this.customerId,
    required this.quotationNumber,
    required this.date,
    required this.amount,
    required this.status,
    required this.expiryDate,
    required this.pdfUrl,
    this.notes = '',
    this.versionHistory = const [],
  });
}
