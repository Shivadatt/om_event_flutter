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
    // Listen to dedicated customer_gallery collection first
    return _firestore
        .collection(AppCollections.customerGallery)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .asyncMap((gallerySnap) async {
      try {
        final List<GalleryItem> items = [];

        for (final doc in gallerySnap.docs) {
          items.add(GalleryItem.fromJson(doc.data(), doc.id));
        }

        // If the dedicated gallery collection is empty or sparse, hydrate from active catalog items
        if (items.isEmpty) {
          final itemsSnap = await _firestore
              .collection(AppCollections.items)
              .where('is_active', isEqualTo: true)
              .get();

          for (final doc in itemsSnap.docs) {
            final data = doc.data();
            final imgUrl = (data['image_url'] ?? data['imageUrl'] ?? '').toString();
            if (imgUrl.isEmpty) continue;

            final tagsRaw = data['tags'];
            final List<String> tags = tagsRaw is List
                ? List<String>.from(tagsRaw.map((e) => e.toString()))
                : [];

            items.add(
              GalleryItem(
                id: 'exp_${doc.id}',
                imageUrl: imgUrl,
                thumbnailUrl: (data['thumbnail_url'] ?? data['thumbnailUrl'] ?? imgUrl).toString(),
                title: (data['name'] ?? data['title'] ?? 'Luxury Celebration').toString(),
                description: (data['description'] ?? '').toString(),
                categoryId: (data['category_id'] ?? data['categoryId'] ?? '').toString(),
                categoryName: (data['category_name'] ?? data['categoryName'] ?? 'Decor').toString(),
                serviceId: doc.id,
                serviceName: (data['name'] ?? '').toString(),
                tags: tags,
                isActive: true,
                sortOrder: (data['popularity'] ?? 0) is int ? data['popularity'] : 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
          }
        }

        // Sort by sortOrder descending
        items.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
        return items;
      } catch (e) {
        AppLogger.error("GalleryRepositoryImpl stream error: $e");
        return [];
      }
    });
  }

  @override
  Future<GalleryItem?> getGalleryItemById(String id) async {
    try {
      final doc = await _firestore.collection(AppCollections.customerGallery).doc(id).get();
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
    return _firestore
        .collection(AppCollections.customerGallery)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => GalleryItem.fromJson(doc.data(), doc.id))
          .toList();
      items.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
      return items;
    });
  }

  @override
  Future<String> createGalleryItem(GalleryItem item) async {
    final data = item.toJson();
    data['created_at'] = FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();
    final ref = await _firestore
        .collection(AppCollections.customerGallery)
        .add(data);
    return ref.id;
  }

  @override
  Future<void> updateGalleryItem(GalleryItem item) async {
    final data = item.toJson();
    data['updated_at'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppCollections.customerGallery)
        .doc(item.id)
        .update(data);
  }

  @override
  Future<void> deleteGalleryItem(String id) async {
    // Soft delete — preserve history, hide from customer views
    await _firestore
        .collection(AppCollections.customerGallery)
        .doc(id)
        .update({
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
