part of '../quotation_controller.dart';

extension QuotationActions on QuotationController {
  // Submit Quotation
  Future<bool> submitQuotationRequest({
    required String name,
    required String phone,
    required String dateStr,
    required String timeStr,
    required String location,
    required String notes,
  }) async {
    if (!AppValidators.isValidName(name)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid name (at least 2 letters).",
      );
      return false;
    }
    if (!AppValidators.isValidPhone(phone)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
      );
      return false;
    }
    if (location.trim().isEmpty) {
      Get.snackbar("Validation Error", "Please specify the venue or location.");
      return false;
    }
    if (cartController.rxCartItems.isEmpty) {
      Get.snackbar(
        "Canvas is Empty",
        "Please select at least one decoration to generate a quotation.",
      );
      return false;
    }

    try {
      isGeneratingQuote.value = true;

      final cleanedPhone = AppValidators.cleanPhone(phone);
      final eventDate = DateTime.tryParse(dateStr) ?? DateTime.now();
      final publicId = _generatePublicId().toUpperCase();
      final quotationId = DateTime.now().millisecondsSinceEpoch.toString();

      // Maps Cart Items to Quotation Items
      final quotationItems = cartController.rxCartItems.map((cartItem) {
        return QuotationItem(
          experienceId: cartItem.experience.id,
          name: cartItem.experience.name,
          quantity: cartItem.quantity,
          unitPrice: cartItem.experience.effectivePrice,
          color: cartItem.color.isEmpty ? "As shown" : cartItem.color,
          theme: cartItem.theme.isEmpty ? "As shown" : cartItem.theme,
          notes: cartItem.notes,
        );
      }).toList();

      // Calculation values matching backend standard
      final subtotal = cartController.subtotal;
      final discount = cartController.volumeDiscount;
      final delivery = AppConstants.enableClientFeeWaiver ? 0.0 : cartController.deliveryCharge;
      final travel = AppConstants.enableClientFeeWaiver ? 0.0 : cartController.travelCharge;
      final gstPercent = AppConstants.enableClientFeeWaiver ? 0.0 : AppConstants.gstPercent;

      // Note: We use standard server calculations for the database record
      // to ensure billing consistency
      final taxable = subtotal - discount + delivery + travel;
      final gstAmount = taxable * (gstPercent / 100.0);
      final grandTotal = taxable + gstAmount;

      final partialQuotation = Quotation(
        id: quotationId,
        publicId: publicId,
        customerPhone: cleanedPhone,
        customerName: name.trim(),
        eventDate: eventDate,
        eventTime: timeStr,
        location: location.trim(),
        notes: notes.trim(),
        subtotal: subtotal,
        discount: discount,
        deliveryCharge: delivery,
        travelCharge: travel,
        gstPercent: gstPercent,
        gstAmount: gstAmount,
        grandTotal: grandTotal,
        pdfUrl: '', // Updated post upload
        status: 'draft',
        items: quotationItems,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate invoice PDF
      final pdfBytes = await _generateInvoicePdf(partialQuotation);

      // Upload to Supabase Storage
      String uploadedPdfUrl = '';
      try {
        uploadedPdfUrl = await quotationRepository.uploadQuotationPdf(
          publicId,
          pdfBytes,
        );
      } catch (e) {
        // Fallback or log if Supabase keys not set
        AppLogger.error("Supabase upload error", e);
      }

      final finalQuotation = Quotation(
        id: partialQuotation.id,
        publicId: partialQuotation.publicId,
        customerPhone: partialQuotation.customerPhone,
        customerName: partialQuotation.customerName,
        eventDate: partialQuotation.eventDate,
        eventTime: partialQuotation.eventTime,
        location: partialQuotation.location,
        notes: partialQuotation.notes,
        subtotal: partialQuotation.subtotal,
        discount: partialQuotation.discount,
        deliveryCharge: partialQuotation.deliveryCharge,
        travelCharge: partialQuotation.travelCharge,
        gstPercent: partialQuotation.gstPercent,
        gstAmount: partialQuotation.gstAmount,
        grandTotal: partialQuotation.grandTotal,
        pdfUrl: uploadedPdfUrl,
        status: 'pending',
        items: partialQuotation.items,
        createdAt: partialQuotation.createdAt,
        updatedAt: partialQuotation.updatedAt,
      );

      // Save to Cloud Firestore
      await createQuotationUsecase(finalQuotation);

      // If customer is logged in, link quotation to customer portal
      final authCtrl = Get.find<CustomerAuthController>();
      final customerId = authCtrl.rxCustomerProfile.value?.id ?? '';
      if (customerId.isNotEmpty) {
        final customerQuoteRef = FirebaseFirestore.instance.collection(AppCollections.customerQuotes).doc(quotationId);
        await customerQuoteRef.set({
          'customerId': customerId,
          'quotationNumber': publicId,
          'date': eventDate.toIso8601String(),
          'amount': grandTotal,
          'status': 'pending',
          'expiryDate': eventDate.add(const Duration(days: 7)).toIso8601String(),
          'pdfUrl': uploadedPdfUrl,
          'notes': notes.trim(),
          'versionHistory': [],
        });
      }

      rxCreatedQuotation.value = finalQuotation;

      // Reset selection drawer
      cartController.clearCart();

      // Route to success view
      Get.offNamed(AppRoutes.quoteSuccess);
      return true;
    } catch (e) {
      Get.snackbar("Failed", "Quotation failed: ${e.toString()}");
      return false;
    } finally {
      isGeneratingQuote.value = false;
    }
  }
}
