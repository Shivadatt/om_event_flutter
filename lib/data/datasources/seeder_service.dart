import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_collections.dart';
import '../../../core/constants/app_buckets.dart';
import '../../../core/constants/app_permissions.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/app_status.dart';
import '../../../core/constants/app_strings.dart';
import 'sql_seed_data.dart';
import 'supabase_upload_service.dart';
import 'batch_delete_service.dart';
import 'batch_insert_service.dart';

/// Orchestrates full database migration: delete → upload → seed.
class SeederService {
  final FirebaseFirestore _firestore;
  final SupabaseUploadService _uploadService;
  final BatchDeleteService _deleteService;
  final BatchInsertService _insertService;

  /// Creates a [SeederService] instance.
  SeederService(this._firestore, this._uploadService)
    : _deleteService = BatchDeleteService(_firestore),
      _insertService = BatchInsertService(_firestore);

  /// Run the entire migration seeder once.
  /// Reports progress via [onProgress] callback.
  Future<void> runMigration({
    required Function(String status, double progress) onProgress,
    bool force = false,
  }) async {
    try {
      onProgress(AppStrings.seederCheckStatus, 0.05);

      // Check migration lock
      final appSettings =
          await _firestore
              .collection(AppCollections.settings)
              .doc(AppStatus.settingsAppDoc)
              .get();
      if (!force &&
          appSettings.exists &&
          appSettings.data()?[AppStatus.migrationCompleted] == true) {
        onProgress(AppStrings.seederAlreadyDone, 1.0);
        return;
      }

      // Step 1: Batch delete all existing collections and settings
      onProgress(AppStrings.seederPruning, 0.1);
      final collectionsToPrune = [
        AppCollections.users,
        AppCollections.admin,
        AppCollections.categories,
        AppCollections.items,
        AppCollections.itemImages,
        AppCollections.customers,
        AppCollections.leads,
        AppCollections.quotations,
        AppCollections.quotationItems,
        AppCollections.bookings,
        AppCollections.reviews,
        AppCollections.activityLogs,
        AppCollections.settings,
      ];
      await _deleteService.deleteCollections(collectionsToPrune, (collection) {
        onProgress(
          'Clearing collection: $collection...',
          0.1 + (collectionsToPrune.indexOf(collection) * 0.02),
        );
      });

      // Step 2: Upload Category media assets to Supabase Storage
      onProgress(AppStrings.seederUploadCategories, 0.4);
      final List<Map<String, dynamic>> resolvedCategories = [];
      for (final cat in SqlSeedData.categories) {
        final Map<String, dynamic> updatedCat = Map.from(cat);
        final String? imagePath = cat[AppStrings.fieldImageUrl];
        if (imagePath != null && imagePath.startsWith('assets/')) {
          final fileName = imagePath.split('/').last;
          updatedCat[AppStrings.fieldImageUrl] =
              '${AppBuckets.galleryImagesUrl}/$fileName';
          try {
            final publicUrl = await _uploadService.uploadAsset(
              imagePath,
              AppBuckets.gallery,
              folder: AppBuckets.imagesFolder,
            );
            updatedCat[AppStrings.fieldImageUrl] = publicUrl;
          } catch (_) {}
        }
        resolvedCategories.add(updatedCat);
      }

      // Step 3: Upload Decoration Item media assets (Photos & Videos)
      onProgress(AppStrings.seederUploadItems, 0.6);
      final List<Map<String, dynamic>> resolvedDecorationItems = [];
      for (final item in SqlSeedData.decorationItems) {
        final Map<String, dynamic> updatedItem = Map.from(item);

        // Main Image -> gallery/images
        final String? imagePath = item[AppStrings.fieldImageUrl];
        if (imagePath != null && imagePath.startsWith('assets/')) {
          final fileName = imagePath.split('/').last;
          updatedItem[AppStrings.fieldImageUrl] =
              '${AppBuckets.galleryImagesUrl}/$fileName';
          try {
            final publicUrl = await _uploadService.uploadAsset(
              imagePath,
              AppBuckets.gallery,
              folder: AppBuckets.imagesFolder,
            );
            updatedItem[AppStrings.fieldImageUrl] = publicUrl;
          } catch (_) {}
        }

        // Video Reel -> gallery/Video
        final String? videoPath = item[AppStrings.fieldVideoUrl];
        if (videoPath != null &&
            videoPath.isNotEmpty &&
            videoPath.startsWith('assets/')) {
          final fileName = videoPath.split('/').last;
          updatedItem[AppStrings.fieldVideoUrl] =
              '${AppBuckets.galleryVideosUrl}/$fileName';
          try {
            final publicUrl = await _uploadService.uploadAsset(
              videoPath,
              AppBuckets.gallery,
              folder: AppBuckets.videosFolder,
            );
            updatedItem[AppStrings.fieldVideoUrl] = publicUrl;
          } catch (_) {}
        }

        resolvedDecorationItems.add(updatedItem);
      }

      // Step 4: Upload Item Gallery Images
      onProgress(AppStrings.seederUploadGallery, 0.7);
      final List<Map<String, dynamic>> resolvedItemImages = [];
      for (final img in SqlSeedData.itemImages) {
        final Map<String, dynamic> updatedImg = Map.from(img);
        final String? imagePath = img[AppStrings.fieldUrl];
        if (imagePath != null && imagePath.startsWith('assets/')) {
          final fileName = imagePath.split('/').last;
          updatedImg[AppStrings.fieldUrl] =
              '${AppBuckets.galleryImagesUrl}/$fileName';
          try {
            final publicUrl = await _uploadService.uploadAsset(
              imagePath,
              AppBuckets.gallery,
              folder: AppBuckets.imagesFolder,
            );
            updatedImg[AppStrings.fieldUrl] = publicUrl;
          } catch (_) {}
        }
        resolvedItemImages.add(updatedImg);
      }

      // Step 5: Upload Review pictures if present
      onProgress(AppStrings.seederUploadReviews, 0.8);
      final List<Map<String, dynamic>> resolvedReviews = [];
      for (final r in SqlSeedData.reviews) {
        final Map<String, dynamic> updatedReview = Map.from(r);
        final String? imagePath = r[AppStrings.fieldImageUrl];
        if (imagePath != null &&
            imagePath.isNotEmpty &&
            imagePath.startsWith('assets/')) {
          final fileName = imagePath.split('/').last;
          updatedReview[AppStrings.fieldImageUrl] =
              '${AppBuckets.galleryImagesUrl}/$fileName';
          try {
            final publicUrl = await _uploadService.uploadAsset(
              imagePath,
              AppBuckets.gallery,
              folder: AppBuckets.imagesFolder,
            );
            updatedReview[AppStrings.fieldImageUrl] = publicUrl;
          } catch (_) {}
        }
        resolvedReviews.add(updatedReview);
      }

      // Step 6: Batch insert converted structures
      onProgress(AppStrings.seederCommitting, 0.85);

      await _insertService.insertDocuments(
        AppCollections.users,
        SqlSeedData.users,
      );

      // Bootstrap Super Admin
      await _firestore
          .collection(AppCollections.admin)
          .doc(AppStrings.superAdminUid)
          .set({
            AppStrings.fieldUid: AppStrings.superAdminUid,
            AppStrings.fieldName: AppStrings.superAdminName,
            AppStrings.fieldEmail: AppStrings.businessEmail,
            AppStrings.fieldRoleType: AppRoles.superAdmin,
            AppStrings.fieldIsActive: true,
            AppStrings.fieldCreatedAt: DateTime.now().toIso8601String(),
            AppStrings.fieldUpdatedAt: DateTime.now().toIso8601String(),
            AppStrings.fieldCreatedBy: AppStrings.createdBySystem,
            AppStrings.fieldPermissions: AppPermissions.superAdminPermissions,
          });

      // Bootstrap Demo Admin
      await _firestore
          .collection(AppCollections.admin)
          .doc(AppStrings.demoAdminUid)
          .set({
            AppStrings.fieldUid: AppStrings.demoAdminUid,
            AppStrings.fieldName: AppStrings.demoAdminName,
            AppStrings.fieldEmail: AppStrings.demoAdminEmail,
            AppStrings.fieldRoleType: AppRoles.demoAdmin,
            AppStrings.fieldIsActive: true,
            AppStrings.fieldCreatedAt: DateTime.now().toIso8601String(),
            AppStrings.fieldUpdatedAt: DateTime.now().toIso8601String(),
            AppStrings.fieldCreatedBy: AppStrings.createdBySystem,
            AppStrings.fieldPermissions: AppPermissions.demoAdminPermissions,
          });

      await _insertService.insertDocuments(
        AppCollections.categories,
        resolvedCategories,
      );
      await _insertService.insertDocuments(
        AppCollections.items,
        resolvedDecorationItems,
      );
      await _insertService.insertDocuments(
        AppCollections.itemImages,
        resolvedItemImages,
      );
      await _insertService.insertDocuments(
        AppCollections.customers,
        SqlSeedData.customers,
      );
      await _insertService.insertDocuments(
        AppCollections.leads,
        SqlSeedData.leads,
      );
      await _insertService.insertDocuments(
        AppCollections.quotations,
        SqlSeedData.quotations,
      );
      await _insertService.insertDocuments(
        AppCollections.quotationItems,
        SqlSeedData.quotationItems,
      );
      await _insertService.insertDocuments(
        AppCollections.bookings,
        SqlSeedData.bookings,
      );
      await _insertService.insertDocuments(
        AppCollections.reviews,
        resolvedReviews,
      );
      await _insertService.insertDocuments(
        AppCollections.activityLogs,
        SqlSeedData.activityLogs,
      );

      // Step 7: Finalize lock document
      onProgress(AppStrings.seederLockMarker, 0.95);
      await _firestore
          .collection(AppCollections.settings)
          .doc(AppStatus.settingsAppDoc)
          .set({
            AppStatus.migrationCompleted: true,
            AppStatus.migrationDate: FieldValue.serverTimestamp(),
          });

      onProgress(AppStrings.seederSuccess, 1.0);
    } catch (e) {
      onProgress('${AppStrings.seederFailed}$e', -1.0);
      rethrow;
    }
  }
}
