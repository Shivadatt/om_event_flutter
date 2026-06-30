class QuotationItem {
  final String experienceId;
  final String name;
  final int quantity;
  final double unitPrice;
  final String color;
  final String theme;
  final String notes;

  const QuotationItem({
    required this.experienceId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.color,
    required this.theme,
    required this.notes,
  });

  double get totalPrice => unitPrice * quantity;
}

class Quotation {
  final String id;
  final String publicId;
  final String customerPhone;
  final String customerName;
  final DateTime eventDate;
  final String eventTime; // e.g. "18:00"
  final String location;
  final String notes;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double travelCharge;
  final double gstPercent;
  final double gstAmount;
  final double grandTotal;
  final String pdfUrl;
  final String status; // 'draft' | 'pending' | 'accepted' | 'expired'
  final List<QuotationItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quotation({
    required this.id,
    required this.publicId,
    required this.customerPhone,
    required this.customerName,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.notes,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.travelCharge,
    required this.gstPercent,
    required this.gstAmount,
    required this.grandTotal,
    required this.pdfUrl,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });
}
