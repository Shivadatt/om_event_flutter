import '../../core/utils/date_parser.dart';
import '../../domain/entities/quotation.dart';

class QuotationItemModel extends QuotationItem {
  const QuotationItemModel({
    required super.experienceId,
    required super.name,
    required super.quantity,
    required super.unitPrice,
    required super.color,
    required super.theme,
    required super.notes,
  });

  factory QuotationItemModel.fromJson(Map<String, dynamic> json) {
    return QuotationItemModel(
      experienceId:
          json['decoration_item_slug'] ??
          json['experience_id'] ??
          json['experienceId'] ??
          '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice:
          (json['unit_price'] ?? json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] ?? '',
      theme: json['theme'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decoration_item_slug': experienceId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'color': color,
      'theme': theme,
      'notes': notes,
    };
  }
}

class QuotationModel extends Quotation {
  const QuotationModel({
    required super.id,
    required super.publicId,
    required super.customerPhone,
    required super.customerName,
    required super.eventDate,
    required super.eventTime,
    required super.location,
    required super.notes,
    required super.subtotal,
    required super.discount,
    required super.deliveryCharge,
    required super.travelCharge,
    required super.gstPercent,
    required super.gstAmount,
    required super.grandTotal,
    required super.pdfUrl,
    required super.status,
    required List<QuotationItemModel> super.items,
    required super.createdAt,
    required super.updatedAt,
  });

  factory QuotationModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList =
        rawItems
            .map(
              (e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();

    return QuotationModel(
      id: documentId,
      publicId: json['public_id'] ?? json['publicId'] ?? '',
      customerPhone: json['customer_phone'] ?? json['customerPhone'] ?? '',
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      eventDate: DateParser.parse(json['event_date'] ?? json['eventDate']),
      eventTime: json['event_time'] ?? json['eventTime'] ?? '18:00',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge:
          (json['delivery_charge'] ?? json['deliveryCharge'] as num?)
              ?.toDouble() ??
          0.0,
      travelCharge:
          (json['travel_charge'] ?? json['travelCharge'] as num?)?.toDouble() ??
          0.0,
      gstPercent:
          (json['gst_percent'] ?? json['gstPercent'] as num?)?.toDouble() ??
          18.0,
      gstAmount:
          (json['gst_amount'] ?? json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      grandTotal:
          (json['grand_total'] ?? json['grandTotal'] as num?)?.toDouble() ??
          0.0,
      pdfUrl: json['pdf_url'] ?? json['pdfUrl'] ?? '',
      status: json['status'] ?? 'draft',
      items: itemsList,
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateParser.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'customer_phone': customerPhone,
      'customer_name': customerName,
      'event_date': eventDate.toIso8601String(),
      'event_time': eventTime,
      'location': location,
      'notes': notes,
      'subtotal': subtotal,
      'discount': discount,
      'delivery_charge': deliveryCharge,
      'travel_charge': travelCharge,
      'gst_percent': gstPercent,
      'gst_amount': gstAmount,
      'grand_total': grandTotal,
      'pdf_url': pdfUrl,
      'status': status,
      'items': items.map((e) => (e as QuotationItemModel).toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
