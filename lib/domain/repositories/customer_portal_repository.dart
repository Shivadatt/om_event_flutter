import '../entities/customer_lead.dart';
import '../entities/customer_booking.dart';
import '../entities/customer_quotation.dart';
import '../entities/booking_timeline.dart';
import '../entities/customer_payment.dart';
import '../entities/customer_notification.dart';
import '../entities/customer_document.dart';
import '../entities/booking_gallery.dart';
import '../entities/customer_wishlist.dart';
import '../entities/rebook_request.dart';
import '../entities/offer.dart';
import '../entities/customer_activity.dart';

abstract class CustomerPortalRepository {
  // Leads
  Stream<List<CustomerLead>> streamCustomerLeads(String customerId);
  Future<void> createCustomerLead(CustomerLead lead);

  // Bookings
  Stream<List<CustomerBooking>> streamCustomerBookings(String customerId);

  // Reviews
  Future<void> submitCustomerReview(String customerId, String bookingId, String reviewText, double rating);

  // Quotations
  Stream<List<CustomerQuotation>> streamCustomerQuotations(String customerId);
  Future<void> updateQuotationStatus(String id, String status);

  // Booking Timeline
  Stream<List<BookingTimeline>> streamBookingTimeline(String bookingId);

  // Payments
  Stream<List<CustomerPayment>> streamCustomerPayments(String customerId);
  Future<void> submitOfflinePayment(CustomerPayment payment);

  // Notifications
  Stream<List<CustomerNotification>> streamCustomerNotifications(String customerId);
  Future<void> updateNotificationStatus(String id, {required bool isRead});

  // Documents
  Stream<List<CustomerDocument>> streamCustomerDocuments(String customerId);

  // Gallery
  Stream<List<BookingGallery>> streamBookingGallery(String bookingId);

  // Wishlist
  Stream<List<CustomerWishlist>> streamCustomerWishlist(String customerId);
  Future<void> addToWishlist(CustomerWishlist item);
  Future<void> removeFromWishlist(String wishlistId);

  // Rebook
  Future<void> submitRebookRequest(RebookRequest request);

  // Offers
  Stream<List<Offer>> streamOffers(String branch);

  // Activity Timeline
  Stream<List<CustomerActivity>> streamCustomerActivity(String customerId);
  Future<void> logCustomerActivity(CustomerActivity activity);
}
