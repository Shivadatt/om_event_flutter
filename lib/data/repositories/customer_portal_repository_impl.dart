import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/customer_lead.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/customer_document.dart';
import '../../domain/entities/customer_wishlist.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/customer_activity.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../models/customer_lead_model.dart';
import '../models/customer_portal_models.dart';

class CustomerPortalRepositoryImpl implements CustomerPortalRepository {
  final FirebaseFirestore _firestore;

  CustomerPortalRepositoryImpl(this._firestore);

  @override
  Stream<List<CustomerLead>> streamCustomerLeads(String customerId) {
    return _firestore
        .collection(AppCollections.customerLeads)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerLeadModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> createCustomerLead(CustomerLead lead) async {
    final model = CustomerLeadModel(
      id: lead.id,
      customerId: lead.customerId,
      leadNumber: lead.leadNumber,
      date: lead.date,
      service: lead.service,
      branch: lead.branch,
      budget: lead.budget,
      eventDate: lead.eventDate,
      status: lead.status,
      adminNotes: lead.adminNotes,
    );
    await _firestore
        .collection(AppCollections.customerLeads)
        .doc(lead.id.isEmpty ? null : lead.id)
        .set(model.toJson());
  }

  @override
  Future<void> submitCustomerReview(
      String customerId, String quotationId, String reviewText, double rating) async {
    final docRef = _firestore.collection(AppCollections.customerReviews).doc();
    await docRef.set({
      'customerId': customerId,
      'quotationId': quotationId,
      'reviewText': reviewText,
      'rating': rating,
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<List<CustomerNotification>> streamCustomerNotifications(String customerId) {
    return _firestore
        .collection(AppCollections.customerNotifications)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerNotificationModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> updateNotificationStatus(String id, {required bool isRead}) async {
    await _firestore
        .collection(AppCollections.customerNotifications)
        .doc(id)
        .update({'isRead': isRead});
  }

  @override
  Stream<List<CustomerDocument>> streamCustomerDocuments(String customerId) {
    return _firestore
        .collection(AppCollections.customerDocuments)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerDocumentModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<CustomerWishlist>> streamCustomerWishlist(String customerId) {
    return _firestore
        .collection(AppCollections.customerWishlist)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerWishlistModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addToWishlist(CustomerWishlist item) async {
    final model = CustomerWishlistModel(
      id: item.id,
      customerId: item.customerId,
      experienceId: item.experienceId,
      addedAt: item.addedAt,
    );
    await _firestore
        .collection(AppCollections.customerWishlist)
        .doc(item.id.isEmpty ? null : item.id)
        .set(model.toJson());
  }

  @override
  Future<void> removeFromWishlist(String wishlistId) async {
    await _firestore
        .collection(AppCollections.customerWishlist)
        .doc(wishlistId)
        .delete();
  }

  @override
  Stream<List<Offer>> streamOffers(String branch) {
    return _firestore
        .collection(AppCollections.offers)
        .where('branch', isEqualTo: branch)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => OfferModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<CustomerActivity>> streamCustomerActivity(String customerId) {
    return _firestore
        .collection(AppCollections.customerActivity)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerActivityModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> logCustomerActivity(CustomerActivity activity) async {
    final model = CustomerActivityModel(
      id: activity.id,
      customerId: activity.customerId,
      status: activity.status,
      updatedAt: activity.updatedAt,
      details: activity.details,
    );
    await _firestore
        .collection(AppCollections.customerActivity)
        .doc(activity.id.isEmpty ? null : activity.id)
        .set(model.toJson());
  }
}
