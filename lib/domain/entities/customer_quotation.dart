class CustomerQuotationItem {
  final String experienceId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String color;
  final String theme;
  final String notes;

  const CustomerQuotationItem({
    required this.experienceId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.color,
    required this.theme,
    required this.notes,
  });
}

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
  final List<CustomerQuotationItem> items;

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
    this.items = const [],
  });
}
