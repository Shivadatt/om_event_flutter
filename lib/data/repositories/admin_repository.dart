import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';
import '../../core/constants/app_status.dart';
import '../models/review_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';

/// Manages application-wide business records from Supabase (reviews, bookings, payments, settings).
class AdminRepository {
  final SupabaseClient _client = Supabase.instance.client;

  AdminRepository();

  // ── Reviews ───────────────────────────────────────────────────────────────

  /// Retrieve all customer reviews ordered by creation date descending.
  Future<List<ReviewModel>> getReviews() async {
    final response = await _client
        .from('reviews')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((row) => ReviewModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  /// Save or update a review record.
  Future<void> saveReview(ReviewModel review, {required bool isEdit}) async {
    final payload = SupabaseMapper.toSnakeCase(review.toJson());
    await _client.from('reviews').upsert({
      'id': review.id,
      ...payload,
    });
  }

  /// Delete a review record.
  Future<void> deleteReview(String id) async {
    await _client.from('reviews').delete().eq('id', id);
  }

  // ── Bookings ────────────────----------------------------------------------

  /// Retrieve all event bookings.
  Future<List<BookingModel>> getBookings() async {
    final response = await _client
        .from('bookings')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((row) => BookingModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  /// Save or update a booking record.
  Future<void> saveBooking(BookingModel booking, {required bool isEdit}) async {
    final payload = SupabaseMapper.toSnakeCase(booking.toJson());
    await _client.from('bookings').upsert({
      'id': booking.id,
      ...payload,
    });
  }

  /// Delete a booking record.
  Future<void> deleteBooking(String id) async {
    await _client.from('bookings').delete().eq('id', id);
  }

  // ── Payments ────────────────----------------------------------------------

  /// Retrieve all billing payments.
  Future<List<PaymentModel>> getPayments() async {
    final response = await _client
        .from('payments')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((row) => PaymentModel.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  /// Save or update a payment record.
  Future<void> savePayment(PaymentModel payment, {required bool isEdit}) async {
    final payload = SupabaseMapper.toSnakeCase(payment.toJson());
    await _client.from('payments').upsert({
      'id': payment.id,
      ...payload,
    });
  }

  /// Delete a payment record.
  Future<void> deletePayment(String id) async {
    await _client.from('payments').delete().eq('id', id);
  }

  // ── Settings ────────────────----------------------------------------------

  /// Retrieve active business configurations.
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _client
        .from('settings')
        .select()
        .eq('id', AppStatus.settingsBusinessDoc)
        .maybeSingle();
    return response ?? {};
  }

  /// Save configurations.
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _client.from('settings').upsert({
      'id': AppStatus.settingsBusinessDoc,
      ...settings,
    });
  }

  /// Update admin profile fields in Supabase
  Future<void> updateAdminProfileFields(String uid, Map<String, dynamic> data) async {
    final payload = SupabaseMapper.toSnakeCase(data);
    await _client.from('admins').update(payload).eq('id', uid);
  }

  /// Update admin photo URL in Supabase
  Future<void> updateAdminPhotoUrl(String uid, String url) async {
    await _client.from('admins').update({'photo_url': url}).eq('id', uid);
  }
}
