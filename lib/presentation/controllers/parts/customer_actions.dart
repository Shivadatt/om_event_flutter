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
      await _quotationRepo.updateQuotationStatus(quoteId, 'acceptedByClient');
      await logActivity('Quotation', 'Accepted quotation ID: $quoteId');
      Get.snackbar("Success", "Quotation accepted.");
    } catch (e) {
      Get.snackbar("Error", "Failed to accept quotation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptQuotationWithConsent(
    String quoteId, {
    required String acceptedBy,
    required String acceptedDevice,
    required String acceptedIp,
    required String consentTextVersion,
    required double acceptedAmount,
    required int acceptedVersion,
  }) async {
    try {
      isLoading.value = true;
      final db = FirebaseFirestore.instance;

      // Security check: must not accept already accepted or outdated versions
      final quoteSnap = await db.collection(AppCollections.quotations).doc(quoteId).get();
      if (!quoteSnap.exists) {
        throw Exception("Quotation not found.");
      }
      final data = quoteSnap.data()!;
      final currentStatus = data['status'] ?? 'draft';
      final currentVersion = data['version'] ?? 1;

      if (currentStatus == 'acceptedByClient' || currentStatus == 'bookingConfirmed') {
        throw Exception("This quotation has already been accepted.");
      }

      if (acceptedVersion != currentVersion) {
        throw Exception("Cannot accept outdated version v$acceptedVersion. Current version is v$currentVersion. Please reload.");
      }

      await db.collection(AppCollections.quotations).doc(quoteId).update({
        'acceptedAt': DateTime.now().toIso8601String(),
        'acceptedVersion': acceptedVersion,
        'acceptedAmount': acceptedAmount,
        'acceptedBy': acceptedBy,
        'acceptedDevice': acceptedDevice,
        'acceptedIp': acceptedIp,
        'consentTextVersion': consentTextVersion,
      });

      await _quotationRepo.updateQuotationStatus(quoteId, 'acceptedByClient');
      await logActivity('Quotation', 'Legally accepted quotation ID: $quoteId (v$acceptedVersion) signed by $acceptedBy.');
      Get.snackbar("Success", "Proposal signed and accepted successfully.");
    } catch (e) {
      Get.snackbar("Consent Error", e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectQuotation(String quoteId) async {
    try {
      isLoading.value = true;
      await _quotationRepo.updateQuotationStatus(quoteId, 'rejectedByClient');
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
      final db = FirebaseFirestore.instance;
      // Pre-save revision fields so repository status transitions can capture them in history snapshots
      await db.collection(AppCollections.quotations).doc(quoteId).update({
        'revisionReason': revisionNotes,
        'revisionMessage': revisionNotes,
      });
      await _quotationRepo.updateQuotationStatus(quoteId, 'revisionRequested');
      await logActivity('Quotation', 'Requested revision for quote: $quoteId. Notes: $revisionNotes');
      Get.snackbar("Success", "Revision request submitted.");
    } catch (e) {
      Get.snackbar("Error", "Failed to request revision: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewQuotation(String quoteId, String currentStatus) async {
    try {
      final status = QuotationStatus.fromString(currentStatus);
      if (status == QuotationStatus.published || status == QuotationStatus.republished) {
        await _quotationRepo.updateQuotationStatus(quoteId, 'viewed');
      }
    } catch (_) {}
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

  Future<void> loadNotificationPreferences(String userId) async {
    try {
      isPreferencesLoading.value = true;
      final repo = Get.find<NotificationRepository>();
      final prefs = await repo.getPreferences(userId);
      if (prefs != null) {
        rxPreferences.value = prefs;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load preferences: $e");
    } finally {
      isPreferencesLoading.value = false;
    }
  }

  Future<void> saveNotificationPreferences(String userId, Map<String, dynamic> data) async {
    try {
      isPreferencesLoading.value = true;
      final repo = Get.find<NotificationRepository>();
      await repo.savePreferences(userId, data);
      rxPreferences.value = data;
      Get.snackbar(
        "Preferences Saved",
        "Your notification channel configurations have been updated.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to save: $e");
    } finally {
      isPreferencesLoading.value = false;
    }
  }

  Future<void> archiveNotification(String notificationId, bool archive) async {
    try {
      final repo = Get.find<NotificationRepository>();
      await repo.archiveNotification(notificationId, archive);
      Get.snackbar(
        archive ? "Archived" : "Restored",
        archive ? "Notification successfully archived." : "Notification restored to inbox.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
      );
    } catch (e) {
      Get.snackbar("Error", "Action failed: $e");
    }
  }
}
