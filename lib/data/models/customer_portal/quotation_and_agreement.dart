import '../../../domain/entities/customer_quotation.dart';
import '../../../domain/entities/booking_agreement.dart';
import '../../../core/utils/date_parser.dart';

class CustomerQuotationItemModel extends CustomerQuotationItem {
  const CustomerQuotationItemModel({
    required super.experienceId,
    required super.name,
    required super.quantity,
    required super.unitPrice,
    required super.color,
    required super.theme,
    required super.notes,
  });

  factory CustomerQuotationItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerQuotationItemModel(
      experienceId: json['experienceId'] ?? json['decoration_item_slug'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice:
          (json['unitPrice'] ?? json['unit_price'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] ?? '',
      theme: json['theme'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'experienceId': experienceId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'color': color,
      'theme': theme,
      'notes': notes,
    };
  }
}

class CustomerQuotationModel extends CustomerQuotation {
  const CustomerQuotationModel({
    required super.id,
    required super.customerId,
    required super.quotationNumber,
    required super.date,
    required super.amount,
    required super.status,
    required super.expiryDate,
    required super.pdfUrl,
    super.notes,
    super.versionHistory,
    required List<CustomerQuotationItemModel> super.items,
  });

  factory CustomerQuotationModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map(
          (e) => CustomerQuotationItemModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();

    return CustomerQuotationModel(
      id: id,
      customerId: json['customerId'] ?? '',
      quotationNumber: json['quotationNumber'] ?? '',
      date: DateParser.parse(json['date']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      expiryDate: DateParser.parse(json['expiryDate']),
      pdfUrl: json['pdfUrl'] ?? '',
      notes: json['notes'] ?? '',
      versionHistory: List<String>.from(json['versionHistory'] ?? []),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'quotationNumber': quotationNumber,
      'date': date.toIso8601String(),
      'amount': amount,
      'status': status,
      'expiryDate': expiryDate.toIso8601String(),
      'pdfUrl': pdfUrl,
      'notes': notes,
      'versionHistory': versionHistory,
      'items':
          items.map((e) => (e as CustomerQuotationItemModel).toJson()).toList(),
    };
  }
}

class BookingAgreementModel extends BookingAgreement {
  const BookingAgreementModel({
    required super.id,
    required super.bookingId,
    required super.terms,
    required super.digitalSignature,
    required super.accepted,
  });

  factory BookingAgreementModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return BookingAgreementModel(
      id: id,
      bookingId: json['bookingId'] ?? '',
      terms: json['terms'] ?? '',
      digitalSignature: json['digitalSignature'] ?? '',
      accepted: json['accepted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'terms': terms,
      'digitalSignature': digitalSignature,
      'accepted': accepted,
    };
  }
}
