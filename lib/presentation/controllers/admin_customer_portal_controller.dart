import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
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
  final SupabaseClient _client = Supabase.instance.client;

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
    // Stream ALL records for admin dashboard management via Supabase Realtime Streams
    rxAllQuotes.bindStream(_client.from('customer_quotes').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => CustomerQuotationModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllTimelines.bindStream(_client.from('booking_timelines').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => BookingTimelineModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllPayments.bindStream(_client.from('customer_payments').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => CustomerPaymentModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllNotifications.bindStream(_client.from('customer_notifications').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => CustomerNotificationModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllRebookRequests.bindStream(_client.from('rebook_requests').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => RebookRequestModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllOffers.bindStream(_client.from('offers').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => OfferModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllActivities.bindStream(_client.from('customer_activity').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => CustomerActivityModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));

    rxAllGalleries.bindStream(_client.from('booking_gallery').stream(primaryKey: ['id']).map((rows) =>
        rows.map((row) => BookingGalleryModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? '')).toList()));
  }

  // 1. Quotation Admin Panel
  Future<void> adminCreateQuotation(CustomerQuotation quote) async {
    final model = CustomerQuotationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: quote.customerId,
      quotationNumber: quote.quotationNumber,
      date: quote.date,
      amount: quote.amount,
      status: quote.status,
      expiryDate: quote.expiryDate,
      pdfUrl: quote.pdfUrl,
      notes: quote.notes,
      versionHistory: quote.versionHistory,
      items: quote.items.map((e) => CustomerQuotationItemModel(
        experienceId: e.experienceId,
        name: e.name,
        quantity: e.quantity,
        unitPrice: e.unitPrice,
        color: e.color,
        theme: e.theme,
        notes: e.notes,
      )).toList(),
    );
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    await _client.from('customer_quotes').insert(payload);
  }

  Future<void> adminUpdateQuotation(String id, Map<String, dynamic> data) async {
    final payload = SupabaseMapper.toSnakeCase(data);
    await _client.from('customer_quotes').update(payload).eq('id', id);
  }

  Future<void> adminDeleteQuotation(String id) async {
    await _client.from('customer_quotes').delete().eq('id', id);
  }

  // 2. Booking Timeline Admin
  Future<void> adminAddTimelineCheckpoint(String bookingId, String status, String notes) async {
    final checkpoint = BookingTimelineModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      status: status,
      updatedTime: DateTime.now(),
      notes: notes,
    );
    final payload = SupabaseMapper.toSnakeCase(checkpoint.toJson());
    await _client.from('booking_timelines').insert(payload);
  }

  // 3. Payments Admin Verification
  Future<void> adminVerifyPayment(String id, String status) async {
    await _client.from('customer_payments').update({'status': status}).eq('id', id);
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      branch: branch,
      createdAt: DateTime.now(),
    );
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    await _client.from('customer_notifications').insert(payload);
  }

  // 5. Shared Booking Gallery Admin
  Future<void> adminUploadGalleryMedia(String bookingId, String customerId, String mediaUrl) async {
    final existing = await _client
        .from('booking_gallery')
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (existing != null) {
      final List<dynamic> currentUrls = existing['media_urls'] ?? [];
      currentUrls.add(mediaUrl);
      await _client.from('booking_gallery').update({
        'media_urls': currentUrls,
      }).eq('id', existing['id']);
    } else {
      final gallery = BookingGalleryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        bookingId: bookingId,
        mediaUrls: [mediaUrl],
        createdAt: DateTime.now(),
      );
      final payload = SupabaseMapper.toSnakeCase(gallery.toJson());
      await _client.from('booking_gallery').insert(payload);
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
    final payload = SupabaseMapper.toSnakeCase(model.toJson());
    if (isEdit) {
      await _client.from('offers').update(payload).eq('id', offer.id);
    } else {
      await _client.from('offers').insert(payload);
    }
  }

  // 7. Rebook Approvals
  Future<void> adminApproveRebook(String requestId, String status) async {
    await _client.from('rebook_requests').update({'status': status}).eq('id', requestId);
  }
}
