import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../data/models/customer_profile_model.dart';
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
        if (profile.id.isEmpty) {
          Get.snackbar("Authentication Error", "User UID not found. Cannot load customer data.");
          _clearAll();
          return;
        }
        syncMasterData(profile);
        _bindStreams(profile.id, profile.branch, profile.phone);
      } else {
        _clearAll();
      }
    });

    if (_authController.rxCustomerProfile.value != null) {
      rxProfile.value = _authController.rxCustomerProfile.value;
      if (rxProfile.value!.id.isEmpty) {
        Get.snackbar("Authentication Error", "User UID not found. Cannot load customer data.");
        _clearAll();
      } else {
        syncMasterData(rxProfile.value!);
        _bindStreams(rxProfile.value!.id, rxProfile.value!.branch, rxProfile.value!.phone);
      }
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
    rxNotifications.bindStream(_portalRepo.streamCustomerNotifications(customerId).handleError(_logErr).map((d) { logFetch('notifications', d); return d; }));
    rxDocuments.bindStream(_portalRepo.streamCustomerDocuments(customerId).handleError(_logErr).map((d) { logFetch('documents', d); return d; }));
    rxWishlist.bindStream(_portalRepo.streamCustomerWishlist(customerId).handleError(_logErr).map((d) { logFetch('wishlist', d); return d; }));
    rxOffers.bindStream(_portalRepo.streamOffers(branch).handleError(_logErr).map((d) { logFetch('offers', d); return d; }));
    rxActivity.bindStream(_portalRepo.streamCustomerActivity(customerId).handleError(_logErr).map((d) { logFetch('activity', d); return d; }));
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
  }
}
