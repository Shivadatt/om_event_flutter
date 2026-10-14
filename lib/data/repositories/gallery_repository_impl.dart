import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/gallery_item.dart';
import '../../domain/repositories/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final FirebaseFirestore _firestore;

  GalleryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<GalleryItem>> streamGalleryItems() {
    // Canonical SSOT: Stream active gallery items from AppCollections.items
    return _firestore
        .collection(AppCollections.items)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => GalleryItem.fromJson(doc.data(), doc.id))
          .where((i) => i.isActive && i.imageUrl.isNotEmpty)
          .toList();
      items.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
      return items;
    }).handleError((e) {
      AppLogger.error("GalleryRepositoryImpl.streamGalleryItems error: $e");
      return <GalleryItem>[];
    });
  }

  @override
  Future<GalleryItem?> getGalleryItemById(String id) async {
    try {
      final doc = await _firestore.collection(AppCollections.items).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return GalleryItem.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      AppLogger.error("GalleryRepositoryImpl.getGalleryItemById failed", e);
      return null;
    }
  }

  // ── Admin CRUD ───────────────────────────────────────────────────────────

  @override
  Stream<List<GalleryItem>> streamAllGalleryItems() {
    // Stream ALL canonical items (both active and inactive) for the admin management view
    return _firestore
        .collection(AppCollections.items)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => GalleryItem.fromJson(doc.data(), doc.id))
          .where((i) => i.title.isNotEmpty || i.imageUrl.isNotEmpty)
          .toList();
      items.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
      return items;
    });
  }

  @override
  Future<String> createGalleryItem(GalleryItem item) async {
    final slug = item.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    final data = <String, dynamic>{
      'name': item.title,
      'title': item.title,
      'slug': slug.isNotEmpty ? slug : 'gallery-item-${DateTime.now().millisecondsSinceEpoch}',
      'image_url': item.imageUrl,
      'imageUrl': item.imageUrl,
      'thumbnail_url': item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.imageUrl,
      'thumbnailUrl': item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.imageUrl,
      'description': item.description,
      'category_id': item.categoryId,
      'categoryId': item.categoryId,
      'category_name': item.categoryName,
      'categoryName': item.categoryName,
      'service_id': item.serviceId,
      'serviceName': item.serviceName.isNotEmpty ? item.serviceName : item.title,
      'tags': item.tags,
      'is_active': item.isActive,
      'isActive': item.isActive,
      'is_featured': item.isFeatured,
      'isFeatured': item.isFeatured,
      'sort_order': item.sortOrder,
      'sortOrder': item.sortOrder,
      'popularity': item.sortOrder,
      'display_order': item.sortOrder,
      'price': 0.0,
      'rating': 5.0,
      'review_count': 0,
      'availability': 'available',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final ref = await _firestore.collection(AppCollections.items).add(data);
    return ref.id;
  }

  @override
  Future<void> updateGalleryItem(GalleryItem item) async {
    final data = <String, dynamic>{
      'name': item.title,
      'title': item.title,
      'image_url': item.imageUrl,
      'imageUrl': item.imageUrl,
      'thumbnail_url': item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.imageUrl,
      'thumbnailUrl': item.thumbnailUrl.isNotEmpty ? item.thumbnailUrl : item.imageUrl,
      'description': item.description,
      'category_id': item.categoryId,
      'categoryId': item.categoryId,
      'category_name': item.categoryName,
      'categoryName': item.categoryName,
      if (item.serviceId.isNotEmpty) 'service_id': item.serviceId,
      if (item.serviceName.isNotEmpty) 'service_name': item.serviceName,
      'tags': item.tags,
      'is_active': item.isActive,
      'isActive': item.isActive,
      'is_featured': item.isFeatured,
      'isFeatured': item.isFeatured,
      'sort_order': item.sortOrder,
      'sortOrder': item.sortOrder,
      'popularity': item.sortOrder,
      'display_order': item.sortOrder,
      'updated_at': FieldValue.serverTimestamp(),
    };

    // Use SetOptions(merge: true) to safely update metadata without overwriting
    // any existing catalog fields (e.g. packages, colors, pricing, rating).
    await _firestore
        .collection(AppCollections.items)
        .doc(item.id)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> deleteGalleryItem(String id, {bool permanent = false}) async {
    if (permanent) {
      await _firestore.collection(AppCollections.items).doc(id).delete();
    } else {
      // Soft delete: set is_active to false so it disappears from customer views
      // but preserves historical records and relationships in Firestore.
      await _firestore.collection(AppCollections.items).doc(id).update({
        'is_active': false,
        'isActive': false,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }
}
