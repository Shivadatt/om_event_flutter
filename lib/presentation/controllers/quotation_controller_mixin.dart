import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/experience.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/repositories/lead_repository.dart';

mixin QuotationControllerMixin on GetxController {
  QuotationRepository get quotationRepository;
  LeadRepository get leadRepository;
  Future<void> loadDashboardStats();

  // --- Active Quotation Editor State ---
  final rxEditingQuotation = Rxn<Quotation>();
  final rxEditorItems = <QuotationItem>[].obs;
  
  final editorSubtotal = 0.0.obs;
  final editorDiscount = 0.0.obs;
  final editorDelivery = 0.0.obs;
  final editorTravel = 0.0.obs;
  final editorGstPercent = 18.0.obs;
  final editorGstAmount = 0.0.obs;
  final editorGrandTotal = 0.0.obs;
  
  final isSavingDraft = false.obs;
  final isPublishingRevision = false.obs;

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

  Future<void> loadQuotationForEditing(Quotation quote) async {
    try {
      debugPrint("loadQuotationForEditing: Started for quoteId=${quote.id}, current status=${quote.status}");
      if (quote.status == QuotationStatus.revisionRequested ||
          quote.status == QuotationStatus.published ||
          quote.status == QuotationStatus.viewed ||
          quote.status == QuotationStatus.republished) {
        debugPrint("loadQuotationForEditing: Status matches revision triggers. Setting status to underRevision...");
        await quotationRepository.updateQuotationStatus(quote.id, QuotationStatus.underRevision.nameStr);
        debugPrint("loadQuotationForEditing: Status updated to underRevision on database.");
      }

      debugPrint("loadQuotationForEditing: Fetching quotation draft...");
      final draft = await quotationRepository.getQuotationDraft(quote.id);
      if (draft != null) {
        debugPrint("loadQuotationForEditing: Draft found. Using draft.");
        rxEditingQuotation.value = draft;
      } else {
        debugPrint("loadQuotationForEditing: No draft found. Using quote.");
        rxEditingQuotation.value = quote;
      }
      
      final activeQuote = rxEditingQuotation.value!;
      debugPrint("loadQuotationForEditing: Assigning editor items count=${activeQuote.items.length}");
      rxEditorItems.assignAll(activeQuote.items);
      editorDiscount.value = activeQuote.discount;
      editorDelivery.value = 0.0;
      editorTravel.value = activeQuote.travelCharge;
      editorGstPercent.value = activeQuote.gstPercent;
      
      debugPrint("loadQuotationForEditing: Recalculating totals...");
      recalculateEditorTotals();
      debugPrint("loadQuotationForEditing: Load completed successfully.");
    } catch (e, s) {
      debugPrint("loadQuotationForEditing Exception: $e\n$s");
      try {
        Get.snackbar("Error Loading Editor", e.toString());
      } catch (e2, s2) {
        debugPrint("loadQuotationForEditing: Snackbar exception: $e2\n$s2");
      }
    }
  }

  void recalculateEditorTotals() {
    double sub = 0.0;
    for (var item in rxEditorItems) {
      sub += item.quantity * item.unitPrice;
    }
    editorSubtotal.value = sub;
    
    final taxable = sub - editorDiscount.value + editorDelivery.value + editorTravel.value;
    editorGstAmount.value = taxable * (editorGstPercent.value / 100.0);
    editorGrandTotal.value = taxable + editorGstAmount.value;
  }

  void addEditorItem(Experience experience) {
    final existingIndex = rxEditorItems.indexWhere((item) => item.experienceId == experience.slug);
    if (existingIndex >= 0) {
      final existing = rxEditorItems[existingIndex];
      rxEditorItems[existingIndex] = QuotationItem(
        experienceId: existing.experienceId,
        name: existing.name,
        quantity: existing.quantity + 1,
        unitPrice: existing.unitPrice,
        color: existing.color,
        theme: existing.theme,
        notes: existing.notes,
      );
    } else {
      rxEditorItems.add(QuotationItem(
        experienceId: experience.slug,
        name: experience.name,
        quantity: 1,
        unitPrice: experience.price,
        color: "As shown",
        theme: "As shown",
        notes: "",
      ));
    }
    recalculateEditorTotals();
  }

  void removeEditorItem(String experienceId) {
    rxEditorItems.removeWhere((item) => item.experienceId == experienceId);
    recalculateEditorTotals();
  }

  void updateItemQuantity(String experienceId, int qty) {
    final idx = rxEditorItems.indexWhere((item) => item.experienceId == experienceId);
    if (idx >= 0) {
      final existing = rxEditorItems[idx];
      rxEditorItems[idx] = QuotationItem(
        experienceId: existing.experienceId,
        name: existing.name,
        quantity: qty > 0 ? qty : 1,
        unitPrice: existing.unitPrice,
        color: existing.color,
        theme: existing.theme,
        notes: existing.notes,
      );
      recalculateEditorTotals();
    }
  }

  void updateItemUnitPrice(String experienceId, double price) {
    final idx = rxEditorItems.indexWhere((item) => item.experienceId == experienceId);
    if (idx >= 0) {
      final existing = rxEditorItems[idx];
      rxEditorItems[idx] = QuotationItem(
        experienceId: existing.experienceId,
        name: existing.name,
        quantity: existing.quantity,
        unitPrice: price >= 0.0 ? price : 0.0,
        color: existing.color,
        theme: existing.theme,
        notes: existing.notes,
      );
      recalculateEditorTotals();
    }
  }

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
      print("saveActiveDraft: rxEditingQuotation is null!");
      return false;
    }

    try {
      print("saveActiveDraft: Setting isSavingDraft to true");
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

      print("saveActiveDraft: Calling saveQuotationDraft");
      await quotationRepository.saveQuotationDraft(draftQuote);
      print("saveActiveDraft: saveQuotationDraft returned successfully");
      rxEditingQuotation.value = draftQuote;
      try {
        Get.snackbar("Draft Saved", "Quotation draft changes saved successfully.");
      } catch (e, s) {
        print("saveActiveDraft: Exception in Get.snackbar: $e\n$s");
      }
      return true;
    } catch (e, stack) {
      print("saveActiveDraft Exception: $e\n$stack");
      try {
        Get.snackbar("Error Saving Draft", e.toString());
      } catch (e2, s2) {
        print("saveActiveDraft: Exception in Get.snackbar error: $e2\n$s2");
      }
      return false;
    } finally {
      print("saveActiveDraft: finally - setting isSavingDraft to false");
      isSavingDraft.value = false;
    }
  }

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
      print("publishActiveRevision: rxEditingQuotation is null!");
      return false;
    }

    try {
      print("publishActiveRevision: Setting isPublishingRevision to true");
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

      print("publishActiveRevision: Calling publishQuotationRevision");
      await quotationRepository.publishQuotationRevision(updatedQuote);
      print("publishActiveRevision: publishQuotationRevision returned successfully");
      
      rxEditingQuotation.value = null;
      try {
        Get.snackbar("Proposal Published", "Quotation revision published successfully.");
      } catch (e, s) {
        print("publishActiveRevision: Exception in Get.snackbar: $e\n$s");
      }
      return true;
    } catch (e, stack) {
      print("publishActiveRevision: Exception caught: $e\n$stack");
      try {
        Get.snackbar("Error Publishing Revision", e.toString());
      } catch (e2, s2) {
        print("publishActiveRevision: Exception in Get.snackbar error: $e2\n$s2");
      }
      return false;
    } finally {
      print("publishActiveRevision: finally - setting isPublishingRevision to false");
      isPublishingRevision.value = false;
    }
  }

  Future<void> archiveQuotation(String id) async {
    try {
      await quotationRepository.updateQuotationStatus(id, QuotationStatus.archived.nameStr);
      Get.snackbar("Success", "Quotation archived successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> expireQuotation(String id) async {
    try {
      await quotationRepository.updateQuotationStatus(id, QuotationStatus.expired.nameStr);
      Get.snackbar("Success", "Quotation marked as expired.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> convertQuotationToBooking(String id) async {
    try {
      await quotationRepository.updateQuotationStatus(id, QuotationStatus.bookingConfirmed.nameStr);
      Get.snackbar("Success", "Quotation converted to Booking successfully.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> unlockQuotation(String id, String superAdminName) async {
    try {
      await quotationRepository.unlockQuotation(id, superAdminName);
      Get.snackbar("Quotation Unlocked", "Financial locks have been successfully removed.");
    } catch (e) {
      Get.snackbar("Unlock Error", e.toString());
    }
  }
}
