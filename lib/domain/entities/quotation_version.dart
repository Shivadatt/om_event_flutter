import 'quotation.dart';

class QuotationVersion {
  final String id;
  final String quotationId;
  final int versionNumber;
  final List<QuotationItem> items;
  final double subtotal;
  final double discount;
  final double gstPercent;
  final double gstAmount;
  final double deliveryCharge;
  final double travelCharge;
  final double grandTotal;
  final String? adminMessage;
  final DateTime publishedAt;
  final String publishedBy;
  final String pdfUrl;
  final String? revisionReason;

  const QuotationVersion({
    required this.id,
    required this.quotationId,
    required this.versionNumber,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.gstPercent,
    required this.gstAmount,
    required this.deliveryCharge,
    required this.travelCharge,
    required this.grandTotal,
    required this.adminMessage,
    required this.publishedAt,
    required this.publishedBy,
    required this.pdfUrl,
    this.revisionReason,
  });
}
