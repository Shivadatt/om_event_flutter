import '../entities/gallery_item.dart';

abstract class GalleryRepository {
  /// Streams active gallery items from Firestore, hydrating from catalog experiences
  /// if the dedicated gallery collection is empty or sparse.
  Stream<List<GalleryItem>> streamGalleryItems();

  /// Fetches a specific gallery item by its unique ID.
  Future<GalleryItem?> getGalleryItemById(String id);

  // ── Admin CRUD Operations ────────────────────────────────────────────────

  /// Realtime stream of ALL gallery items (active + inactive) for the Admin Panel.
  Stream<List<GalleryItem>> streamAllGalleryItems();

  /// Creates a new gallery item in the [customer_gallery] collection.
  Future<String> createGalleryItem(GalleryItem item);

  /// Updates an existing gallery item document.
  Future<void> updateGalleryItem(GalleryItem item);

  /// Soft-deletes a gallery item by setting [is_active] to false.
  Future<void> deleteGalleryItem(String id);
}
