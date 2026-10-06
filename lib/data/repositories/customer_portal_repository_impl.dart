import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/customer_lead.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/entities/customer_document.dart';
import '../../domain/entities/customer_wishlist.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/customer_activity.dart';
import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/customer_portal_repository.dart';
import '../../core/utils/app_logger.dart';
import '../models/customer_lead_model.dart';
import '../models/customer_portal_models.dart';

class CustomerPortalRepositoryImpl implements CustomerPortalRepository {
  final FirebaseFirestore _firestore;

  CustomerPortalRepositoryImpl(this._firestore);

  @override
  Stream<List<CustomerLead>> streamCustomerLeads(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppCollections.customerLeads)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => CustomerLeadModel.fromJson(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        })
        .handleError((e) {
          AppLogger.warning("Failed to stream customer leads for $customerId: $e");
          return <CustomerLead>[];
        });
  }

  @override
  Future<void> createCustomerLead(CustomerLead lead) async {
    final docRef = lead.id.isNotEmpty
        ? _firestore.collection(AppCollections.customerLeads).doc(lead.id)
        : _firestore.collection(AppCollections.customerLeads).doc();
    final leadId = docRef.id;

    final model = CustomerLeadModel(
      id: leadId,
      customerId: lead.customerId,
      customerName: lead.customerName,
      customerEmail: lead.customerEmail,
      customerPhone: lead.customerPhone,
      leadNumber: lead.leadNumber.isNotEmpty
          ? lead.leadNumber
          : 'L-${DateTime.now().millisecondsSinceEpoch}',
      date: lead.date,
      service: lead.service,
      branch: lead.branch,
      budget: lead.budget,
      eventDate: lead.eventDate,
      status: lead.status.isNotEmpty ? lead.status : 'Pending',
      adminNotes: lead.adminNotes,
      serviceId: lead.serviceId,
      serviceSlug: lead.serviceSlug,
      imageUrl: lead.imageUrl,
      categoryId: lead.categoryId,
    );

    // 1. Write to canonical customer_leads collection
    await docRef.set(model.toJson());

    // 2. Also mirror to admin CRM leads collection for unified back-office visibility
    try {
      await _firestore.collection(AppCollections.leads).doc(leadId).set({
        'id': leadId,
        'name': model.customerName.isNotEmpty ? model.customerName : 'Valued Client',
        'phone': model.customerPhone,
        'email': model.customerEmail,
        'requestType': 'consultation',
        'requirements': model.service,
        'branch': model.branch,
        'budget': model.budget,
        'eventDate': model.eventDate.toIso8601String(),
        'status': 'new',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'customerId': model.customerId,
        'serviceId': model.serviceId,
        'serviceSlug': model.serviceSlug,
        'imageUrl': model.imageUrl,
        'categoryId': model.categoryId,
      });
    } catch (e) {
      AppLogger.warning("Failed to mirror inquiry to admin leads: $e");
    }
  }

  @override
  Future<void> submitCustomerReview(
      String customerId, String quotationId, String reviewText, double rating) async {
    String customerName = 'Valued Customer';
    String eventName = 'Event Decor';
    String experienceId = '';

    try {
      if (customerId.isNotEmpty) {
        final custDoc = await _firestore.collection(AppCollections.customers).doc(customerId).get();
        if (custDoc.exists && custDoc.data() != null) {
          final cd = custDoc.data()!;
          customerName = cd['fullName'] ?? cd['name'] ?? customerName;
        }
      }
      if (quotationId.isNotEmpty) {
        final quoteDoc = await _firestore.collection(AppCollections.quotations).doc(quotationId).get();
        if (quoteDoc.exists && quoteDoc.data() != null) {
          final qd = quoteDoc.data()!;
          final items = qd['items'];
          if (items is List && items.isNotEmpty && items.first is Map) {
            eventName = items.first['name'] ?? eventName;
            experienceId = items.first['experienceId'] ?? '';
          }
        }
      }
    } catch (_) {}

    final now = DateTime.now();

    // 1. Canonical write to AppCollections.reviews (moderated in Admin Studio)
    await _firestore.collection(AppCollections.reviews).add({
      'customer_name': customerName,
      'event_name': eventName,
      'rating': rating,
      'comment': reviewText,
      'image_url': '',
      'is_verified': true,
      'is_published': false, // Requires admin moderation before public display
      'experience_id': experienceId,
      'quotation_id': quotationId,
      'customer_id': customerId,
      'created_at': now.toIso8601String(),
      'is_featured': false,
      'display_order': 1,
      'is_active': true,
    });

    // 2. Dual-write to customer_reviews for complete backward compatibility
    final docRef = _firestore.collection(AppCollections.customerReviews).doc();
    await docRef.set({
      'customerId': customerId,
      'quotationId': quotationId,
      'customerName': customerName,
      'reviewText': reviewText,
      'rating': rating,
      'status': 'Pending Moderation',
      'createdAt': now.toIso8601String(),
    });
  }

  @override
  Stream<List<CustomerNotification>> streamCustomerNotifications(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppCollections.customerNotifications)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerNotificationModel.fromJson(doc.data(), doc.id))
            .toList())
        .handleError((e) {
          AppLogger.warning("Failed to stream notifications for $customerId: $e");
          return <CustomerNotification>[];
        });
  }

  @override
  Future<void> updateNotificationStatus(String id, {required bool isRead}) async {
    try {
      await _firestore
          .collection(AppCollections.customerNotifications)
          .doc(id)
          .update({'isRead': isRead});
    } catch (e) {
      AppLogger.warning("Failed to update notification $id: $e");
    }
  }

  @override
  Stream<List<CustomerDocument>> streamCustomerDocuments(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppCollections.customerDocuments)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerDocumentModel.fromJson(doc.data(), doc.id))
            .toList())
        .handleError((e) {
          AppLogger.warning("Failed to stream customer documents for $customerId: $e");
          return <CustomerDocument>[];
        });
  }

  @override
  Stream<List<CustomerWishlist>> streamCustomerWishlist(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppCollections.customerWishlist)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map<CustomerWishlist>((doc) => CustomerWishlistModel.fromJson(doc.data(), doc.id))
            .toList())
        .handleError((e) {
          AppLogger.warning("Failed to stream customer wishlist for $customerId: $e");
          return <CustomerWishlist>[];
        });
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
            .toList())
        .handleError((e) {
          AppLogger.warning("Failed to stream offers for $branch: $e");
          return <Offer>[];
        });
  }

  @override
  Stream<List<CustomerActivity>> streamCustomerActivity(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppCollections.customerActivity)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerActivityModel.fromJson(doc.data(), doc.id))
            .toList())
        .handleError((e) {
          AppLogger.warning("Failed to stream activity for $customerId: $e");
          return <CustomerActivity>[];
        });
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

  @override
  Stream<List<SupportTicket>> streamCustomerTickets(String customerId) {
    if (customerId.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppCollections.supportTickets)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SupportTicketModel.fromJson(doc.data(), doc.id))
            .toList())
        .handleError((e) {
          AppLogger.warning("Failed to stream support tickets for $customerId: $e");
          return <SupportTicket>[];
        });
  }

  @override
  Future<void> createSupportTicket(SupportTicket ticket) async {
    final model = SupportTicketModel(
      id: ticket.id,
      customerId: ticket.customerId,
      subject: ticket.subject,
      status: ticket.status.isNotEmpty ? ticket.status : 'Open',
      messages: ticket.messages,
      createdAt: ticket.createdAt,
    );
    final docRef = ticket.id.isEmpty
        ? _firestore.collection(AppCollections.supportTickets).doc()
        : _firestore.collection(AppCollections.supportTickets).doc(ticket.id);
    await docRef.set(model.toJson());
  }

  @override
  Future<void> replySupportTicket(String ticketId, String message) async {
    if (ticketId.isEmpty || message.trim().isEmpty) return;
    await _firestore.collection(AppCollections.supportTickets).doc(ticketId).update({
      'messages': FieldValue.arrayUnion([message]),
    });
  }

  @override
  Future<void> closeSupportTicket(String ticketId) async {
    if (ticketId.isEmpty) return;
    await _firestore.collection(AppCollections.supportTickets).doc(ticketId).update({
      'status': 'Closed',
    });
  }
}
