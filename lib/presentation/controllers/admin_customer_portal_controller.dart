import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../data/models/customer_portal_models.dart';
import '../../data/models/quotation_model.dart';
import '../../domain/entities/quotation.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/customer_activity.dart';

class AdminCustomerPortalController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final rxAllQuotes = <Quotation>[].obs;
  final rxAllNotifications = <CustomerNotification>[].obs;
  final rxAllOffers = <Offer>[].obs;
  final rxAllActivities = <CustomerActivity>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _bindAdminStreams();
  }

  void _bindAdminStreams() {
    rxAllQuotes.bindStream(_firestore.collection(AppCollections.quotations).snapshots().map((snap) =>
        snap.docs.map((doc) => QuotationModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllNotifications.bindStream(_firestore.collection(AppCollections.customerNotifications).snapshots().map((snap) =>
        snap.docs.map((doc) => CustomerNotificationModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllOffers.bindStream(_firestore.collection(AppCollections.offers).snapshots().map((snap) =>
        snap.docs.map((doc) => OfferModel.fromJson(doc.data(), doc.id)).toList()));

    rxAllActivities.bindStream(_firestore.collection(AppCollections.customerActivity).snapshots().map((snap) =>
        snap.docs.map((doc) => CustomerActivityModel.fromJson(doc.data(), doc.id)).toList()));
  }

  // 1. Quotation Admin Panel
  Future<void> adminCreateQuotation(Quotation quote) async {
    final model = QuotationModel(
      id: '',
      publicId: quote.publicId,
      customerPhone: quote.customerPhone,
      customerName: quote.customerName,
      eventDate: quote.eventDate,
      eventTime: quote.eventTime,
      location: quote.location,
      notes: quote.notes,
      subtotal: quote.subtotal,
      discount: quote.discount,
      deliveryCharge: quote.deliveryCharge,
      travelCharge: quote.travelCharge,
      gstPercent: quote.gstPercent,
      gstAmount: quote.gstAmount,
      grandTotal: quote.grandTotal,
      pdfUrl: quote.pdfUrl,
      status: quote.status,
      items: quote.items.map((e) => QuotationItemModel(
        experienceId: e.experienceId,
        name: e.name,
        quantity: e.quantity,
        unitPrice: e.unitPrice,
        color: e.color,
        theme: e.theme,
        notes: e.notes,
      )).toList(),
      createdAt: quote.createdAt,
      updatedAt: quote.updatedAt,
      customerId: quote.customerId,
      versions: quote.versions,
    );
    await _firestore.collection(AppCollections.quotations).add(model.toJson());
  }

  Future<void> adminUpdateQuotation(String id, Map<String, dynamic> data) async {
    if (data.containsKey('status')) {
      final targetStatus = QuotationStatus.fromString(data['status']);
      if (targetStatus == QuotationStatus.acceptedByClient || targetStatus == QuotationStatus.rejectedByClient) {
        throw Exception("Customer acceptance or rejection must always originate from the Client Portal.");
      }
      if (targetStatus == QuotationStatus.bookingConfirmed) {
        final snap = await _firestore.collection(AppCollections.quotations).doc(id).get();
        if (snap.exists) {
          final currentStatus = QuotationStatus.fromString(snap.data()?['status'] ?? 'draft');
          final acceptedAt = snap.data()?['acceptedAt'];
          if (currentStatus != QuotationStatus.acceptedByClient || acceptedAt == null) {
            throw Exception("Booking can only be confirmed after client has legally accepted the proposal with digital consent.");
          }
        }
      }
    }
    await _firestore.collection(AppCollections.quotations).doc(id).update(data);
  }

  Future<void> adminDeleteQuotation(String id) async {
    await _firestore.collection(AppCollections.quotations).doc(id).delete();
  }

  // 2. Notifications Composer Admin
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

  // 3. Offers & Banner Editor Admin
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
}
