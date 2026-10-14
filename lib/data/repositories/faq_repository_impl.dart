import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/faq_item.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/faq_repository.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FirebaseFirestore _firestore;

  FaqRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _homepageDocRef =>
      _firestore.collection(AppCollections.settings).doc('homepage');

  @override
  Stream<List<FaqItem>> streamFaqs({bool activeOnly = false}) {
    return _homepageDocRef.snapshots().asyncMap((doc) async {
      try {
        if (!doc.exists) {
          // One-time idempotent seed to establish Firestore SSOT
          await seedDefaultFaqsIfEmpty();
          return _getDefaultFaqItems(activeOnly: activeOnly);
        }

        final data = doc.data() ?? {};
        final source = data['published'] ?? data['draft'] ?? {};
        final rawFaqs = source['faqs'] ?? data['faqs'];

        if (rawFaqs is! List || rawFaqs.isEmpty) {
          await seedDefaultFaqsIfEmpty();
          return _getDefaultFaqItems(activeOnly: activeOnly);
        }

        final List<FaqItem> items = [];
        for (int i = 0; i < rawFaqs.length; i++) {
          final entry = rawFaqs[i];
          if (entry is Map) {
            final map = Map<String, dynamic>.from(entry);
            items.add(FaqItem.fromJson(map, 'faq_${i + 1}'));
          }
        }

        // Apply public visibility filtering
        final result = activeOnly ? items.where((f) => f.isActive).toList() : items;

        // Sort by display order ascending
        result.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        return result;
      } catch (e) {
        AppLogger.error("FaqRepositoryImpl.streamFaqs error: $e");
        return _getDefaultFaqItems(activeOnly: activeOnly);
      }
    });
  }

  @override
  Future<List<FaqItem>> getFaqs({bool activeOnly = false}) async {
    try {
      final doc = await _homepageDocRef.get();
      if (!doc.exists) {
        await seedDefaultFaqsIfEmpty();
        return _getDefaultFaqItems(activeOnly: activeOnly);
      }

      final data = doc.data() ?? {};
      final source = data['published'] ?? data['draft'] ?? {};
      final rawFaqs = source['faqs'] ?? data['faqs'];

      if (rawFaqs is! List || rawFaqs.isEmpty) {
        await seedDefaultFaqsIfEmpty();
        return _getDefaultFaqItems(activeOnly: activeOnly);
      }

      final List<FaqItem> items = [];
      for (int i = 0; i < rawFaqs.length; i++) {
        final entry = rawFaqs[i];
        if (entry is Map) {
          final map = Map<String, dynamic>.from(entry);
          items.add(FaqItem.fromJson(map, 'faq_${i + 1}'));
        }
      }

      final result = activeOnly ? items.where((f) => f.isActive).toList() : items;
      result.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return result;
    } catch (e) {
      AppLogger.error("FaqRepositoryImpl.getFaqs error: $e");
      return _getDefaultFaqItems(activeOnly: activeOnly);
    }
  }

  @override
  Future<void> saveFaq(FaqItem faq) async {
    final doc = await _homepageDocRef.get();
    final data = doc.exists ? (doc.data() ?? {}) : <String, dynamic>{};
    final source = Map<String, dynamic>.from(data['published'] ?? data['draft'] ?? {});
    final rawList = List<dynamic>.from(source['faqs'] ?? data['faqs'] ?? []);

    final updatedMap = faq.toJson();
    int foundIndex = -1;

    for (int i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is Map && (item['id'] == faq.id || (item['id'] == null && i.toString() == faq.id))) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex >= 0) {
      rawList[foundIndex] = updatedMap;
    } else {
      rawList.add(updatedMap);
    }

    source['faqs'] = rawList;

    await _homepageDocRef.set({
      'faqs': rawList,
      'draft': source,
      'published': source,
      'meta': {
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': 'admin',
        'version': ((data['meta']?['version'] ?? 0) as int) + 1,
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveAllFaqs(List<FaqItem> faqs) async {
    final doc = await _homepageDocRef.get();
    final data = doc.exists ? (doc.data() ?? {}) : <String, dynamic>{};
    final source = Map<String, dynamic>.from(data['published'] ?? data['draft'] ?? {});
    final rawList = faqs.map((f) => f.toJson()).toList();

    source['faqs'] = rawList;

    await _homepageDocRef.set({
      'faqs': rawList,
      'draft': source,
      'published': source,
      'meta': {
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': 'admin',
        'version': ((data['meta']?['version'] ?? 0) as int) + 1,
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteFaq(String id, {bool permanent = false}) async {
    final doc = await _homepageDocRef.get();
    if (!doc.exists) return;

    final data = doc.data() ?? {};
    final source = Map<String, dynamic>.from(data['published'] ?? data['draft'] ?? {});
    final rawList = List<dynamic>.from(source['faqs'] ?? data['faqs'] ?? []);

    if (permanent) {
      rawList.removeWhere((item) {
        if (item is Map) {
          return item['id'] == id;
        }
        return false;
      });
    } else {
      for (int i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        if (item is Map && item['id'] == id) {
          rawList[i] = {
            ...item,
            'isActive': false,
            'is_active': false,
            'updatedAt': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          break;
        }
      }
    }

    source['faqs'] = rawList;

    await _homepageDocRef.set({
      'faqs': rawList,
      'draft': source,
      'published': source,
      'meta': {
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': 'admin',
        'version': ((data['meta']?['version'] ?? 0) as int) + 1,
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<void> seedDefaultFaqsIfEmpty() async {
    try {
      final doc = await _homepageDocRef.get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final source = data['published'] ?? data['draft'] ?? {};
        final rawFaqs = source['faqs'] ?? data['faqs'];
        if (rawFaqs is List && rawFaqs.isNotEmpty) {
          // Already seeded, do nothing
          return;
        }
      }

      final defaultFaqMaps = HomepageSettings.defaultVal().faqs;
      final List<Map<String, dynamic>> seededFaqs = [];

      for (int i = 0; i < defaultFaqMaps.length; i++) {
        final item = Map<String, dynamic>.from(defaultFaqMaps[i]);
        final faq = FaqItem(
          id: 'faq_${i + 1}',
          question: (item['question'] ?? '').toString().trim(),
          answer: (item['answer'] ?? '').toString().trim(),
          category: (item['category'] ?? 'GENERAL').toString().trim().toUpperCase(),
          displayOrder: i + 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        seededFaqs.add(faq.toJson());
      }

      final currentData = doc.exists ? (doc.data() ?? {}) : <String, dynamic>{};
      final draft = Map<String, dynamic>.from(currentData['draft'] ?? {});
      final published = Map<String, dynamic>.from(currentData['published'] ?? {});

      draft['faqs'] = seededFaqs;
      published['faqs'] = seededFaqs;

      await _homepageDocRef.set({
        'faqs': seededFaqs,
        'draft': draft,
        'published': published,
        'meta': {
          'updatedAt': DateTime.now().toIso8601String(),
          'updatedBy': 'idempotent_faq_seeder',
          'version': 1,
        },
      }, SetOptions(merge: true));

      AppLogger.info("FaqRepositoryImpl: Successfully seeded ${seededFaqs.length} canonical FAQs to Firestore.");
    } catch (e) {
      AppLogger.error("FaqRepositoryImpl.seedDefaultFaqsIfEmpty error: $e");
    }
  }

  List<FaqItem> _getDefaultFaqItems({bool activeOnly = false}) {
    final defaultFaqMaps = HomepageSettings.defaultVal().faqs;
    final List<FaqItem> items = [];
    for (int i = 0; i < defaultFaqMaps.length; i++) {
      final item = Map<String, dynamic>.from(defaultFaqMaps[i]);
      items.add(FaqItem(
        id: 'faq_${i + 1}',
        question: (item['question'] ?? '').toString().trim(),
        answer: (item['answer'] ?? '').toString().trim(),
        category: (item['category'] ?? 'GENERAL').toString().trim().toUpperCase(),
        displayOrder: i + 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    return activeOnly ? items.where((f) => f.isActive).toList() : items;
  }
}
