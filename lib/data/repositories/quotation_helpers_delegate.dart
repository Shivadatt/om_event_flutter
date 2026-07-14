import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/quotation_version.dart';
import '../models/quotation_version_model.dart';
import '../models/quotation_model.dart';

/// Delegate handling version migration, history, timeline logs, and system message posts.
class QuotationHelpersDelegate {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches revisions and maps legacy histories.
  Future<List<QuotationVersion>> getVersionsForQuotation(
    String quotationId,
    List<String> legacyHistory,
    List<QuotationItem> currentItems,
  ) async {
    try {
      final snap = await _db
          .collection('quotation_versions')
          .where('quotationId', isEqualTo: quotationId)
          .orderBy('versionNumber', descending: true)
          .get();

      if (snap.docs.isEmpty && legacyHistory.isNotEmpty) {
        return _migrateLegacyHistory(quotationId, legacyHistory, currentItems);
      }

      return snap.docs
          .map((doc) => QuotationVersionModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed fetching versions", layer: LogLayer.repository, className: "QuotationHelpersDelegate", methodName: "getVersionsForQuotation", error: e, stack: stack);
      return [];
    }
  }

  List<QuotationVersion> _migrateLegacyHistory(
    String quotationId,
    List<String> legacyHistory,
    List<QuotationItem> currentItems,
  ) {
    final list = <QuotationVersion>[];
    for (var histStr in legacyHistory) {
      try {
        final json = jsonDecode(histStr) as Map<String, dynamic>;
        final versionNum = json['version'] as int? ?? 1;

        final rawItems = json['items'] as List? ?? [];
        final itemsList = rawItems
            .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final version = QuotationVersion(
          id: '${quotationId}_$versionNum',
          quotationId: quotationId,
          versionNumber: versionNum,
          items: itemsList.isEmpty ? currentItems : itemsList,
          subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
          discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
          gstPercent: (json['gst_percent'] ?? json['gstPercent'] as num?)?.toDouble() ?? 18.0,
          gstAmount: (json['gst_amount'] ?? json['gstAmount'] as num?)?.toDouble() ?? 0.0,
          deliveryCharge: (json['delivery_charge'] ?? json['deliveryCharge'] ?? json['delivery'] as num?)?.toDouble() ?? 0.0,
          travelCharge: (json['travel_charge'] ?? json['travelCharge'] as num?)?.toDouble() ?? 0.0,
          grandTotal: (json['grand_total'] ?? json['grandTotal'] as num?)?.toDouble() ?? 0.0,
          adminMessage: json['adminMessage'] ?? json['admin_message'],
          publishedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
          publishedBy: json['editor'] ?? 'Admin',
          pdfUrl: json['pdf_url'] ?? json['pdfUrl'] ?? '',
          revisionReason: json['reason'] ?? 'Legacy Version',
        );
        list.add(version);

        _db
            .collection('quotation_versions')
            .doc(version.id)
            .set(QuotationVersionModel(
              id: version.id,
              quotationId: version.quotationId,
              versionNumber: version.versionNumber,
              items: version.items,
              subtotal: version.subtotal,
              discount: version.discount,
              gstPercent: version.gstPercent,
              gstAmount: version.gstAmount,
              deliveryCharge: version.deliveryCharge,
              travelCharge: version.travelCharge,
              grandTotal: version.grandTotal,
              adminMessage: version.adminMessage,
              publishedAt: version.publishedAt,
              publishedBy: version.publishedBy,
              pdfUrl: version.pdfUrl,
              revisionReason: version.revisionReason,
            ).toJson());
      } catch (_) {}
    }
    list.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    return list;
  }

  /// Posts system message inside quotation message thread.
  Future<void> postSystemMessage(
    String quotationId,
    String content,
    String type, {
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      final docRef = _db.collection('quotation_messages').doc();
      await docRef.set({
        'quotationId': quotationId,
        'senderId': senderId ?? 'system',
        'senderName': senderName ?? 'System',
        'senderRole': senderRole ?? 'system',
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'isReadByAdmin': senderRole == 'admin',
        'isReadByClient': senderRole == 'client',
        'attachments': [],
      });
      AppLogger.success("Posted system message for $quotationId", layer: LogLayer.repository, className: "QuotationHelpersDelegate", methodName: "postSystemMessage");
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to post system message", layer: LogLayer.repository, className: "QuotationHelpersDelegate", methodName: "postSystemMessage", error: e, stack: stack);
    }
  }

  /// Writes an audit record in Firestore logs.
  Future<void> writeAuditLog({
    required String action,
    required String user,
    required String role,
    required int version,
    required String quotationId,
    required String details,
  }) async {
    try {
      await _db.collection('activity_logs').add({
        'action': action,
        'user': user,
        'role': role,
        'timestamp': FieldValue.serverTimestamp(),
        'version': version,
        'quotationId': quotationId,
        'details': details,
      });
      AppLogger.success("Written audit log for $quotationId", layer: LogLayer.repository, className: "QuotationHelpersDelegate", methodName: "writeAuditLog");
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to write audit log", layer: LogLayer.repository, className: "QuotationHelpersDelegate", methodName: "writeAuditLog", error: e, stack: stack);
    }
  }
}
