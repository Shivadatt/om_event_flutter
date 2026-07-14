import 'package:get/get.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/experience.dart';

/// Mixin providing state management and calculations for the quotation editor dialog.
mixin QuotationEditorStateMixin on GetxController {
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

  /// Recalculates totals including GST, travel, and discounts.
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

  /// Adds a new catalog experience decoration item to the proposal editor.
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

  /// Removes an experience decoration item from the proposal editor.
  void removeEditorItem(String experienceId) {
    rxEditorItems.removeWhere((item) => item.experienceId == experienceId);
    recalculateEditorTotals();
  }

  /// Modifies the quantity of a proposal item.
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

  /// Modifies the unit price of a proposal item.
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
}
