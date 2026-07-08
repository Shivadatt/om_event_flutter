import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/config/constants.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../../domain/entities/customer_lead.dart';
import '../../domain/entities/customer_booking.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/entities/customer_quotation.dart';
import '../../domain/entities/booking_timeline.dart';
import '../../domain/entities/customer_payment.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/customer_document.dart';
import '../../domain/entities/booking_gallery.dart';
import '../../domain/entities/customer_wishlist.dart';
import '../../domain/entities/rebook_request.dart';
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

  CustomerDashboardController(
    this._portalRepo,
    this._authRepo,
    this._authController,
  );

  final rxLeads = <CustomerLead>[].obs;
  final rxBookings = <CustomerBooking>[].obs;
  final rxQuotations = <CustomerQuotation>[].obs;
  final rxPayments = <CustomerPayment>[].obs;
  final rxNotifications = <CustomerNotification>[].obs;
  final rxDocuments = <CustomerDocument>[].obs;
  final rxWishlist = <CustomerWishlist>[].obs;
  final rxOffers = <Offer>[].obs;
  final rxActivity = <CustomerActivity>[].obs;

  final rxSelectedBookingTimeline = <BookingTimeline>[].obs;
  final rxSelectedBookingGallery = <BookingGallery>[].obs;

  final rxProfile = Rxn<CustomerProfile>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.rxCustomerProfile, (profile) {
      rxProfile.value = profile;
      if (profile != null) {
        syncMasterData(profile);
        _bindStreams(profile.id, profile.branch);
      } else {
        _clearAll();
      }
    });

    if (_authController.rxCustomerProfile.value != null) {
      rxProfile.value = _authController.rxCustomerProfile.value;
      syncMasterData(rxProfile.value!);
      _bindStreams(rxProfile.value!.id, rxProfile.value!.branch);
    }
  }

  void _bindStreams(String customerId, String branch) {
    rxLeads.bindStream(_portalRepo.streamCustomerLeads(customerId));
    rxBookings.bindStream(_portalRepo.streamCustomerBookings(customerId));
    rxQuotations.bindStream(_portalRepo.streamCustomerQuotations(customerId));
    rxPayments.bindStream(_portalRepo.streamCustomerPayments(customerId));
    rxNotifications.bindStream(_portalRepo.streamCustomerNotifications(customerId));
    rxDocuments.bindStream(_portalRepo.streamCustomerDocuments(customerId));
    rxWishlist.bindStream(_portalRepo.streamCustomerWishlist(customerId));
    rxOffers.bindStream(_portalRepo.streamOffers(branch));
    rxActivity.bindStream(_portalRepo.streamCustomerActivity(customerId));
  }

  void _clearAll() {
    rxLeads.clear();
    rxBookings.clear();
    rxQuotations.clear();
    rxPayments.clear();
    rxNotifications.clear();
    rxDocuments.clear();
    rxWishlist.clear();
    rxOffers.clear();
    rxActivity.clear();
    rxSelectedBookingTimeline.clear();
    rxSelectedBookingGallery.clear();
  }

  // Booking Timeline Selection
  void fetchBookingTimeline(String bookingId) {
    rxSelectedBookingTimeline.bindStream(_portalRepo.streamBookingTimeline(bookingId));
  }

  // Booking Gallery Selection
  void fetchBookingGallery(String bookingId) {
    rxSelectedBookingGallery.bindStream(_portalRepo.streamBookingGallery(bookingId));
  }
}
