import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/quotation_pdf_generator.dart';
import '../../domain/entities/quotation.dart';
import '../datasources/firestore_remote_source.dart';
import '../datasources/supabase_storage_source.dart';
import '../models/quotation_model.dart';
import '../models/quotation_version_model.dart';
import 'quotation_helpers_delegate.dart';

/// Delegate handling revision publishing and snapshot logs for QuotationRepository.
class QuotationRevisionsDelegate {
  final FirestoreRemoteSource firestoreSource;
  final SupabaseStorageSource? supabaseSource;
  final QuotationHelpersDelegate helpersDelegate;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  QuotationRevisionsDelegate({
    required this.firestoreSource,
    required this.supabaseSource,
    required this.helpersDelegate,
  });

  /// Publishes a new revision, snapshots previous state, and clears active drafts.
  Future<void> publishQuotationRevision(Quotation quotation) async {
    try {
      AppLogger.info("Starting revision publish for ${quotation.id}", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision");
      final doc = await _db.collection(AppCollections.quotations).doc(quotation.id).get();
      if (!doc.exists) {
        throw const ServerFailure("Quotation not found");
      }

      final data = doc.data()!;
      final previousVersionNum = data['version'] ?? 1;
      final newVersion = previousVersionNum + 1;
      final newStatus = QuotationStatus.republished;

      AppLogger.info("Incrementing version: $previousVersionNum -> $newVersion", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision");

      var updatedQuotation = quotation.resetConsent().copyWith(
        version: newVersion,
        status: newStatus,
        updatedAt: DateTime.now(),
        lastPublishedAt: DateTime.now(),
        revisionReason: null,
        revisionMessage: null,
      );

      if (supabaseSource != null) {
        try {
          AppLogger.info("Generating PDF bytes...", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision");
          final pdfBytes = await QuotationPdfGenerator.generate(updatedQuotation);
          AppLogger.info("Uploading PDF to Supabase...", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision");
          final filePath = 'quotes/${updatedQuotation.publicId}.pdf';
          final uploadedPdfUrl = await supabaseSource!.uploadFile(
            filePath,
            pdfBytes,
            'application/pdf',
          );
          AppLogger.success("PDF uploaded: $uploadedPdfUrl", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision");
          updatedQuotation = updatedQuotation.copyWith(pdfUrl: uploadedPdfUrl);
        } catch (pdfEx, pdfStack) {
          AppLogger.errorDetailed("PDF generation/upload failed", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision", error: pdfEx, stack: pdfStack);
        }
      }

      final model = QuotationModel(
        id: updatedQuotation.id,
        publicId: updatedQuotation.publicId,
        customerPhone: updatedQuotation.customerPhone,
        customerName: updatedQuotation.customerName,
        eventDate: updatedQuotation.eventDate,
        eventTime: updatedQuotation.eventTime,
        location: updatedQuotation.location,
        notes: updatedQuotation.notes,
        subtotal: updatedQuotation.subtotal,
        discount: updatedQuotation.discount,
        deliveryCharge: updatedQuotation.deliveryCharge,
        travelCharge: updatedQuotation.travelCharge,
        gstPercent: updatedQuotation.gstPercent,
        gstAmount: updatedQuotation.gstAmount,
        grandTotal: updatedQuotation.grandTotal,
        pdfUrl: updatedQuotation.pdfUrl,
        status: updatedQuotation.status,
        items: updatedQuotation.items.map((e) => QuotationItemModel(
          experienceId: e.experienceId,
          name: e.name,
          quantity: e.quantity,
          unitPrice: e.unitPrice,
          color: e.color,
          theme: e.theme,
          notes: e.notes,
        )).toList(),
        createdAt: updatedQuotation.createdAt,
        updatedAt: updatedQuotation.updatedAt,
        customerId: updatedQuotation.customerId,
        version: updatedQuotation.version,
        publishedAt: updatedQuotation.publishedAt ?? DateTime.now(),
        publishedBy: 'Admin',
        revisionReason: null,
        revisionMessage: null,
        adminMessage: updatedQuotation.adminMessage,
        customerAction: null,
        customerActionAt: null,
        customerViewedAt: null,
        lastPublishedAt: updatedQuotation.lastPublishedAt,
        internalNotes: updatedQuotation.internalNotes,
        acceptedAt: null,
        acceptedVersion: null,
        acceptedAmount: null,
        acceptedBy: null,
        acceptedDevice: null,
        acceptedIp: null,
        consentTextVersion: null,
      );

      await _db.collection(AppCollections.quotations).doc(quotation.id).set(model.toJson());
      AppLogger.success("Main quotation document written successfully", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision");

      _publishSideEffects(
        quotation: quotation,
        data: data,
        model: model,
        previousVersionNum: previousVersionNum,
        newVersion: newVersion,
        updatedQuotation: updatedQuotation,
      );
    } catch (e, stack) {
      AppLogger.errorDetailed("Failed publishing revision", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "publishQuotationRevision", error: e, stack: stack);
      throw ServerFailure("Failed to publish revision: ${e.toString()}");
    }
  }

  void _publishSideEffects({
    required Quotation quotation,
    required Map<String, dynamic> data,
    required QuotationModel model,
    required int previousVersionNum,
    required int newVersion,
    required Quotation updatedQuotation,
  }) {
    Future(() async {
      try {
        final versionId = '${quotation.id}_$previousVersionNum';
        AppLogger.info("Writing version snapshot $versionId", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects");

        final rawItems = data['items'] as List? ?? [];
        final itemsList = rawItems
            .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final versionModel = QuotationVersionModel(
          id: versionId,
          quotationId: quotation.id,
          versionNumber: previousVersionNum,
          items: itemsList,
          subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
          discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
          gstPercent: (data['gst_percent'] ?? data['gstPercent'] as num?)?.toDouble() ?? 18.0,
          gstAmount: (data['gst_amount'] ?? data['gstAmount'] as num?)?.toDouble() ?? 0.0,
          deliveryCharge: (data['delivery_charge'] ?? data['deliveryCharge'] ?? data['delivery'] as num?)?.toDouble() ?? 0.0,
          travelCharge: (data['travel_charge'] ?? data['travelCharge'] as num?)?.toDouble() ?? 0.0,
          grandTotal: (data['grand_total'] ?? data['grandTotal'] as num?)?.toDouble() ?? 0.0,
          adminMessage: data['adminMessage'] ?? data['admin_message'],
          publishedAt: DateTime.tryParse(data['updated_at'] ?? data['updatedAt'] ?? '') ?? DateTime.now(),
          publishedBy: data['publishedBy'] ?? 'Admin',
          pdfUrl: data['pdf_url'] ?? data['pdfUrl'] ?? '',
          revisionReason: quotation.revisionReason ?? 'Admin Revision',
        );

        await _db.collection('quotation_versions').doc(versionId).set(versionModel.toJson());
        AppLogger.success("Version snapshot written successfully", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects");
      } catch (e) {
        AppLogger.errorDetailed("Version snapshot write failed (non-blocking)", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects", error: e);
      }

      try {
        AppLogger.info("Deleting draft from database", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects");
        await _db.collection('quotation_drafts').doc(quotation.id).delete();
      } catch (e) {
        AppLogger.errorDetailed("Draft delete failed (non-blocking)", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects", error: e);
      }

      try {
        final oldGrandTotal = (data['grand_total'] ?? data['grandTotal'] as num?)?.toDouble() ?? 0.0;
        final newGrandTotal = model.grandTotal;
        if (oldGrandTotal != newGrandTotal) {
          AppLogger.info("Posting price change system message", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects");
          await helpersDelegate.postSystemMessage(
            quotation.id,
            'Price updated from ₹${oldGrandTotal.toStringAsFixed(0)} to ₹${newGrandTotal.toStringAsFixed(0)}.',
            'priceChange',
            senderId: 'admin',
            senderName: 'Admin',
            senderRole: 'admin',
          );
        }

        final revisionNote = quotation.revisionReason ?? updatedQuotation.adminMessage ?? 'No notes';
        await helpersDelegate.postSystemMessage(
          quotation.id,
          'Revised proposal version $newVersion published by Admin. Notes: $revisionNote',
          'revision',
          senderId: 'admin',
          senderName: 'Admin',
          senderRole: 'admin',
        );
      } catch (e) {
        AppLogger.errorDetailed("System messages post failed (non-blocking)", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects", error: e);
      }

      try {
        final customerId = updatedQuotation.customerId;
        if (customerId.isNotEmpty) {
          await _db.collection(AppCollections.customerNotifications).add({
            'customerId': customerId,
            'title': 'Proposal Updated',
            'body': 'Admin published a revised proposal for invoice ${updatedQuotation.publicId}.',
            'type': 'quotation_updated',
            'isRead': false,
            'createdAt': DateTime.now().toIso8601String(),
            'branch': updatedQuotation.location,
            'quotationId': quotation.id,
          });

          await _db.collection(AppCollections.customerActivity).add({
            'customerId': customerId,
            'status': 'Quotation',
            'updatedAt': DateTime.now().toIso8601String(),
            'details': 'Admin published revised proposal version $newVersion.',
          });

          await helpersDelegate.writeAuditLog(
            action: 'Revision Published',
            user: 'Admin',
            role: 'admin',
            version: newVersion,
            quotationId: quotation.id,
            details: 'Admin published revised proposal version $newVersion.',
          );
        }
      } catch (e) {
        AppLogger.errorDetailed("Notifications/activity/audit failed (non-blocking)", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects", error: e);
      }

      AppLogger.info("All background side-effects completed", layer: LogLayer.repository, className: "QuotationRevisionsDelegate", methodName: "_publishSideEffects");
    });
  }
}
