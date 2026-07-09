// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/quotation.dart';
import 'seeds/migration_seed.dart';

class DatabaseMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if migration has already been executed.
  Future<bool> isMigrationCompleted() async {
    try {
      final doc = await _firestore
          .collection(AppCollections.settings)
          .doc('migrations')
          .get();
      if (doc.exists) {
        return doc.data()?['servicesSeeded'] == true;
      }
    } catch (e) {
      print("Check migration error: $e");
    }
    return false;
  }

  /// Run full migration: correct relationships + insert new services.
  Future<void> runFullMigration() async {
    await correctDatabaseRelationships();
    await seedCategoriesOnly();
    await insertNewServices();
    await migrateQuotationsCustomerId();
    await markMigrationCompleted();
  }

  Future<void> markMigrationCompleted() async {
    try {
      await _firestore
          .collection(AppCollections.settings)
          .doc('migrations')
          .set({
        'catalogVersion': 1,
        'servicesSeeded': true,
        'relationshipVersion': 1,
        'lastMigration': FieldValue.serverTimestamp(),
      });
      print("DATABASE MIGRATION: Marked migration as completed.");
    } catch (e) {
      print("Failed to mark migration as completed: $e");
    }
  }

  Future<void> correctDatabaseRelationships() async {
    try {
      final itemsCol = _firestore.collection(AppCollections.items);
      final catsCol = _firestore.collection(AppCollections.categories);

      // Perform dynamic batch migration for multi-category support
      for (final entry in MigrationSeed.experienceCategoryMappings.entries) {
        final itemId = entry.key;
        final targetCatIds = entry.value;

        final itemDoc = await itemsCol.doc(itemId).get();
        if (itemDoc.exists) {
          final data = itemDoc.data();
          if (data != null) {
            final existingCatIds = data['category_ids'] != null
                ? List<String>.from(data['category_ids'])
                : <String>[];

            // Check if categories match exactly
            final hasMatch = existingCatIds.length == targetCatIds.length &&
                existingCatIds.every((id) => targetCatIds.contains(id));

            if (!hasMatch) {
              // Ensure first category is the default category property
              final firstCatId = targetCatIds.first;
              final catDoc = await catsCol.doc(firstCatId).get();
              final catName = catDoc.data()?['name'] ?? 'Category';
              final catSlug = catDoc.data()?['slug'] ?? firstCatId;

              await itemsCol.doc(itemId).update({
                'category_id': firstCatId,
                'category_name': catName,
                'category_slug': catSlug,
                'category_ids': targetCatIds,
              });
              print(
                "DATABASE MIGRATION: Migrated $itemId to multiple categories $targetCatIds",
              );
            }
          }
        }
      }
    } catch (e) {
      print("DATABASE MIGRATION ERROR: $e");
      rethrow;
    }
  }

  Future<void> seedCategoriesOnly() async {
    try {
      final categoriesCol = _firestore.collection(AppCollections.categories);

      for (final cat in MigrationSeed.newCategories) {
        final docRef = categoriesCol.doc(cat['id'] as String);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'name': cat['name'],
            'slug': cat['slug'],
            'is_active': true,
            'is_featured': false,
            'cover_image': null,
            'thumbnail': null,
            'banner_image': null,
            'icon': null,
            'gallery_images': [],
            'videos': [],
            'display_order': 1,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
          print("SUCCESSFULLY INSERTED CATEGORY ${cat['id']}");
        }
      }
    } catch (e) {
      print("SEED CATEGORIES ERROR: $e");
      rethrow;
    }
  }

  Future<void> insertNewServices() async {
    try {
      final itemsCol = _firestore.collection(AppCollections.items);

      for (final item in MigrationSeed.newItems) {
        final docRef = itemsCol.doc(item['id'] as String);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set({
            'name': item['name'],
            'slug': item['slug'],
            'category_id': item['category_id'],
            'category_name': item['category_name'],
            'category_slug': item['category_slug'],
            'category_ids': item['category_ids'],
            'description': item['description'],
            'price': item['price'],
            'discount_price': item['discount_price'],
            'offer_price': item['offer_price'],
            'duration_hours': item['duration_hours'],
            'colors': item['colors'],
            'availability': item['availability'],
            'is_active': item['is_active'],
            'is_featured': item['is_featured'],
            'is_popular': item['is_popular'],
            'rating': item['rating'],
            'review_count': item['review_count'],
            'gallery_urls': item['gallery_urls'],
            'image_url': item['image_url'],
            'cover_image': item['cover_image'],
            'thumbnail': item['thumbnail'],
            'banner_image': item['banner_image'],
            'videos': item['videos'],
            'tags': item['tags'],
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
          print("SUCCESSFULLY INSERTED SERVICE ${item['id']}");
        }
      }
    } catch (e) {
      print("INSERT SERVICES ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, int>> migrateQuotationsCustomerId() async {
    int scanned = 0;
    int updated = 0;
    int skipped = 0;
    int failed = 0;

    try {
      final querySnapshot = await _firestore.collection(AppCollections.quotations).get();
      final profilesSnapshot = await _firestore.collection(AppCollections.customerProfiles).get();
      final profiles = profilesSnapshot.docs;

      for (final doc in querySnapshot.docs) {
        scanned++;
        final data = doc.data();
        final String? existingCustomerId = data['customerId'];
        final String? legacyCustomerId = data['customer_id'];
        final int? version = data['version'];
        final String? currentStatus = data['status'];

        final updateMap = <String, dynamic>{};

        // 1. Resolve customerId if missing
        if (existingCustomerId == null || existingCustomerId.trim().isEmpty || existingCustomerId == 'unmigrated_legacy_id') {
          String? resolvedUid;
          if (legacyCustomerId != null && legacyCustomerId.trim().isNotEmpty && legacyCustomerId != 'unmigrated_legacy_id') {
            resolvedUid = legacyCustomerId;
          } else {
            final customerPhone = data['customer_phone'] ?? data['customerPhone'] ?? '';
            final customerName = data['customer_name'] ?? data['customerName'] ?? '';

            if (customerPhone.isNotEmpty) {
              final normalizedPhone = customerPhone.replaceAll(RegExp(r'\D'), '');
              final tenDigitPhone = normalizedPhone.length >= 10 
                  ? normalizedPhone.substring(normalizedPhone.length - 10) 
                  : normalizedPhone;

              final phoneVariations = {
                customerPhone,
                normalizedPhone,
                tenDigitPhone,
                if (tenDigitPhone.length == 10) "+91$tenDigitPhone",
                if (tenDigitPhone.length == 10) "91$tenDigitPhone",
                if (tenDigitPhone.length == 10) "0$tenDigitPhone",
              };

              for (final profDoc in profiles) {
                final profData = profDoc.data();
                final profPhone = profData['phone'] ?? '';
                if (profPhone.isNotEmpty) {
                  final normalizedProfPhone = profPhone.replaceAll(RegExp(r'\D'), '');
                  final tenDigitProfPhone = normalizedProfPhone.length >= 10 
                      ? normalizedProfPhone.substring(normalizedProfPhone.length - 10) 
                      : normalizedProfPhone;
                  if (phoneVariations.contains(profPhone) || phoneVariations.contains(normalizedProfPhone) || phoneVariations.contains(tenDigitProfPhone)) {
                    resolvedUid = profDoc.id;
                    break;
                  }
                }
              }
            }

            if (resolvedUid == null && customerName.isNotEmpty) {
              for (final profDoc in profiles) {
                final profData = profDoc.data();
                final fullName = profData['full_name'] ?? profData['fullName'] ?? '';
                if (fullName.toLowerCase() == customerName.toLowerCase()) {
                  resolvedUid = profDoc.id;
                  break;
                }
              }
            }
          }

          if (resolvedUid != null && resolvedUid.isNotEmpty) {
            updateMap['customerId'] = resolvedUid;
          } else {
            updateMap['customerId'] = 'unmigrated_legacy_id';
          }
        }

        // 2. Map legacy statuses for backward compatibility
        if (currentStatus == 'pending') {
          updateMap['status'] = QuotationStatus.published.nameStr;
        } else if (currentStatus == 'declinedByClient') {
          updateMap['status'] = QuotationStatus.rejectedByClient.nameStr;
        }

        // 3. Populate default version
        if (version == null) {
          updateMap['version'] = 1;
        }

        if (updateMap.isNotEmpty) {
          await _firestore.collection(AppCollections.quotations).doc(doc.id).update(updateMap);
          updated++;
        } else {
          skipped++;
        }
      }

      print("DATABASE MIGRATION SUMMARY: Scanned: $scanned, Updated: $updated, Skipped: $skipped, Failed: $failed");
    } catch (e) {
      print("DATABASE MIGRATION ERROR: $e");
    }

    return {
      'scanned': scanned,
      'updated': updated,
      'skipped': skipped,
      'failed': failed,
    };
  }
}
