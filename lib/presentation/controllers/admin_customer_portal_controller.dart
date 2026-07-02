import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../data/models/customer_portal_models.dart';
import '../../domain/entities/customer_quotation.dart';
import '../../domain/entities/booking_timeline.dart';
import '../../domain/entities/customer_payment.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/booking_gallery.dart';
import '../../domain/entities/rebook_request.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/customer_activity.dart';

class AdminCustomerPortalController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final rxAllQuotes = <CustomerQuotation>[].obs;
  final rxAllTimelines = <BookingTimeline>[].obs;
  final rxAllPayments = <CustomerPayment>[].obs;
  final rxAllNotifications = <CustomerNotification>[].obs;
  final rxAllRebookRequests = <RebookRequest>[].obs;
  final rxAllOffers = <Offer>[].obs;
  final rxAllActivities = <CustomerActivity>[].obs;
  final rxAllGalleries = <BookingGallery>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _bindAdminStreams();
  }

  void _bindAdminStreams() {
    // Stream ALL records for admin dashboard management
    rxAllQuotes.bindStream(_firestore.collection(AppCollections.customerQuotes).snapshots().map((snap) =>
        snap.docs.map((doc) => CustomerQuotationModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllTimelines.bindStream(_firestore.collection(AppCollections.bookingTimelines).snapshots().map((snap) =>
        snap.docs.map((doc) => BookingTimelineModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllPayments.bindStream(_firestore.collection(AppCollections.customerPayments).snapshots().map((snap) =>
        snap.docs.map((doc) => CustomerPaymentModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllNotifications.bindStream(_firestore.collection(AppCollections.customerNotifications).snapshots().map((snap) =>
        snap.docs.map((doc) => CustomerNotificationModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllRebookRequests.bindStream(_firestore.collection(AppCollections.rebookRequests).snapshots().map((snap) =>
        snap.docs.map((doc) => RebookRequestModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllOffers.bindStream(_firestore.collection(AppCollections.offers).snapshots().map((snap) =>
        snap.docs.map((doc) => OfferModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllActivities.bindStream(_firestore.collection(AppCollections.customerActivity).snapshots().map((snap) =>
        snap.docs.map((doc) => CustomerActivityModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllGalleries.bindStream(_firestore.collection(AppCollections.bookingGallery).snapshots().map((snap) =>
        snap.docs.map((doc) => BookingGalleryModel.fromJson(doc.data(), doc.id)).toList()));
  }

  // 1. Quotation Admin Panel
  Future<void> adminCreateQuotation(CustomerQuotation quote) async {
    final model = CustomerQuotationModel(
      id: '',
      customerId: quote.customerId,
      quotationNumber: quote.quotationNumber,
      date: quote.date,
      amount: quote.amount,
      status: quote.status,
      expiryDate: quote.expiryDate,
      pdfUrl: quote.pdfUrl,
      notes: quote.notes,
      versionHistory: quote.versionHistory,
    );
    await _firestore.collection(AppCollections.customerQuotes).add(model.toJson());
  }

  Future<void> adminUpdateQuotation(String id, Map<String, dynamic> data) async {
    await _firestore.collection(AppCollections.customerQuotes).doc(id).update(data);
  }

  Future<void> adminDeleteQuotation(String id) async {
    await _firestore.collection(AppCollections.customerQuotes).doc(id).delete();
  }

  // 2. Booking Timeline Admin
  Future<void> adminAddTimelineCheckpoint(String bookingId, String status, String notes) async {
    final checkpoint = BookingTimelineModel(
      id: '',
      bookingId: bookingId,
      status: status,
      updatedTime: DateTime.now(),
      notes: notes,
    );
    await _firestore.collection(AppCollections.bookingTimelines).add(checkpoint.toJson());
  }

  // 3. Payments Admin Verification
  Future<void> adminVerifyPayment(String id, String status) async {
    await _firestore.collection(AppCollections.customerPayments).doc(id).update({'status': status});
  }

  // 4. Notifications Composer Admin
  Future<void> adminSendNotification({
    required String customerId,
    required String title,
    required String body,
    required String type,
    String branch = '',
  }) async {
    final model = CustomerNotificationModel(
      id: '',
      customerId: customerId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      branch: branch,
      createdAt: DateTime.now(),
    );
    await _firestore.collection(AppCollections.customerNotifications).add(model.toJson());
  }

  // 5. Shared Booking Gallery Admin
  Future<void> adminUploadGalleryMedia(String bookingId, String customerId, String mediaUrl) async {
    final query = await _firestore
        .collection(AppCollections.bookingGallery)
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await _firestore.collection(AppCollections.bookingGallery).doc(docId).update({
        'mediaUrls': FieldValue.arrayUnion([mediaUrl]),
      });
    } else {
      final gallery = BookingGalleryModel(
        id: '',
        customerId: customerId,
        bookingId: bookingId,
        mediaUrls: [mediaUrl],
        createdAt: DateTime.now(),
      );
      await _firestore.collection(AppCollections.bookingGallery).add(gallery.toJson());
    }
  }

  // 6. Offers & Banner Editor Admin
  Future<void> adminSaveOffer(Offer offer, {bool isEdit = false}) async {
    final model = OfferModel(
      id: offer.id,
      title: offer.title,
      description: offer.description,
      imageUrl: offer.imageUrl,
      isActive: offer.isActive,
      priority: offer.priority,
      expiryDate: offer.expiryDate,
      branch: offer.branch,
    );
    if (isEdit) {
      await _firestore.collection(AppCollections.offers).doc(offer.id).update(model.toJson());
    } else {
      await _firestore.collection(AppCollections.offers).add(model.toJson());
    }
  }

  // 7. Rebook Approvals
  Future<void> adminApproveRebook(String requestId, String status) async {
    await _firestore.collection(AppCollections.rebookRequests).doc(requestId).update({'status': status});
  }
}
