class CustomerPayment {
  final String id;
  final String customerId;
  final String bookingId;
  final double amount;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String method; // 'UPI' | 'Cash' | 'Card' | 'Bank Transfer'
  final String receiptUrl;
  final String invoiceUrl;
  final DateTime paymentDate;

  const CustomerPayment({
    required this.id,
    required this.customerId,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.method,
    required this.receiptUrl,
    required this.invoiceUrl,
    required this.paymentDate,
  });
}
