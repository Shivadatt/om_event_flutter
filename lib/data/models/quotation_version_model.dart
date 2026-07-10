import '../../domain/entities/quotation_version.dart';
import 'quotation_model.dart';

class QuotationVersionModel extends QuotationVersion {
  const QuotationVersionModel({
    required super.id,
    required super.quotationId,
    required super.versionNumber,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.gstPercent,
    required super.gstAmount,
    required super.deliveryCharge,
    required super.travelCharge,
    required super.grandTotal,
    required super.adminMessage,
    required super.publishedAt,
    required super.publishedBy,
    required super.pdfUrl,
    super.revisionReason,
  });

  factory QuotationVersionModel.fromJson(Map<String, dynamic> json, String id) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return QuotationVersionModel(
      id: id,
      quotationId: json['quotationId'] ?? json['quotation_id'] ?? '',
      versionNumber: json['versionNumber'] ?? json['version_number'] ?? 1,
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      gstPercent: (json['gstPercent'] ?? json['gst_percent'] as num?)?.toDouble() ?? 18.0,
      gstAmount: (json['gstAmount'] ?? json['gst_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] ?? json['delivery_charge'] ?? json['delivery'] as num?)?.toDouble() ?? 0.0,
      travelCharge: (json['travelCharge'] ?? json['travel_charge'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] ?? json['grand_total'] as num?)?.toDouble() ?? 0.0,
      adminMessage: json['adminMessage'] ?? json['admin_message'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? json['published_at'] ?? '') ?? DateTime.now(),
      publishedBy: json['publishedBy'] ?? json['published_by'] ?? 'admin',
      pdfUrl: json['pdfUrl'] ?? json['pdf_url'] ?? '',
      revisionReason: json['revisionReason'] ?? json['revision_reason'] ?? json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationId': quotationId,
      'versionNumber': versionNumber,
      'items': items.map((e) => (e as QuotationItemModel).toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'gstPercent': gstPercent,
      'gstAmount': gstAmount,
      'deliveryCharge': deliveryCharge,
      'travelCharge': travelCharge,
      'grandTotal': grandTotal,
      'adminMessage': adminMessage,
      'publishedAt': publishedAt.toIso8601String(),
      'publishedBy': publishedBy,
      'pdfUrl': pdfUrl,
      'revisionReason': revisionReason,
    };
  }
}
