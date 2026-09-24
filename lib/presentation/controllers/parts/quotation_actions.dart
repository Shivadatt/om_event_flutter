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
    // 1. AUTH CHECK FIRST
    final authCtrl = Get.find<CustomerAuthController>();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.isAnonymous || !authCtrl.isAuthenticatedCustomer) {
      Get.snackbar(
        "Login Required",
        "Please login to your customer account to submit a quotation request.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF231B1B),
        colorText: const Color(0xFFFFAA99),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    // 2. VALIDATION
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

      // Check date availability
      final availabilityService = Get.isRegistered<BookingAvailabilityService>()
          ? BookingAvailabilityService.to
          : Get.put(BookingAvailabilityService());
      final availability = await availabilityService.checkDateAvailability(eventDate);
      if (!availability.isAvailable) {
        Get.snackbar(
          "Date Unavailable",
          availability.reason ?? "This date is unavailable. Please select another date.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF231B1B),
          colorText: const Color(0xFFFFAA99),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }

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

      final String customerId = currentUser.uid;

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
        status: QuotationStatus.draft,
        items: quotationItems,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customerId: customerId,
      );

      // Generate invoice PDF
      final pdfBytes = await generateInvoicePdf(partialQuotation);

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
        status: QuotationStatus.published,
        items: partialQuotation.items,
        createdAt: partialQuotation.createdAt,
        updatedAt: partialQuotation.updatedAt,
        customerId: customerId,
      );

      // Save to Cloud Firestore
      await createQuotationUsecase(finalQuotation);

      rxCreatedQuotation.value = finalQuotation;

      // Reset selection drawer
      cartController.clearCart();

      // Route to success view
      Get.offNamed(AppRoutes.quoteSuccess);
      return true;
    } catch (e) {
      final safeMsg = AppErrorMapper.mapBookingError(e);
      Get.snackbar("Notice", safeMsg);
      return false;
    } finally {
      isGeneratingQuote.value = false;
    }
  }

  /// Submits a direct service + package booking with real availability validation
  Future<bool> submitDirectBookingRequest({
    required Experience experience,
    required PackageOption package,
    required String name,
    required String phone,
    String? email,
    required String dateStr,
    required String timeStr,
    required String venue,
    required String notes,
    String? referenceImageUrl,
  }) async {
    // 1. AUTH CHECK FIRST
    final authCtrl = Get.find<CustomerAuthController>();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.isAnonymous || !authCtrl.isAuthenticatedCustomer) {
      Get.snackbar(
        "Login Required",
        "Please login to your customer account to submit a booking.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF231B1B),
        colorText: const Color(0xFFFFAA99),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    // 2. VALIDATION
    if (!AppValidators.isValidName(name)) {
      Get.snackbar("Validation Error", "Please enter a valid name (at least 2 letters).");
      return false;
    }
    if (!AppValidators.isValidPhone(phone)) {
      Get.snackbar("Validation Error", "Please enter a valid 10-digit mobile number.");
      return false;
    }
    if (venue.trim().isEmpty) {
      Get.snackbar("Validation Error", "Please specify the venue or location.");
      return false;
    }

    // 3. AVAILABILITY CHECK
    final eventDate = DateTime.tryParse(dateStr) ?? DateTime.now();

    // Re-verify availability atomically before writing to database
    final availabilityService = Get.isRegistered<BookingAvailabilityService>()
        ? BookingAvailabilityService.to
        : Get.put(BookingAvailabilityService());

    final availability = await availabilityService.checkDateAvailability(eventDate);
    if (!availability.isAvailable) {
      Get.snackbar(
        "Date Unavailable",
        availability.reason ?? "This date is unavailable. Please select another date.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF231B1B),
        colorText: const Color(0xFFFFAA99),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    // 4. BOOKING TRANSACTION
    try {
      isGeneratingQuote.value = true;

      final cleanedPhone = AppValidators.cleanPhone(phone);
      final publicId = generateBookingReferenceId(eventDate);
      final quotationId = DateTime.now().millisecondsSinceEpoch.toString();
      final String customerId = currentUser.uid;

      final double unitPrice = package.effectivePrice;
      final double gstPercent = AppConstants.enableClientFeeWaiver ? 0.0 : AppConstants.gstPercent;
      final double gstAmount = unitPrice * (gstPercent / 100.0);
      final double grandTotal = unitPrice + gstAmount;

      final bookingItem = QuotationItem(
        experienceId: experience.id,
        name: "${experience.name} (${package.name})",
        quantity: 1,
        unitPrice: unitPrice,
        color: "Selected Theme",
        theme: package.name,
        notes: "Package: ${package.tier.toUpperCase()} | Features: ${package.features.take(3).join(', ')}",
      );

      final combinedNotes = [
        "Package: ${package.name} (${package.tier.toUpperCase()})",
        if (referenceImageUrl != null && referenceImageUrl.isNotEmpty) "Reference Image: $referenceImageUrl",
        if (notes.trim().isNotEmpty) "Notes: ${notes.trim()}",
      ].join("\n");

      final partialQuotation = Quotation(
        id: quotationId,
        publicId: publicId,
        customerPhone: cleanedPhone,
        customerName: name.trim(),
        eventDate: eventDate,
        eventTime: timeStr,
        location: venue.trim(),
        notes: combinedNotes,
        subtotal: unitPrice,
        discount: 0.0,
        deliveryCharge: 0.0,
        travelCharge: 0.0,
        gstPercent: gstPercent,
        gstAmount: gstAmount,
        grandTotal: grandTotal,
        pdfUrl: '',
        status: QuotationStatus.published,
        items: [bookingItem],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customerId: customerId,
        operationalNotes: referenceImageUrl != null && referenceImageUrl.isNotEmpty
            ? "RefImg: $referenceImageUrl"
            : null,
      );

      // Generate invoice / quotation PDF
      String uploadedPdfUrl = '';
      try {
        final pdfBytes = await generateInvoicePdf(partialQuotation);
        uploadedPdfUrl = await quotationRepository.uploadQuotationPdf(
          publicId,
          pdfBytes,
        );
      } catch (e) {
        AppLogger.error("PDF generation or Supabase upload error", e);
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
        status: QuotationStatus.published,
        items: partialQuotation.items,
        createdAt: partialQuotation.createdAt,
        updatedAt: partialQuotation.updatedAt,
        customerId: customerId,
        operationalNotes: partialQuotation.operationalNotes,
      );

      // Persist to Cloud Firestore
      await createQuotationUsecase(finalQuotation);

      rxCreatedQuotation.value = finalQuotation;

      // Trigger notification
      try {
        if (Get.isRegistered<NotificationLocalService>()) {
          NotificationLocalService.to.show(
            title: "Booking Request Received",
            body: "Your booking for ${experience.name} has been received. Reference ID: $publicId",
          );
        }
      } catch (_) {}

      // Navigate to booking confirmation screen
      Get.offNamed(AppRoutes.quoteSuccess);
      return true;
    } catch (e) {
      final safeMsg = AppErrorMapper.mapBookingError(e);
      Get.snackbar(
        "Booking Notice",
        safeMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF231B1B),
        colorText: const Color(0xFFFFAA99),
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isGeneratingQuote.value = false;
    }
  }
}
