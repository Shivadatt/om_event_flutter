import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/supabase_mapper.dart';

class GalleryItem {
  final String id;
  final String bookingId;
  final String customerId;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;

  GalleryItem({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json, String id) {
    return GalleryItem(
      id: id,
      bookingId: json['bookingId'] ?? '',
      customerId: json['customerId'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Repository implementing event gallery media CRUD operations on Supabase.
class SupabaseGalleryRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<GalleryItem>> getGalleryByBooking(String bookingId) async {
    final response = await _client
        .from('gallery')
        .select()
        .eq('booking_id', bookingId);
    return response
        .map((row) => GalleryItem.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<List<GalleryItem>> getGalleryByCustomer(String customerId) async {
    final response = await _client
        .from('gallery')
        .select()
        .eq('customer_id', customerId);
    return response
        .map((row) => GalleryItem.fromJson(SupabaseMapper.toCamelCase(row), row['id'] ?? ''))
        .toList();
  }

  Future<void> addGalleryItem(GalleryItem item) async {
    final payload = SupabaseMapper.toSnakeCase(item.toJson());
    await _client.from('gallery').upsert({
      'id': item.id,
      ...payload,
    });
  }

  Future<void> deleteGalleryItem(String id) async {
    await _client.from('gallery').delete().eq('id', id);
  }
}
