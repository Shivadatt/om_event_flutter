import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/feature_flags.dart';
import '../../core/constants/app_collections.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../domain/entities/customer_lead.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/customer_document.dart';
import '../../domain/entities/customer_wishlist.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/customer_activity.dart';
import '../../domain/entities/support_ticket.dart';
import '../../data/models/customer_profile_model.dart';
import '../../data/models/customer_portal/payment_and_activity.dart';
import '../../data/datasources/supabase_storage_source.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/services/inquiry_image_resolver.dart';
import '../screens/customer/widgets/customer_login_required_dialog.dart';
import '../../core/utils/auth_route_helper.dart';
import 'customer_auth_controller.dart';

part 'parts/customer_sync.dart';
part 'parts/customer_actions.dart';

class CustomerDashboardController extends GetxController {
  final CustomerPortalRepository _portalRepo;
  final CustomerAuthRepository _authRepo;
  final CustomerAuthController _authController;
  final QuotationRepository _quotationRepo;

  CustomerDashboardController(
    this._portalRepo,
    this._authRepo,
    this._authController,
    this._quotationRepo,
  );

  final rxLeads = <CustomerLead>[].obs;
  final rxQuotations = <Quotation>[].obs;
  final rxNotifications = <CustomerNotification>[].obs;
  final rxDocuments = <CustomerDocument>[].obs;
  final rxWishlist = <CustomerWishlist>[].obs;
  final rxOffers = <Offer>[].obs;
  final rxActivity = <CustomerActivity>[].obs;
  final rxTickets = <SupportTicket>[].obs;

  final rxProfile = Rxn<CustomerProfile>();
  final isLoading = false.obs;
  final rxPreferences = <String, dynamic>{}.obs;
  final isPreferencesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.rxCustomerProfile, (profile) {
      rxProfile.value = profile;
      if (profile != null) {
        final isGuest = profile.id.isEmpty ||
            profile.id.startsWith('guest_') ||
            FirebaseAuth.instance.currentUser == null;
        if (isGuest) {
          _clearAll();
          return;
        }
        syncMasterData(profile);
        _bindStreams(profile.id, profile.branch, profile.phone);
      } else {
        _clearAll();
      }
    });

    final currentProfile = _authController.rxCustomerProfile.value;
    if (currentProfile != null) {
      rxProfile.value = currentProfile;
      final isGuest = currentProfile.id.isEmpty ||
          currentProfile.id.startsWith('guest_') ||
          FirebaseAuth.instance.currentUser == null;
      if (isGuest) {
        _clearAll();
      } else {
        syncMasterData(currentProfile);
        _bindStreams(currentProfile.id, currentProfile.branch, currentProfile.phone);
      }
    } else {
      ensureProfileLoaded();
    }
  }

  Future<void> ensureProfileLoaded() async {
    if (rxProfile.value != null) return;
    if (AuthRouteHelper.isCurrentAdminOrStaff()) return;

    isLoading.value = true;
    try {
      await _authController.checkAuthStatus();
      var profile = _authController.rxCustomerProfile.value;
      if (profile == null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && !AuthRouteHelper.isCurrentAdminOrStaff()) {
          profile = await _authRepo.getCustomerProfile(user.uid);
          if (profile != null) {
            _authController.rxCustomerProfile.value = profile;
          }
        }
      }
      if (profile != null) {
        rxProfile.value = profile;
        final isGuest = profile.id.isEmpty ||
            profile.id.startsWith('guest_') ||
            FirebaseAuth.instance.currentUser == null;
        if (!isGuest) {
          syncMasterData(profile);
          _bindStreams(profile.id, profile.branch, profile.phone);
        }
      } else if (!AuthRouteHelper.isCurrentAdminOrStaff()) {
        final user = FirebaseAuth.instance.currentUser;
        final fallback = CustomerProfileModel(
          id: user?.uid ?? 'guest',
          fullName: (user?.displayName?.isNotEmpty == true)
              ? user!.displayName!
              : (user?.email?.split('@').first ?? 'Valued Client'),
          phone: user?.phoneNumber ?? '',
          email: user?.email ?? '',
          gender: '',
          address: '',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '',
          branch: '',
          profileImageUrl: user?.photoURL ?? '',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        rxProfile.value = fallback;
      }
    } catch (e) {
      AppLogger.warning("ensureProfileLoaded error: $e");
    } finally {
      isLoading.value = false;
    }
  }



  void _bindStreams(String customerId, String branch, String phone) {
    final startTime = DateTime.now();

    void logFetch(String name, dynamic data) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final length = (data is Iterable) ? data.length : (data != null ? 1 : 0);
      AppLogger.info("TIME_LOG [$name]: Fetched $length records in ${elapsed}ms", layer: LogLayer.controller, className: "CustomerDashboardController", methodName: "_bindStreams");
    }

    rxLeads.bindStream(_portalRepo.streamCustomerLeads(customerId).handleError(_logErr).map((d) { logFetch('leads', d); return d; }));
    rxQuotations.bindStream(_quotationRepo.streamCustomerQuotations(customerId).handleError(_logErr).map((d) { logFetch('quotations', d); return d; }));
    // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
    // REASON: Not required for current business flow.
    // DO NOT DELETE - Keep for future reactivation.
    if (FeatureFlags.notifications) {
      rxNotifications.bindStream(_portalRepo.streamCustomerNotifications(customerId).handleError(_logErr).map((d) { logFetch('notifications', d); return d; }));
    }
    rxDocuments.bindStream(_portalRepo.streamCustomerDocuments(customerId).handleError(_logErr).map((d) { logFetch('documents', d); return d; }));
    rxWishlist.bindStream(_portalRepo.streamCustomerWishlist(customerId).handleError(_logErr).map((d) { logFetch('wishlist', d); return List<CustomerWishlist>.from(d); }));
    rxOffers.bindStream(_portalRepo.streamOffers(branch).handleError(_logErr).map((d) { logFetch('offers', d); return d; }));
    rxActivity.bindStream(_portalRepo.streamCustomerActivity(customerId).handleError(_logErr).map((d) { logFetch('activity', d); return d; }));
    rxTickets.bindStream(_portalRepo.streamCustomerTickets(customerId).handleError(_logErr).map((d) { logFetch('tickets', d); return d; }));
  }

  void _logErr(e) => AppLogger.errorDetailed("CustomerDashboard stream ERROR", error: e, layer: LogLayer.controller, className: "CustomerDashboardController", methodName: "_logErr");

  void _clearAll() {
    rxLeads.clear();
    rxQuotations.clear();
    rxNotifications.clear();
    rxDocuments.clear();
    rxWishlist.clear();
    rxOffers.clear();
    rxActivity.clear();
    rxTickets.clear();
  }
}
