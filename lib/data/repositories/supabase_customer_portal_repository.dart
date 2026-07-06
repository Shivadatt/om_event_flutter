import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../domain/entities/customer_lead.dart';
import '../../domain/entities/customer_booking.dart';
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
import '../../domain/repositories/customer_portal_repository.dart';
import '../models/customer_lead_model.dart';
import '../models/customer_booking_model.dart';
import '../models/customer_portal_models.dart';

class SupabaseCustomerPortalRepository implements CustomerPortalRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Leads
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerLead>> streamCustomerLeads(String customerId) {
    return _client
        .from('customer_leads')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerLeadModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
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
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    // Supabase insert or update depending on ID
    if (lead.id.isEmpty) {
      await _client.from('customer_leads').insert(payload);
    } else {
      await _client.from('customer_leads').upsert(payload);
    }
  }

  // ---------------------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerBooking>> streamCustomerBookings(String customerId) {
    return _client
        .from('customer_bookings')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerBookingModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------

  @override
  Future<void> submitCustomerReview(
    String customerId,
    String bookingId,
    String reviewText,
    double rating,
  ) async {
    final payload = {
      'customer_id': customerId,
      'booking_id': bookingId,
      'review_text': reviewText,
      'rating': rating,
      'status': 'Pending',
      'created_at': DateTime.now().toIso8601String(),
    };
    await _client.from('customer_reviews').insert(payload);
  }

  // ---------------------------------------------------------------------------
  // Quotations
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerQuotation>> streamCustomerQuotations(String customerId) {
    return _client
        .from('customer_quotes')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerQuotationModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  @override
  Future<void> updateQuotationStatus(String id, String status) async {
    await _client
        .from('customer_quotes')
        .update({'status': status})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Booking Timeline
  // ---------------------------------------------------------------------------

  @override
  Stream<List<BookingTimeline>> streamBookingTimeline(String bookingId) {
    return _client
        .from('booking_timelines')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .map((rows) => rows
            .map((row) => BookingTimelineModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerPayment>> streamCustomerPayments(String customerId) {
    return _client
        .from('customer_payments')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerPaymentModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  @override
  Future<void> submitOfflinePayment(CustomerPayment payment) async {
    final model = CustomerPaymentModel(
      id: payment.id,
      customerId: payment.customerId,
      bookingId: payment.bookingId,
      amount: payment.amount,
      status: payment.status,
      method: payment.method,
      receiptUrl: payment.receiptUrl,
      invoiceUrl: payment.invoiceUrl,
      paymentDate: payment.paymentDate,
    );
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    if (payment.id.isEmpty) {
      await _client.from('customer_payments').insert(payload);
    } else {
      await _client.from('customer_payments').upsert(payload);
    }
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerNotification>> streamCustomerNotifications(String customerId) {
    return _client
        .from('customer_notifications')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerNotificationModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  @override
  Future<void> updateNotificationStatus(String id, {required bool isRead}) async {
    await _client
        .from('customer_notifications')
        .update({'is_read': isRead})
        .eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Documents
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerDocument>> streamCustomerDocuments(String customerId) {
    return _client
        .from('customer_documents')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerDocumentModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------------

  @override
  Stream<List<BookingGallery>> streamBookingGallery(String bookingId) {
    return _client
        .from('booking_gallery')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .map((rows) => rows
            .map((row) => BookingGalleryModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Wishlist
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerWishlist>> streamCustomerWishlist(String customerId) {
    return _client
        .from('customer_wishlist')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerWishlistModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
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
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    if (item.id.isEmpty) {
      await _client.from('customer_wishlist').insert(payload);
    } else {
      await _client.from('customer_wishlist').upsert(payload);
    }
  }

  @override
  Future<void> removeFromWishlist(String wishlistId) async {
    await _client.from('customer_wishlist').delete().eq('id', wishlistId);
  }

  // ---------------------------------------------------------------------------
  // Rebook
  // ---------------------------------------------------------------------------

  @override
  Future<void> submitRebookRequest(RebookRequest request) async {
    final model = RebookRequestModel(
      id: request.id,
      customerId: request.customerId,
      previousBookingId: request.previousBookingId,
      newDate: request.newDate,
      status: request.status,
      createdAt: request.createdAt,
    );
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    if (request.id.isEmpty) {
      await _client.from('rebook_requests').insert(payload);
    } else {
      await _client.from('rebook_requests').upsert(payload);
    }
  }

  // ---------------------------------------------------------------------------
  // Offers
  // ---------------------------------------------------------------------------

  @override
  Stream<List<Offer>> streamOffers(String branch) {
    return _client
        .from('offers')
        .stream(primaryKey: ['id'])
        .eq('branch', branch)
        .map((rows) => rows
            .where((row) => row['is_active'] == true || row['isActive'] == true)
            .map((row) => OfferModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Activity Timeline
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CustomerActivity>> streamCustomerActivity(String customerId) {
    return _client
        .from('customer_activity')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .map((rows) => rows
            .map((row) => CustomerActivityModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
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
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    if (activity.id.isEmpty) {
      await _client.from('customer_activity').insert(payload);
    } else {
      await _client.from('customer_activity').upsert(payload);
    }
  }
}
