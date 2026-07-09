import '../entities/customer_lead.dart';
import '../entities/customer_notification.dart';
import '../entities/customer_document.dart';
import '../entities/customer_wishlist.dart';
import '../entities/offer.dart';
import '../entities/customer_activity.dart';

abstract class CustomerPortalRepository {
  // Leads
  Stream<List<CustomerLead>> streamCustomerLeads(String customerId);
  Future<void> createCustomerLead(CustomerLead lead);

  // Reviews
  Future<void> submitCustomerReview(String customerId, String quotationId, String reviewText, double rating);

  // Notifications
  Stream<List<CustomerNotification>> streamCustomerNotifications(String customerId);
  Future<void> updateNotificationStatus(String id, {required bool isRead});

  // Documents
  Stream<List<CustomerDocument>> streamCustomerDocuments(String customerId);

  // Wishlist
  Stream<List<CustomerWishlist>> streamCustomerWishlist(String customerId);
  Future<void> addToWishlist(CustomerWishlist item);
  Future<void> removeFromWishlist(String wishlistId);

  // Offers
  Stream<List<Offer>> streamOffers(String branch);

  // Activity Timeline
  Stream<List<CustomerActivity>> streamCustomerActivity(String customerId);
  Future<void> logCustomerActivity(CustomerActivity activity);
}
