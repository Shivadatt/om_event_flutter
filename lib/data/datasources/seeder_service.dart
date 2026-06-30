import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sql_seed_data.dart';
import 'supabase_upload_service.dart';
import 'batch_delete_service.dart';
import 'batch_insert_service.dart';

class SeederService {
  final FirebaseFirestore _firestore;
  final SupabaseUploadService _uploadService;
  final BatchDeleteService _deleteService;
  final BatchInsertService _insertService;

  SeederService(
    this._firestore,
    this._uploadService,
  )   : _deleteService = BatchDeleteService(_firestore),
        _insertService = BatchInsertService(_firestore);

  /// Run the entire migration seeder once.
  /// Reports progress status and completion states.
  Future<void> runMigration({
    required Function(String status, double progress) onProgress,
  }) async {
    try {
      onProgress("Checking migration status...", 0.05);

      // Check migration lock
      final appSettings = await _firestore.collection('settings').doc('app').get();
      if (appSettings.exists && appSettings.data()?['migration_completed'] == true) {
        onProgress("Migration already completed. Skipping.", 1.0);
        return;
      }

      // Step 1: Batch delete all existing collections and settings
      onProgress("Pruning existing collections...", 0.1);
      final collectionsToPrune = [
        'users',
        'categories',
        'items',
        'item_images',
        'customers',
        'leads',
        'quotations',
        'quotation_items',
        'bookings',
        'reviews',
        'activity_logs',
        'settings',
      ];
      await _deleteService.deleteCollections(collectionsToPrune, (collection) {
        onProgress("Clearing collection: $collection...", 0.1 + (collectionsToPrune.indexOf(collection) * 0.02));
      });

      // Step 2: Upload Category media assets to Supabase Storage ('services')
      onProgress("Uploading category media to Supabase...", 0.4);
      final List<Map<String, dynamic>> resolvedCategories = [];
      for (final cat in SqlSeedData.categories) {
        final Map<String, dynamic> updatedCat = Map.from(cat);
        final String? imagePath = cat['image_url'];
        if (imagePath != null && (imagePath.startsWith('assets/') || imagePath.contains('/static/'))) {
          try {
            final publicUrl = await _uploadService.uploadAsset(imagePath, 'services');
            updatedCat['image_url'] = publicUrl;
          } catch (_) {}
        }
        resolvedCategories.add(updatedCat);
      }

      // Step 3: Upload Decoration Item media assets (Photos & Videos)
      onProgress("Uploading decoration items media to Supabase...", 0.6);
      final List<Map<String, dynamic>> resolvedDecorationItems = [];
      for (final item in SqlSeedData.decorationItems) {
        final Map<String, dynamic> updatedItem = Map.from(item);

        // Main Image -> 'services'
        final String? imagePath = item['image_url'];
        if (imagePath != null && (imagePath.startsWith('assets/') || imagePath.contains('/static/'))) {
          try {
            final publicUrl = await _uploadService.uploadAsset(imagePath, 'services');
            updatedItem['image_url'] = publicUrl;
          } catch (_) {}
        }

        // Video Reel -> 'videos'
        final String? videoPath = item['video_url'];
        if (videoPath != null && videoPath.isNotEmpty && (videoPath.startsWith('assets/') || videoPath.contains('/static/'))) {
          try {
            final publicUrl = await _uploadService.uploadAsset(videoPath, 'videos');
            updatedItem['video_url'] = publicUrl;
          } catch (_) {}
        }

        resolvedDecorationItems.add(updatedItem);
      }

      // Step 4: Upload Item Gallery Images
      onProgress("Uploading secondary gallery images to Supabase...", 0.7);
      final List<Map<String, dynamic>> resolvedItemImages = [];
      for (final img in SqlSeedData.itemImages) {
        final Map<String, dynamic> updatedImg = Map.from(img);
        final String? imagePath = img['url'];
        if (imagePath != null && (imagePath.startsWith('assets/') || imagePath.contains('/static/'))) {
          try {
            final publicUrl = await _uploadService.uploadAsset(imagePath, 'gallery');
            updatedImg['url'] = publicUrl;
          } catch (_) {}
        }
        resolvedItemImages.add(updatedImg);
      }

      // Step 5: Upload Review pictures if present
      onProgress("Uploading review media to Supabase...", 0.8);
      final List<Map<String, dynamic>> resolvedReviews = [];
      for (final r in SqlSeedData.reviews) {
        final Map<String, dynamic> updatedReview = Map.from(r);
        final String? imagePath = r['image_url'];
        if (imagePath != null && imagePath.isNotEmpty && (imagePath.startsWith('assets/') || imagePath.contains('/static/'))) {
          try {
            final publicUrl = await _uploadService.uploadAsset(imagePath, 'reviews');
            updatedReview['image_url'] = publicUrl;
          } catch (_) {}
        }
        resolvedReviews.add(updatedReview);
      }

      // Step 6: Batch insert converted structures
      onProgress("Committing SQL data to Firestore collections...", 0.85);

      await _insertService.insertDocuments('users', SqlSeedData.users);
      await _insertService.insertDocuments('categories', resolvedCategories);
      await _insertService.insertDocuments('items', resolvedDecorationItems);
      await _insertService.insertDocuments('item_images', resolvedItemImages);
      await _insertService.insertDocuments('customers', SqlSeedData.customers);
      await _insertService.insertDocuments('leads', SqlSeedData.leads);
      await _insertService.insertDocuments('quotations', SqlSeedData.quotations);
      await _insertService.insertDocuments('quotation_items', SqlSeedData.quotationItems);
      await _insertService.insertDocuments('bookings', SqlSeedData.bookings);
      await _insertService.insertDocuments('reviews', resolvedReviews);
      await _insertService.insertDocuments('activity_logs', SqlSeedData.activityLogs);

      // Step 7: Finalize lock document settings/app
      onProgress("Setting migration lock marker...", 0.95);
      await _firestore.collection('settings').doc('app').set({
        'migration_completed': true,
        'migration_date': FieldValue.serverTimestamp(),
      });

      onProgress("Migration completed successfully!", 1.0);
    } catch (e) {
      onProgress("Migration failed: $e", -1.0);
      rethrow;
    }
  }
}
