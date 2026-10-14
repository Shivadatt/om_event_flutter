import 'dart:async';
import 'package:get/get.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/faq_item.dart';
import '../../domain/repositories/faq_repository.dart';

class FaqController extends GetxController {
  static FaqController get to => Get.find<FaqController>();

  final FaqRepository _faqRepo = Get.find<FaqRepository>();

  final rxAllFaqs = <FaqItem>[].obs;
  final rxIsLoading = true.obs;
  final rxError = ''.obs;

  // Filter state
  final rxSearchQuery = ''.obs;
  final rxSelectedCategory = 'ALL'.obs;
  final rxFilterActiveOnly = false.obs;

  StreamSubscription? _faqSub;

  @override
  void onInit() {
    super.onInit();
    bindFaqStream();
  }

  @override
  void onClose() {
    _faqSub?.cancel();
    super.onClose();
  }

  void bindFaqStream() {
    rxIsLoading.value = true;
    rxError.value = '';
    _faqSub?.cancel();
    _faqSub = _faqRepo.streamFaqs(activeOnly: false).listen(
      (faqs) {
        rxAllFaqs.assignAll(faqs);
        rxIsLoading.value = false;
        rxError.value = '';
      },
      onError: (err) {
        AppLogger.error("FaqController stream error: $err");
        rxIsLoading.value = false;
        rxError.value = err.toString();
      },
    );
  }

  // ── Calculated Statistics ──────────────────────────────────────────────────
  int get totalCount => rxAllFaqs.length;
  int get activeCount => rxAllFaqs.where((f) => f.isActive).length;
  int get inactiveCount => rxAllFaqs.where((f) => !f.isActive).length;

  /// Dynamically derived from loaded Firestore records
  List<String> get availableCategories {
    final Set<String> cats = {'ALL'};
    for (final faq in rxAllFaqs) {
      if (faq.category.trim().isNotEmpty) {
        cats.add(faq.category.trim().toUpperCase());
      }
    }
    return cats.toList();
  }

  /// Category item counts
  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {'ALL': rxAllFaqs.length};
    for (final faq in rxAllFaqs) {
      final c = faq.category.trim().toUpperCase();
      counts[c] = (counts[c] ?? 0) + 1;
    }
    return counts;
  }

  // ── Public Customer View FAQs ──────────────────────────────────────────────
  List<FaqItem> get publicFaqs {
    final q = rxSearchQuery.value.trim().toLowerCase();
    final cat = rxSelectedCategory.value.trim().toUpperCase();

    return rxAllFaqs.where((faq) {
      if (!faq.isActive) return false;

      final matchesCat = cat == 'ALL' ||
          faq.category.toUpperCase() == cat ||
          faq.question.toUpperCase().contains(cat);

      final matchesQ = q.isEmpty ||
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);

      return matchesCat && matchesQ;
    }).toList();
  }

  // ── Admin Filtered FAQs ────────────────────────────────────────────────────
  List<FaqItem> get adminFilteredFaqs {
    final q = rxSearchQuery.value.trim().toLowerCase();
    final cat = rxSelectedCategory.value.trim().toUpperCase();
    final activeOnly = rxFilterActiveOnly.value;

    return rxAllFaqs.where((faq) {
      if (activeOnly && !faq.isActive) return false;

      final matchesCat = cat == 'ALL' || faq.category.toUpperCase() == cat;

      final matchesQ = q.isEmpty ||
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q) ||
          faq.category.toLowerCase().contains(q);

      return matchesCat && matchesQ;
    }).toList();
  }

  // ── Filter Controls ────────────────────────────────────────────────────────
  void setCategory(String category) => rxSelectedCategory.value = category.trim().toUpperCase();
  void setSearchQuery(String query) => rxSearchQuery.value = query.trim();
  void clearSearch() => rxSearchQuery.value = '';
  void toggleFilterActiveOnly() => rxFilterActiveOnly.value = !rxFilterActiveOnly.value;

  // ── Admin CRUD Mutations ───────────────────────────────────────────────────

  Future<void> createFaq(FaqItem faq) async {
    try {
      await _faqRepo.saveFaq(faq);
      Get.snackbar(
        'Success',
        'FAQ item added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error("FaqController.createFaq error: $e");
      Get.snackbar('Error', 'Failed to add FAQ: $e');
    }
  }

  Future<void> updateFaq(FaqItem faq) async {
    try {
      await _faqRepo.saveFaq(faq);
      Get.snackbar(
        'Saved',
        'FAQ item updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error("FaqController.updateFaq error: $e");
      Get.snackbar('Error', 'Failed to update FAQ: $e');
    }
  }

  Future<void> toggleActive(FaqItem faq) async {
    final updated = faq.copyWith(
      isActive: !faq.isActive,
      updatedAt: DateTime.now(),
    );
    await updateFaq(updated);
  }

  Future<void> deleteFaq(String id, {bool permanent = false}) async {
    try {
      await _faqRepo.deleteFaq(id, permanent: permanent);
      Get.snackbar(
        permanent ? 'Deleted' : 'Hidden',
        permanent ? 'FAQ item permanently removed.' : 'FAQ item hidden from public website.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error("FaqController.deleteFaq error: $e");
      Get.snackbar('Error', 'Failed to delete FAQ: $e');
    }
  }

  Future<void> reorderFaqs(List<FaqItem> reordered) async {
    try {
      final updatedList = <FaqItem>[];
      for (int i = 0; i < reordered.length; i++) {
        updatedList.add(reordered[i].copyWith(
          displayOrder: i + 1,
          updatedAt: DateTime.now(),
        ));
      }
      await _faqRepo.saveAllFaqs(updatedList);
      Get.snackbar('Reordered', 'FAQ ordering updated.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      AppLogger.error("FaqController.reorderFaqs error: $e");
      Get.snackbar('Error', 'Failed to save reordered FAQs: $e');
    }
  }
}
