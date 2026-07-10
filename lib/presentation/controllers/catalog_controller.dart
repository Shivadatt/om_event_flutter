import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_experiences.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/submit_lead.dart';

import 'customer_auth_controller.dart';

part 'parts/catalog_filter.dart';
part 'parts/catalog_lead.dart';

/// Customer-facing catalog controller backed by Firestore realtime streams via UseCases.
/// Crucial: Zero direct CatalogRepository calls. Zero direct snapshot listens.
class CatalogController extends GetxController {
  final GetCategories getCategories;
  final GetExperiences getExperiences;
  final SubmitLead submitLead;

  CatalogController({
    required this.getCategories,
    required this.getExperiences,
    required this.submitLead,
  });

  // ── Public Rx state ────────────────────────────────────────────────────────
  final rxCategories = <Category>[].obs;
  final rxExperiences = <Experience>[].obs;
  final rxReviews = <Review>[].obs;

  final isLoadingCategories = false.obs;
  final isLoadingExperiences = false.obs;
  final isSubmittingLead = false.obs;

  // Search & Filter state
  final selectedCategorySlug = ''.obs;
  final searchQuery = ''.obs;
  final sortBy = 'popular'.obs;
  final rxVisibleCount = 6.obs;

  // Raw unfiltered list of all active experiences from Firestore.
  final List<Experience> _allActiveExperiences = <Experience>[];

  void loadMore() {
    rxVisibleCount.value += 6;
  }

  void resetVisibleCount() {
    rxVisibleCount.value = 6;
  }

  @override
  void onInit() {
    super.onInit();
    _bindRealtimeStreams();

    // Re-apply experience filters whenever user changes any filter param.
    ever(selectedCategorySlug, (_) => applyExperienceFilters());
    ever(sortBy, (_) => applyExperienceFilters());

    // Re-apply when categories change (cascade: hide experiences of inactive category).
    ever(rxCategories, (_) => applyExperienceFilters());

    // Debounce keystroke-level search so we don't re-filter on every character.
    debounce(
      searchQuery,
      (_) => applyExperienceFilters(),
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void onClose() {
    _categoriesSub?.cancel();
    _experiencesSub?.cancel();
    _reviewsSub?.cancel();
    super.onClose();
  }

  StreamSubscription? _categoriesSub;
  StreamSubscription? _experiencesSub;
  StreamSubscription? _reviewsSub;

  // ── Realtime stream binding ────────────────────────────────────────────────
  void _bindRealtimeStreams() {
    final getReviews = Get.find<GetReviews>();
    final startTime = DateTime.now();

    // 1. Categories
    isLoadingCategories.value = true;
    _categoriesSub?.cancel();
    _categoriesSub = getCategories.executeStream().listen(
      (cats) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint("TIME_LOG [categories]: Fetched ${cats.length} categories in ${elapsed}ms");
        rxCategories.assignAll(cats);
        isLoadingCategories.value = false;
      },
      onError: (e, s) {
        debugPrint("CATALOG ERROR: Categories failed to load: $e");
        isLoadingCategories.value = false;
      }
    );

    // 2. Experiences
    isLoadingExperiences.value = true;
    _experiencesSub?.cancel();
    _experiencesSub = getExperiences.executeStream().listen(
      (experiences) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint("TIME_LOG [items]: Fetched ${experiences.length} experiences in ${elapsed}ms");
        _allActiveExperiences
          ..clear()
          ..addAll(experiences);
        applyExperienceFilters();
        isLoadingExperiences.value = false;
      },
      onError: (e, s) {
        debugPrint("CATALOG ERROR: Experiences failed to load: $e");
        isLoadingExperiences.value = false;
      }
    );

    // 3. Reviews
    _reviewsSub?.cancel();
    _reviewsSub = getReviews.executeStream().listen(
      (reviews) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint("TIME_LOG [reviews]: Fetched ${reviews.length} reviews in ${elapsed}ms");
        rxReviews.assignAll(reviews);
      },
    );
  }

  // ── Public API (UI compatibility) ──────────────────────────────────────────
  Future<void> refreshCatalog() async {
    _bindRealtimeStreams();
  }

  /// Kept for backward compatibility — streams handle this automatically.
  Future<void> loadCategories() async {}

  /// Kept for backward compatibility
  Future<void> loadExperiences() async {
    applyExperienceFilters();
  }

  void selectCategory(String slug) {
    // Toggle: tap the same category again to deselect
    selectedCategorySlug.value = selectedCategorySlug.value == slug ? '' : slug;
    resetVisibleCount();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    resetVisibleCount();
    applyExperienceFilters();
  }

  void updateSort(String option) {
    sortBy.value = option;
  }

  Future<bool> requestCallback({
    required String name,
    required String phone,
    required String dateStr,
    required String budgetStr,
    required String requirements,
  }) async {
    return handleRequestCallback(
      name: name,
      phone: phone,
      dateStr: dateStr,
      budgetStr: budgetStr,
      requirements: requirements,
    );
  }
}
