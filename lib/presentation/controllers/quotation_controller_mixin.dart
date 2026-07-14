import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../core/utils/app_logger.dart';
import 'quotation_editor_state_mixin.dart';

/// Admin quotation CRUD operations coordinator, mixed in by GetX controller.
mixin QuotationControllerMixin on GetxController, QuotationEditorStateMixin {
  QuotationRepository get quotationRepository;
  LeadRepository get leadRepository;
  Future<void> loadDashboardStats();

  /// Updates status of a quotation.
  Future<void> updateQuotation(String id, String status) async {
    try {
      final targetStatus = QuotationStatus.fromString(status);
      if (targetStatus == QuotationStatus.acceptedByClient || targetStatus == QuotationStatus.rejectedByClient) {
        throw Exception("Customer acceptance or rejection must always originate from the Client Portal.");
      }
      await quotationRepository.updateQuotationStatus(id, status);
      await loadDashboardStats();
      Get.snackbar("Status Updated", "Quotation status updated successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Sends admin custom proposal coordinator chat messages.
  Future<void> sendProposalMessage(String id, String message) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection(AppCollections.quotations).doc(id).update({
        'adminMessage': message,
      });
      
      final doc = await db.collection(AppCollections.quotations).doc(id).get();
      final data = doc.data() ?? {};
      final customerId = data['customerId'] ?? data['customer_id'] ?? '';
      
      if (customerId.isNotEmpty) {
        await db.collection(AppCollections.customerNotifications).add({
          'customerId': customerId,
          'title': 'New Message from Studio',
          'body': 'Admin sent a message regarding proposal ${data['public_id'] ?? id}: "$message"',
          'type': 'message',
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
          'branch': data['location'] ?? '',
        });
      }
      Get.snackbar("Message Sent", "Proposal message sent successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: ${e.toString()}");
    }
  }

  /// Loads active quotation models for live item curation.
  Future<void> loadQuotationForEditing(Quotation quote) async {
    try {
      AppLogger.info("loadQuotationForEditing: Started for quoteId=${quote.id}", layer: LogLayer.controller, className: "QuotationControllerMixin", methodName: "loadQuotationForEditing");
      if (quote.status == QuotationStatus.revisionRequested ||
          quote.status == QuotationStatus.published ||
          quote.status == QuotationStatus.viewed ||
          quote.status == QuotationStatus.republished) {
        await quotationRepository.updateQuotationStatus(quote.id, QuotationStatus.underRevision.nameStr);
      }

      final draft = await quotationRepository.getQuotationDraft(quote.id);
      rxEditingQuotation.value = draft ?? quote;
      
      final activeQuote = rxEditingQuotation.value!;
      rxEditorItems.assignAll(activeQuote.items);
      editorDiscount.value = activeQuote.discount;
      editorDelivery.value = 0.0;
      editorTravel.value = activeQuote.travelCharge;
      editorGstPercent.value = activeQuote.gstPercent;
      
      recalculateEditorTotals();
    } catch (e, s) {
      AppLogger.errorDetailed("loadQuotationForEditing Exception", error: e, stack: s, layer: LogLayer.controller, className: "QuotationControllerMixin", methodName: "loadQuotationForEditing");
      Get.snackbar("Error Loading Editor", e.toString());
    }
  }

  /// Saves active quotation draft edits.
  Future<bool> saveActiveDraft({
    required DateTime eventDate,
    required String eventTime,
    required String location,
    required String notes,
    required String? internalNotes,
    required String? adminMessage,
    String? operationalNotes,
    String? bookingDetails,
    String? staffAssignment,
    String? logistics,
  }) async {
    final active = rxEditingQuotation.value;
    if (active == null) {
      AppLogger.warning("rxEditingQuotation is null!", layer: LogLayer.controller, className: "QuotationControllerMixin", methodName: "saveActiveDraft");
      return false;
    }

    try {
      isSavingDraft.value = true;
      final draftQuote = active.copyWith(
        eventDate: eventDate,
        eventTime: eventTime,
        location: location,
        notes: notes,
        internalNotes: internalNotes,
        adminMessage: adminMessage,
        items: rxEditorItems,
        subtotal: editorSubtotal.value,
        discount: editorDiscount.value,
        deliveryCharge: editorDelivery.value,
        travelCharge: editorTravel.value,
        gstPercent: editorGstPercent.value,
        gstAmount: editorGstAmount.value,
        grandTotal: editorGrandTotal.value,
        operationalNotes: operationalNotes,
        bookingDetails: bookingDetails,
        staffAssignment: staffAssignment,
        logistics: logistics,
      );

      await quotationRepository.saveQuotationDraft(draftQuote);
      rxEditingQuotation.value = draftQuote;
      Get.snackbar("Draft Saved", "Quotation draft changes saved successfully.");
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed("Exception saving active draft", layer: LogLayer.controller, className: "QuotationControllerMixin", methodName: "saveActiveDraft", error: e, stack: stack);
      Get.snackbar("Error Saving Draft", e.toString());
      return false;
    } finally {
      isSavingDraft.value = false;
    }
  }

  /// Publishes draft changes as a new revision.
  Future<bool> publishActiveRevision({
    required DateTime eventDate,
    required String eventTime,
    required String location,
    required String notes,
    required String? internalNotes,
    required String? adminMessage,
    required String revisionReason,
    String? operationalNotes,
    String? bookingDetails,
    String? staffAssignment,
    String? logistics,
  }) async {
    final active = rxEditingQuotation.value;
    if (active == null) {
      AppLogger.warning("rxEditingQuotation is null!", layer: LogLayer.controller, className: "QuotationControllerMixin", methodName: "publishActiveRevision");
      return false;
    }

    try {
      isPublishingRevision.value = true;
      final updatedQuote = active.copyWith(
        eventDate: eventDate,
        eventTime: eventTime,
        location: location,
        notes: notes,
        internalNotes: internalNotes,
        adminMessage: adminMessage,
        items: rxEditorItems,
        subtotal: editorSubtotal.value,
        discount: editorDiscount.value,
        deliveryCharge: editorDelivery.value,
        travelCharge: editorTravel.value,
        gstPercent: editorGstPercent.value,
        gstAmount: editorGstAmount.value,
        grandTotal: editorGrandTotal.value,
        revisionReason: revisionReason,
        operationalNotes: operationalNotes,
        bookingDetails: bookingDetails,
        staffAssignment: staffAssignment,
        logistics: logistics,
      );

      await quotationRepository.publishQuotationRevision(updatedQuote);
      rxEditingQuotation.value = null;
      Get.snackbar("Proposal Published", "Quotation revision published successfully.");
      return true;
    } catch (e, stack) {
      AppLogger.errorDetailed("Exception publishing active revision", layer: LogLayer.controller, className: "QuotationControllerMixin", methodName: "publishActiveRevision", error: e, stack: stack);
      Get.snackbar("Error Publishing Revision", e.toString());
      return false;
    } finally {
      isPublishingRevision.value = false;
    }
  }

  /// Archives active quotation.
  Future<void> archiveQuotation(String id) async {
    try {
      await quotationRepository.updateQuotationStatus(id, QuotationStatus.archived.nameStr);
      Get.snackbar("Success", "Quotation archived successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Marks quotation as expired.
  Future<void> expireQuotation(String id) async {
    try {
      await quotationRepository.updateQuotationStatus(id, QuotationStatus.expired.nameStr);
      Get.snackbar("Success", "Quotation marked as expired.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Converts accepted proposal into confirmed Booking.
  Future<void> convertQuotationToBooking(String id) async {
    try {
      await quotationRepository.updateQuotationStatus(id, QuotationStatus.bookingConfirmed.nameStr);
      Get.snackbar("Success", "Quotation converted to Booking successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Unlocks editing pricing fields for locked proposal.
  Future<void> unlockQuotation(String id, String superAdminName) async {
    try {
      await quotationRepository.unlockQuotation(id, superAdminName);
      Get.snackbar("Quotation Unlocked", "Financial locks have been successfully removed.");
    } catch (e) {
      Get.snackbar("Unlock Error", e.toString());
    }
  }
}
