import '../../domain/entities/quotation_version.dart';
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
      quantity: json['quantity'] as int? ?? 1,
      unitPrice:
          (json['unit_price'] ?? json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] ?? 'As shown',
      theme: json['theme'] ?? 'As shown',
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
  final List<String> legacyVersionHistory;

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
    required super.customerId,
    super.versions = const [],
    this.legacyVersionHistory = const [],
    super.version = 1,
    super.publishedAt,
    super.publishedBy,
    super.revisionReason,
    super.revisionMessage,
    super.adminMessage,
    super.customerAction,
    super.customerActionAt,
    super.customerViewedAt,
    super.lastPublishedAt,
    super.internalNotes,
    super.isFinancialLocked = false,
    super.isPermanentlyLocked = false,
    super.operationalNotes,
    super.bookingDetails,
    super.staffAssignment,
    super.logistics,
    super.acceptedAt,
    super.acceptedVersion,
    super.acceptedAmount,
    super.acceptedBy,
    super.acceptedDevice,
    super.acceptedIp,
    super.consentTextVersion,
    super.sentReminders = const [],
  });

  factory QuotationModel.fromJson(
    Map<String, dynamic> json,
    String documentId, {
    List<QuotationVersion> versions = const [],
  }) {
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
      status: QuotationStatus.fromString(json['status'] ?? 'draft'),
      items: itemsList,
      createdAt: DateParser.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateParser.parse(json['updated_at'] ?? json['updatedAt']),
      customerId: json['customerId'] ?? json['customer_id'] ?? 'unmigrated_legacy_id',
      versions: versions,
      legacyVersionHistory: List<String>.from(json['versionHistory'] ?? json['version_history'] ?? []),
      version: json['version'] ?? 1,
      publishedAt: json['publishedAt'] != null ? DateParser.parse(json['publishedAt']) : null,
      publishedBy: json['publishedBy'],
      revisionReason: json['revisionReason'],
      revisionMessage: json['revisionMessage'],
      adminMessage: json['adminMessage'],
      customerAction: json['customerAction'],
      customerActionAt: json['customerActionAt'] != null ? DateParser.parse(json['customerActionAt']) : null,
      customerViewedAt: json['customerViewedAt'] != null ? DateParser.parse(json['customerViewedAt']) : null,
      lastPublishedAt: json['lastPublishedAt'] != null ? DateParser.parse(json['lastPublishedAt']) : null,
      internalNotes: json['internalNotes'] ?? json['internal_notes'],
      isFinancialLocked: json['isFinancialLocked'] ?? json['is_financial_locked'] ?? false,
      isPermanentlyLocked: json['isPermanentlyLocked'] ?? json['is_permanently_locked'] ?? false,
      operationalNotes: json['operationalNotes'] ?? json['operational_notes'],
      bookingDetails: json['bookingDetails'] ?? json['booking_details'],
      staffAssignment: json['staffAssignment'] ?? json['staff_assignment'],
      logistics: json['logistics'] ?? json['logistics'],
      acceptedAt: json['acceptedAt'] != null ? DateParser.parse(json['acceptedAt']) : null,
      acceptedVersion: json['acceptedVersion'] as int?,
      acceptedAmount: (json['acceptedAmount'] as num?)?.toDouble(),
      acceptedBy: json['acceptedBy'],
      acceptedDevice: json['acceptedDevice'],
      acceptedIp: json['acceptedIp'],
      consentTextVersion: json['consentTextVersion'],
      sentReminders: List<String>.from(json['sentReminders'] ?? json['sent_reminders'] ?? []),
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
      'status': status.nameStr,
      'items': items.map((e) {
        if (e is QuotationItemModel) {
          return e.toJson();
        } else {
          return QuotationItemModel(
            experienceId: e.experienceId,
            name: e.name,
            quantity: e.quantity,
            unitPrice: e.unitPrice,
            color: e.color,
            theme: e.theme,
            notes: e.notes,
          ).toJson();
        }
      }).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customerId': customerId,
      'versionHistory': legacyVersionHistory,
      'version': version,
      'publishedAt': publishedAt?.toIso8601String(),
      'publishedBy': publishedBy,
      'revisionReason': revisionReason,
      'revisionMessage': revisionMessage,
      'adminMessage': adminMessage,
      'customerAction': customerAction,
      'customerActionAt': customerActionAt?.toIso8601String(),
      'customerViewedAt': customerViewedAt?.toIso8601String(),
      'lastPublishedAt': lastPublishedAt?.toIso8601String(),
      'internalNotes': internalNotes,
      'isFinancialLocked': isFinancialLocked,
      'isPermanentlyLocked': isPermanentlyLocked,
      'operationalNotes': operationalNotes,
      'bookingDetails': bookingDetails,
      'staffAssignment': staffAssignment,
      'logistics': logistics,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'acceptedVersion': acceptedVersion,
      'acceptedAmount': acceptedAmount,
      'acceptedBy': acceptedBy,
      'acceptedDevice': acceptedDevice,
      'acceptedIp': acceptedIp,
      'consentTextVersion': consentTextVersion,
      'sentReminders': sentReminders,
    };
  }
}
