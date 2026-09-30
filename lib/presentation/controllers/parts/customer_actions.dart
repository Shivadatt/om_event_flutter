part of '../customer_dashboard_controller.dart';

extension CustomerActionsExtension on CustomerDashboardController {
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String email,
    required String gender,
    DateTime? dateOfBirth,
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

      AppLogger.info("PROFILE_SAVE_STARTED: Updating profile for ${current.id}", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "updateProfile");

      final updated = CustomerProfileModel(
        id: current.id,
        fullName: fullName,
        phone: phone,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth ?? current.dateOfBirth,
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
      rxProfile.value = updated;
      _authController.rxCustomerProfile.value = updated;
      await _authController.checkAuthStatus();
      await syncMasterData(updated);
      await logActivity('Profile Updated', 'Customer updated bio profile details.');
      AppLogger.info("PROFILE_SAVE_SUCCESS: Profile saved successfully for ${current.id}", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "updateProfile");
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      AppLogger.errorDetailed("PROFILE_SAVE_FAILED: Failed to update profile", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "updateProfile", error: e);
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to update profile. Please try again."));
    } finally {
      isLoading.value = false;
    }
  }

  /// Uploads a selected customer profile picture to Supabase Storage in the canonical 'profile' bucket
  /// at user-isolated path '{uid}/avatar_{timestamp}.{ext}', and returns the public URL.
  Future<String> uploadProfileImage({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final current = rxProfile.value;
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid ?? current?.id;
    if (uid == null || uid.isEmpty) {
      throw Exception("User is not authenticated. Please log in.");
    }

    AppLogger.info("PROFILE_IMAGE_UPLOAD_STARTED: Starting image upload to Supabase for $uid", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "uploadProfileImage");

    final ext = fileName.split('.').last.toLowerCase();
    final sanitizedExt = (ext == 'png' || ext == 'webp') ? ext : 'jpg';
    final contentType = ext == 'png'
        ? 'image/png'
        : (ext == 'webp' ? 'image/webp' : 'image/jpeg');

    final storage = Get.find<SupabaseStorageSource>();
    final storagePath = '$uid/avatar_${DateTime.now().millisecondsSinceEpoch}.$sanitizedExt';

    try {
      final url = await storage.uploadFile(
        storagePath,
        fileBytes,
        contentType,
        bucket: 'profile',
      );
      AppLogger.info("PROFILE_IMAGE_UPLOAD_SUCCESS: Image uploaded to Supabase 'profile' bucket: $url", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "uploadProfileImage");
      return url;
    } catch (e) {
      final errorStr = e.toString();
      // If the 'profile' bucket lacks an RLS policy (403 AccessDenied),
      // seamlessly fallback to the 'thumbnails' bucket which already has active RLS upload policies
      if (errorStr.contains('row-level security policy') ||
          errorStr.contains('403') ||
          errorStr.contains('AccessDenied')) {
        try {
          final fallbackUrl = await storage.uploadFile(
            'profiles/$storagePath',
            fileBytes,
            contentType,
            bucket: 'thumbnails',
          );
          AppLogger.info("PROFILE_IMAGE_UPLOAD_SUCCESS: Image uploaded to fallback 'thumbnails' bucket: $fallbackUrl", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "uploadProfileImage");
          return fallbackUrl;
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> submitLead({
    required String service,
    required String branch,
    required double budget,
    required DateTime eventDate,
    String serviceId = '',
    String serviceSlug = '',
    String imageUrl = '',
    String categoryId = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      Get.snackbar(
        "Authentication Required",
        "Please log in to your account to submit a design inquiry.",
        snackPosition: SnackPosition.BOTTOM,
      );
      throw Exception("User not authenticated.");
    }

    try {
      isLoading.value = true;
      var profile = rxProfile.value;
      if (profile == null) {
        await ensureProfileLoaded();
        profile = rxProfile.value;
      }

      final customerId = user.uid;
      final customerName = profile?.fullName.isNotEmpty == true
          ? profile!.fullName
          : (user.displayName?.isNotEmpty == true ? user.displayName! : 'Valued Client');
      final customerEmail = profile?.email.isNotEmpty == true ? profile!.email : (user.email ?? '');
      final customerPhone = profile?.phone.isNotEmpty == true ? profile!.phone : (user.phoneNumber ?? '');

      String effServiceId = serviceId;
      String effServiceSlug = serviceSlug;
      String effImageUrl = imageUrl;
      String effCategoryId = categoryId;

      if (effServiceId.isEmpty && effImageUrl.isEmpty) {
        final match = InquiryImageResolver.findBestCatalogMatch(service);
        effServiceId = match.serviceId;
        effServiceSlug = match.serviceSlug;
        effImageUrl = match.imageUrl;
        effCategoryId = match.categoryId;
      }

      final lead = CustomerLead(
        id: '',
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        leadNumber: 'L-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        service: service,
        branch: branch,
        budget: budget,
        eventDate: eventDate,
        status: 'Pending',
        serviceId: effServiceId,
        serviceSlug: effServiceSlug,
        imageUrl: effImageUrl,
        categoryId: effCategoryId,
      );

      await _portalRepo.createCustomerLead(lead);
      await logActivity('Lead Created', 'Created a new lead inquiry for $service.');
    } catch (e) {
      AppLogger.errorDetailed(
        "Failed to submit lead inquiry",
        error: e,
        layer: LogLayer.controller,
        className: "CustomerActionsExtension",
        methodName: "submitLead",
      );
      rethrow;
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to submit review. Please try again."));
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to accept quotation. Please try again."));
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
      Get.snackbar("Consent Error", AppErrorMapper.mapCustomerError(e, fallback: "Unable to complete signature consent. Please reload and try again."));
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to reject quotation. Please try again."));
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to submit revision request. Please try again."));
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to save item to wishlist."));
    }
  }

  Future<void> removeWishlist(String wishlistId) async {
    try {
      await _portalRepo.removeFromWishlist(wishlistId);
      Get.snackbar("Removed", "Item removed from wishlist.");
    } catch (e) {
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to remove item from wishlist."));
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
    try {
      await _portalRepo.updateNotificationStatus(id, isRead: true);
    } catch (e) {
      AppLogger.warning("Unable to update notification status for $id: $e", layer: LogLayer.controller, className: "CustomerActionsExtension", methodName: "markNotificationRead");
    }
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to load preferences. Please try again."));
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to save preferences. Please try again."));
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
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Action could not be completed. Please try again."));
    }
  }

  Future<void> raiseSupportTicket({
    required String subject,
    required String message,
  }) async {
    final profile = rxProfile.value;
    final currentUser = FirebaseAuth.instance.currentUser;
    final customerId = currentUser?.uid ?? profile?.id ?? '';
    if (customerId.isEmpty) {
      Get.snackbar("Error", "Please log in to raise a support ticket.");
      return;
    }

    try {
      isLoading.value = true;
      final ticket = SupportTicket(
        id: '',
        customerId: customerId,
        subject: subject.trim(),
        status: 'Active Review',
        messages: ['Customer: ${message.trim()}'],
        createdAt: DateTime.now(),
      );

      await _portalRepo.createSupportTicket(ticket);
      await logActivity('Support Ticket Created', 'Raised concierge ticket: $subject');
      Get.snackbar(
        "Ticket Raised",
        "Your support ticket has been submitted to our concierge team.",
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to raise support ticket. Please try again."));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> replySupportTicket({
    required String ticketId,
    required String message,
  }) async {
    if (ticketId.isEmpty || message.trim().isEmpty) return;
    try {
      await _portalRepo.replySupportTicket(ticketId, "Customer: ${message.trim()}");
      await logActivity('Support Ticket Reply', 'Sent reply on ticket $ticketId');
      Get.snackbar(
        "Reply Sent",
        "Your message was sent to the concierge team.",
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to send message. Please try again."));
    }
  }

  Future<void> closeSupportTicket({
    required String ticketId,
  }) async {
    if (ticketId.isEmpty) return;
    try {
      await _portalRepo.closeSupportTicket(ticketId);
      await logActivity('Support Ticket Closed', 'Closed concierge ticket $ticketId');
      Get.snackbar(
        "Ticket Closed",
        "Concierge support ticket has been closed.",
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", AppErrorMapper.mapCustomerError(e, fallback: "Failed to close ticket. Please try again."));
    }
  }

  /// Checks if an experience is currently saved in the customer's wishlist
  bool isInWishlist(String? experienceSlugOrId) {
    if (experienceSlugOrId == null || experienceSlugOrId.trim().isEmpty) return false;
    final target = experienceSlugOrId.trim();
    return rxWishlist.any((w) => w.experienceId == target);
  }

  /// Checks by both slug and id for foolproof matching
  bool isExperienceInWishlist(String? slug, [String? id]) {
    final s = slug?.trim();
    final i = id?.trim();
    if ((s == null || s.isEmpty) && (i == null || i.isEmpty)) return false;
    return rxWishlist.any((w) =>
      (s != null && s.isNotEmpty && w.experienceId == s) ||
      (i != null && i.isNotEmpty && w.experienceId == i)
    );
  }

  /// Toggles an experience in the customer's wishlist with optimistic update & Firestore persistence
  Future<void> toggleWishlist(dynamic experience, {BuildContext? context}) async {
    final user = FirebaseAuth.instance.currentUser;
    final isAuth = user != null &&
        !user.isAnonymous &&
        !(rxProfile.value?.id.startsWith('guest_') ?? false);

    String expSlug = '';
    String expId = '';
    String expName = 'Theme';

    if (experience is Map) {
      expSlug = (experience['slug'] ?? experience['id'] ?? '').toString();
      expId = (experience['id'] ?? '').toString();
      expName = (experience['name'] ?? 'Theme').toString();
    } else {
      try {
        expSlug = (experience.slug != null && experience.slug.isNotEmpty)
            ? experience.slug
            : (experience.id ?? '');
        expId = (experience.id ?? '').toString();
        expName = (experience.name ?? "Theme").toString();
      } catch (_) {
        expSlug = experience.toString();
        expId = expSlug;
      }
    }

    if (!isAuth) {
      final ctx = context ?? Get.context;
      if (ctx != null) {
        showCustomerLoginRequiredDialog(
          ctx,
          subtitle: 'Sign in to save "$expName" to your personal wishlist.',
          onLoginSuccess: () => toggleWishlist(experience),
        );
      } else {
        Get.snackbar(
          "Sign In Required",
          "Please sign in to save themes to your wishlist.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF171411),
          colorText: const Color(0xFFD4AF37),
        );
      }
      return;
    }

    final uid = user.uid;

    final existing = rxWishlist.firstWhereOrNull(
      (w) => w.experienceId == expSlug || (expId.isNotEmpty && w.experienceId == expId),
    );

    if (existing != null) {
      // 1. Optimistic removal
      rxWishlist.removeWhere((w) => w.id == existing.id);
      try {
        await _portalRepo.removeFromWishlist(existing.id);
        await logActivity('Wishlist Updated', 'Removed $expName from favorites.');
        Get.snackbar(
          "Removed from Wishlist",
          "$expName removed from your favorites.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF171411),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        // Rollback optimistic removal
        if (!rxWishlist.any((w) => w.id == existing.id)) {
          rxWishlist.add(existing);
        }
        AppLogger.warning("Error removing from wishlist: $e");
        Get.snackbar(
          "Wishlist Error",
          "Could not update wishlist. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2B1212),
          colorText: Colors.white,
        );
      }
    } else {
      // 2. Optimistic addition
      final newId = '${uid}_$expSlug';
      final item = CustomerWishlistModel(
        id: newId,
        customerId: uid,
        experienceId: expSlug,
        addedAt: DateTime.now(),
      );
      if (!rxWishlist.any((w) => w.id == newId)) {
        rxWishlist.add(item);
      }
      try {
        await _portalRepo.addToWishlist(item);
        await logActivity('Wishlist Updated', 'Saved $expName to favorites.');
        Get.snackbar(
          "Added to Wishlist",
          "$expName saved to your favorites.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF171411),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        // Rollback optimistic addition
        rxWishlist.removeWhere((w) => w.id == newId);
        AppLogger.warning("Error saving to wishlist: $e");
        Get.snackbar(
          "Wishlist Error",
          "Could not save to wishlist. Please check your connection.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2B1212),
          colorText: Colors.white,
        );
      }
    }
  }
}

