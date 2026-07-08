part of '../customer_dashboard_controller.dart';

extension CustomerActionsExtension on CustomerDashboardController {
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String email,
    required String gender,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String branch,
    required String profileImageUrl,
  }) async {
    try {
      isLoading.value = true;
      final current = rxProfile.value;
      if (current == null) return;

      final updated = CustomerProfileModel(
        id: current.id,
        fullName: fullName,
        phone: phone,
        email: email,
        gender: gender,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        branch: branch,
        profileImageUrl: profileImageUrl,
        createdAt: current.createdAt,
        lastLogin: current.lastLogin,
      );

      await _authRepo.saveCustomerProfile(updated, isEdit: true);
      await _authController.checkAuthStatus();
      await logActivity('Profile Updated', 'Customer updated bio profile details.');
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitLead({
    required String service,
    required String branch,
    required double budget,
    required DateTime eventDate,
  }) async {
    try {
      isLoading.value = true;
      final profile = rxProfile.value;
      if (profile == null) return;

      final lead = CustomerLead(
        id: '',
        customerId: profile.id,
        leadNumber: 'L-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        service: service,
        branch: branch,
        budget: budget,
        eventDate: eventDate,
        status: 'Pending',
      );

      await _portalRepo.createCustomerLead(lead);
      await logActivity('Lead Created', 'Created a new lead inquiry for $service.');
      Get.snackbar("Success", "Inquiry submitted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit inquiry: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitReview({
    required String bookingId,
    required String reviewText,
    required double rating,
  }) async {
    try {
      isLoading.value = true;
      final profile = rxProfile.value;
      if (profile == null) return;

      await _portalRepo.submitCustomerReview(profile.id, bookingId, reviewText, rating);
      await logActivity('Review', 'Submitted a booking review.');
      Get.snackbar("Success", "Review submitted for verification");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit review: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Quotation Management
  Future<void> acceptQuotation(String quoteId) async {
    try {
      isLoading.value = true;
      await _portalRepo.updateQuotationStatus(quoteId, 'accepted');
      await logActivity('Quotation', 'Accepted quotation ID: $quoteId');
      Get.snackbar("Success", "Quotation accepted.");
    } catch (e) {
      Get.snackbar("Error", "Failed to accept quotation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectQuotation(String quoteId) async {
    try {
      isLoading.value = true;
      await _portalRepo.updateQuotationStatus(quoteId, 'rejected');
      await logActivity('Quotation', 'Rejected quotation ID: $quoteId');
      Get.snackbar("Success", "Quotation rejected.");
    } catch (e) {
      Get.snackbar("Error", "Failed to reject quotation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestRevision(String quoteId, String revisionNotes) async {
    try {
      isLoading.value = true;
      await _portalRepo.updateQuotationStatus(quoteId, 'revision_requested');
      await logActivity('Quotation', 'Requested revision for quote: $quoteId. Notes: $revisionNotes');
      Get.snackbar("Success", "Revision request submitted.");
    } catch (e) {
      Get.snackbar("Error", "Failed to request revision: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Payments Management
  Future<void> payOffline({
    required String bookingId,
    required double amount,
    required String method,
    required String receiptUrl,
  }) async {
    try {
      isLoading.value = true;
      final profile = rxProfile.value;
      if (profile == null) return;

      final payment = CustomerPayment(
        id: '',
        customerId: profile.id,
        bookingId: bookingId,
        amount: amount,
        status: 'pending',
        method: method,
        receiptUrl: receiptUrl,
        invoiceUrl: '',
        paymentDate: DateTime.now(),
      );

      await _portalRepo.submitOfflinePayment(payment);
      await logActivity('Payment', 'Submitted offline payment of ₹$amount via $method.');
      Get.snackbar("Success", "Payment receipt uploaded. Admin review pending.");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload payment receipt: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Wishlist Actions
  Future<void> addWishlist(String decorationId) async {
    try {
      final profile = rxProfile.value;
      if (profile == null) return;

      final item = CustomerWishlist(
        id: '',
        customerId: profile.id,
        experienceId: decorationId,
        addedAt: DateTime.now(),
      );
      await _portalRepo.addToWishlist(item);
      Get.snackbar("Added", "Item saved to wishlist.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> removeWishlist(String wishlistId) async {
    try {
      await _portalRepo.removeFromWishlist(wishlistId);
      Get.snackbar("Removed", "Item removed from wishlist.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Rebooking
  Future<void> requestRebook(String bookingId, DateTime newDate) async {
    try {
      isLoading.value = true;
      final profile = rxProfile.value;
      if (profile == null) return;

      final request = RebookRequest(
        id: '',
        customerId: profile.id,
        previousBookingId: bookingId,
        newDate: newDate,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      await _portalRepo.submitRebookRequest(request);
      await logActivity('Rebook', 'Submitted a rebooking request for date: ${newDate.toLocal()}');
      Get.snackbar("Success", "Rebooking request submitted.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Activity Logger
  Future<void> logActivity(String status, String details) async {
    final profile = rxProfile.value;
    if (profile == null) return;

    final activity = CustomerActivity(
      id: '',
      customerId: profile.id,
      status: status,
      updatedAt: DateTime.now(),
      details: details,
    );
    await _portalRepo.logCustomerActivity(activity);
  }

  // Notifications
  Future<void> markNotificationRead(String id) async {
    await _portalRepo.updateNotificationStatus(id, isRead: true);
  }
}
