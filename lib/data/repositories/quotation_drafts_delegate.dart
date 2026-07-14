import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/quotation.dart';
import '../models/quotation_model.dart';

/// Delegate handling draft creation, fetch, and deletion for QuotationRepository.
class QuotationDraftsDelegate {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves a draft copy of the quotation.
  Future<void> saveQuotationDraft(Quotation quotation) async {
    try {
      AppLogger.info("Starting draft save for ${quotation.id}", layer: LogLayer.repository, className: "QuotationDraftsDelegate", methodName: "saveQuotationDraft");
      final model = QuotationModel(
        id: quotation.id,
        publicId: quotation.publicId,
        customerPhone: quotation.customerPhone,
        customerName: quotation.customerName,
        eventDate: quotation.eventDate,
        eventTime: quotation.eventTime,
        location: quotation.location,
        notes: quotation.notes,
        subtotal: quotation.subtotal,
        discount: quotation.discount,
        deliveryCharge: quotation.deliveryCharge,
        travelCharge: quotation.travelCharge,
        gstPercent: quotation.gstPercent,
        gstAmount: quotation.gstAmount,
        grandTotal: quotation.grandTotal,
        pdfUrl: quotation.pdfUrl,
        status: quotation.status,
        items: quotation.items.map((e) => QuotationItemModel(
          experienceId: e.experienceId,
          name: e.name,
          quantity: e.quantity,
          unitPrice: e.unitPrice,
          color: e.color,
          theme: e.theme,
          notes: e.notes,
        )).toList(),
        createdAt: quotation.createdAt,
        updatedAt: DateTime.now(),
        customerId: quotation.customerId,
        versions: quotation.versions,
        version: quotation.version,
        publishedAt: quotation.publishedAt,
        publishedBy: quotation.publishedBy,
        revisionReason: quotation.revisionReason,
        revisionMessage: quotation.revisionMessage,
        adminMessage: quotation.adminMessage,
        customerAction: quotation.customerAction,
        customerActionAt: quotation.customerActionAt,
        customerViewedAt: quotation.customerViewedAt,
        lastPublishedAt: quotation.lastPublishedAt,
        internalNotes: quotation.internalNotes,
      );

      await _db.collection('quotation_drafts').doc(quotation.id).set(model.toJson());
      AppLogger.success("Quotation draft saved successfully", layer: LogLayer.repository, className: "QuotationDraftsDelegate", methodName: "saveQuotationDraft");
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to save draft", layer: LogLayer.repository, className: "QuotationDraftsDelegate", methodName: "saveQuotationDraft", error: e, stack: stack);
      throw ServerFailure("Failed to save draft: ${e.toString()}");
    }
  }

  /// Fetches a draft quotation if it exists.
  Future<Quotation?> getQuotationDraft(String id) async {
    try {
      final doc = await _db.collection('quotation_drafts').doc(id).get();
      if (!doc.exists) return null;
      return QuotationModel.fromJson(doc.data()!, doc.id);
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to load draft", layer: LogLayer.repository, className: "QuotationDraftsDelegate", methodName: "getQuotationDraft", error: e, stack: stack);
      throw ServerFailure("Failed to load draft: ${e.toString()}");
    }
  }

  /// Deletes a draft quotation.
  Future<void> deleteQuotationDraft(String id) async {
    try {
      await _db.collection('quotation_drafts').doc(id).delete();
      AppLogger.success("Draft deleted successfully", layer: LogLayer.repository, className: "QuotationDraftsDelegate", methodName: "deleteQuotationDraft");
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed to delete draft", layer: LogLayer.repository, className: "QuotationDraftsDelegate", methodName: "deleteQuotationDraft", error: e, stack: stack);
      throw ServerFailure("Failed to delete draft: ${e.toString()}");
    }
  }
}
