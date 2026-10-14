import 'dart:async';
import 'package:get/get.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/gallery_item.dart';
import '../../domain/repositories/gallery_repository.dart';
import 'catalog_controller.dart';

class GalleryController extends GetxController {
  static GalleryController get to => Get.find<GalleryController>();

  final GalleryRepository _galleryRepo = Get.find<GalleryRepository>();

  // ── Customer-facing state ─────────────────────────────────────────────────
  final rxGalleryItems = <GalleryItem>[].obs;
  final rxCategories = <String>['ALL'].obs;
  final rxSelectedCategory = 'ALL'.obs;
  final rxSearchQuery = ''.obs;
  final rxIsLoading = true.obs;

  // ── Admin state ───────────────────────────────────────────────────────────
  final rxAllGalleryItems = <GalleryItem>[].obs;
  final rxAdminShowAll = true.obs;
  final rxIsAdminLoading = false.obs;
  final rxAdminError = ''.obs;

  StreamSubscription? _customerSub;
  StreamSubscription? _adminSub;

  @override
  void onInit() {
    super.onInit();
    _bindGalleryStream();
  }

  @override
  void onClose() {
    _adminSub?.cancel();
    _customerSub?.cancel();
    super.onClose();
  }

  /// Starts the unfiltered admin stream.
  /// Call this from [ManageGalleryScreen.initState] (once per admin session).
  void initAdminStream() {
    if (_adminSub != null && rxAllGalleryItems.isNotEmpty) return;
    _bindAdminGalleryStream();
  }

  void _bindGalleryStream() {
    rxIsLoading.value = true;
    _customerSub?.cancel();
    _customerSub = _galleryRepo.streamGalleryItems().listen(
      (items) {
        rxGalleryItems.assignAll(items);
        rxIsLoading.value = false;
        _populateCategories(items);
      },
      onError: (err) {
        AppLogger.error("GalleryController stream error", err);
        rxIsLoading.value = false;
      },
    );
  }

  void _bindAdminGalleryStream() {
    rxIsAdminLoading.value = true;
    rxAdminError.value = '';
    _adminSub?.cancel();
    _adminSub = _galleryRepo.streamAllGalleryItems().listen(
      (items) {
        rxAllGalleryItems.assignAll(items);
        rxIsAdminLoading.value = false;
        rxAdminError.value = '';
        _populateCategories(items);
      },
      onError: (err) {
        AppLogger.error("GalleryController admin stream error", err);
        rxIsAdminLoading.value = false;
        rxAdminError.value = err.toString();
      },
    );
  }

  /// Evaluates filtering dynamically so switching 'All' vs 'Active Only' is instantaneous.
  List<GalleryItem> get displayedAdminGalleryItems {
    if (rxAdminShowAll.value) return rxAllGalleryItems;
    return rxAllGalleryItems.where((i) => i.isActive).toList();
  }

  void _populateCategories(List<GalleryItem> items) {
    final Set<String> catSet = {'ALL'};

    if (Get.isRegistered<CatalogController>()) {
      for (final cat in Get.find<CatalogController>().rxCategories) {
        if (cat.name.trim().isNotEmpty) {
          catSet.add(cat.name.trim().toUpperCase());
        }
      }
    }

    for (final item in items) {
      if (item.categoryName.trim().isNotEmpty) {
        catSet.add(item.categoryName.trim().toUpperCase());
      }
    }

    rxCategories.assignAll(catSet.toList());
  }

  void setCategory(String category) => rxSelectedCategory.value = category.toUpperCase();
  void setSearchQuery(String query) => rxSearchQuery.value = query.trim();
  void clearSearch() => rxSearchQuery.value = '';
  void resetFilters() {
    rxSelectedCategory.value = 'ALL';
    rxSearchQuery.value = '';
  }

  List<GalleryItem> get filteredItems {
    final query = rxSearchQuery.value.toLowerCase();
    final selectedCat = rxSelectedCategory.value;

    return rxGalleryItems.where((item) {
      if (selectedCat != 'ALL') {
        if (item.categoryName.toUpperCase() != selectedCat) return false;
      }
      if (query.isNotEmpty) {
        final inTitle = item.title.toLowerCase().contains(query);
        final inDesc = item.description.toLowerCase().contains(query);
        final inCategory = item.categoryName.toLowerCase().contains(query);
        final inService = item.serviceName.toLowerCase().contains(query);
        final inTags = item.tags.any((t) => t.toLowerCase().contains(query));
        if (!inTitle && !inDesc && !inCategory && !inService && !inTags) return false;
      }
      return true;
    }).toList();
  }

  Experience? findExperienceForGalleryItem(GalleryItem item) {
    if (!Get.isRegistered<CatalogController>()) return null;
    final experiences = Get.find<CatalogController>().rxExperiences;

    if (item.serviceId.isNotEmpty) {
      final byId = experiences.firstWhereOrNull((e) => e.id == item.serviceId);
      if (byId != null) return byId;
    }
    if (item.serviceName.isNotEmpty) {
      final byName = experiences.firstWhereOrNull(
        (e) => e.name.toLowerCase() == item.serviceName.toLowerCase(),
      );
      if (byName != null) return byName;
    }
    final byTitle = experiences.firstWhereOrNull(
      (e) => e.name.toLowerCase() == item.title.toLowerCase(),
    );
    if (byTitle != null) return byTitle;
    if (item.categoryName.isNotEmpty) {
      return experiences.firstWhereOrNull(
        (e) => e.categoryName.toLowerCase() == item.categoryName.toLowerCase(),
      );
    }
    return null;
  }

  // ── Admin CRUD ─────────────────────────────────────────────────────────────

  Future<void> createGalleryItem(GalleryItem item) async {
    try {
      rxIsAdminLoading.value = true;
      await _galleryRepo.createGalleryItem(item);
      Get.snackbar('Success', 'Gallery item added successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      AppLogger.error("GalleryController.createGalleryItem failed", e);
      Get.snackbar('Error', 'Failed to add gallery item: ${e.toString()}');
    } finally {
      rxIsAdminLoading.value = false;
    }
  }

  Future<void> updateGalleryItem(GalleryItem item) async {
    try {
      rxIsAdminLoading.value = true;
      await _galleryRepo.updateGalleryItem(item);
      Get.snackbar('Saved', 'Gallery item updated.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      AppLogger.error("GalleryController.updateGalleryItem failed", e);
      Get.snackbar('Error', 'Failed to update gallery item: ${e.toString()}');
    } finally {
      rxIsAdminLoading.value = false;
    }
  }

  Future<void> deleteGalleryItem(String id, {bool permanent = false}) async {
    try {
      await _galleryRepo.deleteGalleryItem(id, permanent: permanent);
      Get.snackbar(
        permanent ? 'Deleted' : 'Hidden',
        permanent
            ? 'Gallery item removed permanently.'
            : 'Gallery item hidden from customer website.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error("GalleryController.deleteGalleryItem failed", e);
      Get.snackbar('Error', 'Failed to remove gallery item: ${e.toString()}');
    }
  }

  Future<void> toggleGalleryItemActive(GalleryItem item) async {
    final updated = item.copyWith(
      isActive: !item.isActive,
      updatedAt: DateTime.now(),
    );
    await updateGalleryItem(updated);
  }

  Future<void> toggleGalleryItemFeatured(GalleryItem item) async {
    final updated = item.copyWith(
      isFeatured: !item.isFeatured,
      updatedAt: DateTime.now(),
    );
    await updateGalleryItem(updated);
  }
}
