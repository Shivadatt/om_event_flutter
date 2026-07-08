// ignore_for_file: avoid_print
import 'dart:async';
import 'package:get/get.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_experiences.dart';
import '../../domain/usecases/submit_lead.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import 'customer_auth_controller.dart';
/// Customer-facing catalog controller backed by Firestore realtime streams.
///
/// Architecture:
/// - Categories  → direct Firestore snapshot stream via [CatalogRepository.streamCategories]
/// - Experiences → snapshot stream of ALL active items; filters (category,
///                 search, sort) applied in-memory via [_applyExperienceFilters]
/// - Reviews     → direct Firestore snapshot stream via [CatalogRepository.streamPublishedReviews]
///
/// Any Firestore write (admin toggle, edit, delete) is automatically pushed to
/// the customer UI within milliseconds. No manual refresh or app restart needed.
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

  void loadMore() {
    rxVisibleCount.value += 6;
  }

  void resetVisibleCount() {
    rxVisibleCount.value = 6;
  }

  // ── Internal ───────────────────────────────────────────────────────────────
  /// Raw unfiltered list of all active experiences from Firestore.
  final _allActiveExperiences = <Experience>[];

  /// Active Firestore stream subscriptions — cancelled in [onClose].
  StreamSubscription<List<Category>>? _categoriesSub;
  StreamSubscription<List<Experience>>? _experiencesSub;
  StreamSubscription<List<Review>>? _reviewsSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _correctDatabaseRelationships();
    _bindRealtimeStreams();

    // Re-apply experience filters whenever user changes any filter param.
    ever(selectedCategorySlug, (_) => _applyExperienceFilters());
    ever(sortBy, (_) => _applyExperienceFilters());

    // Re-apply when categories change (cascade: hide experiences of inactive category).
    ever(rxCategories, (_) => _applyExperienceFilters());

    // Debounce keystroke-level search so we don't re-filter on every character.
    debounce(
      searchQuery,
      (_) => _applyExperienceFilters(),
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

  // ── Realtime stream binding ────────────────────────────────────────────────

  void _bindRealtimeStreams() {
    final repo = Get.find<CatalogRepository>();

    // 1. Categories
    isLoadingCategories.value = true;
    _categoriesSub = repo.streamCategories().listen(
      (cats) {
        rxCategories.assignAll(cats);
        isLoadingCategories.value = false;
      },
      onError: (_) {
        isLoadingCategories.value = false;
      },
    );

    // 2. Experiences — stream ALL active items; filter in-memory so that:
    //    (a) changing a filter param does not create a new Firestore listener
    //    (b) disabling a category auto-hides its experiences via cascade filter
    isLoadingExperiences.value = true;
    _experiencesSub = repo.streamAllActiveExperiences().listen(
      (experiences) {
        _allActiveExperiences
          ..clear()
          ..addAll(experiences);
        _applyExperienceFilters();
        isLoadingExperiences.value = false;
      },
      onError: (_) {
        isLoadingExperiences.value = false;
      },
    );

    // 3. Reviews
    _reviewsSub = repo.streamPublishedReviews().listen(
      (reviews) => rxReviews.assignAll(reviews),
      onError: (_) {},
    );
  }

  // ── In-memory filtering ────────────────────────────────────────────────────

  /// Filters [_allActiveExperiences] by active categories, selected category,
  /// search query, and sort order, then assigns the result to [rxExperiences].
  void _applyExperienceFilters() {
    // Resolve selected category using active slug
    final catFilter = selectedCategorySlug.value;
    final selectedCat = rxCategories.firstWhereOrNull((c) => c.slug == catFilter);
    final selectedId = selectedCat?.id ?? '';
    final selectedName = selectedCat?.name ?? (catFilter.isEmpty ? 'All' : 'Unknown');
    final selectedSlug = selectedCat?.slug ?? (catFilter.isEmpty ? 'N/A' : catFilter);

    // Cascade filter using category IDs
    final activeIds = rxCategories.map((c) => c.id).toSet();
    var list =
        activeIds.isEmpty
            ? List<Experience>.from(_allActiveExperiences)
            : _allActiveExperiences
                .where((e) => e.categoryIds.any((id) => activeIds.contains(id)))
                .toList();

    // Category tab filter using ID-based relationship
    if (selectedId.isNotEmpty) {
      list = list.where((e) => e.categoryIds.contains(selectedId)).toList();
    }

    // Keyword search
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      final keywords = query.split(RegExp(r'\s+'));
      list = list.where((e) {
        return keywords.every((keyword) {
          return e.name.toLowerCase().contains(keyword) ||
              e.categoryName.toLowerCase().contains(keyword) ||
              e.categorySlug.toLowerCase().contains(keyword) ||
              e.description.toLowerCase().contains(keyword) ||
              e.tags.any((t) => t.toLowerCase().contains(keyword));
        });
      }).toList();
    }

    // Sort
    switch (sortBy.value) {
      case 'price_low':
        list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_high':
        list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      default:
        // 'popular' and 'latest' both sort by popularity
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
    }

    // Temporary debug logs for filter investigation
    print("Selected Category: $selectedName");
    print("ID: ${selectedId.isEmpty ? 'N/A' : selectedId}");
    print("Slug: $selectedSlug");
    print("Name: $selectedName");

    for (final e in _allActiveExperiences) {
      final relationExists = e.categoryIds.any((id) => rxCategories.any((c) => c.id == id));
      final matchesSelected = selectedId.isEmpty || e.categoryIds.contains(selectedId);
      print("Experience: ${e.name}");
      print("Category ID: ${e.categoryId}");
      print("Category Name: ${e.categoryName}");
      print("Category Slug: ${e.categorySlug}");
      print("Relation Loaded: ${relationExists ? 'YES' : 'NO'}");
      print("Matches Selected Category: ${matchesSelected ? 'YES' : 'NO'}");
    }

    print("Total Experiences Loaded: ${_allActiveExperiences.length}");
    print("Filtered Experiences: ${list.length}");
    print("IDs Returned: ${list.map((e) => e.id).join(', ')}");

    rxExperiences.assignAll(list);
  }

  // ── Public API (UI compatibility) ──────────────────────────────────────────

  /// Force re-subscription to all Firestore streams (pull-to-refresh).
  /// Streams auto-refresh on Firestore changes; this is a fallback.
  Future<void> refreshCatalog() async {
    _categoriesSub?.cancel();
    _experiencesSub?.cancel();
    _reviewsSub?.cancel();
    _bindRealtimeStreams();
  }

  /// Kept for backward compatibility — streams handle this automatically.
  Future<void> loadCategories() async {}

  /// Kept for backward compatibility — [_applyExperienceFilters] handles this.
  Future<void> loadExperiences() async {
    _applyExperienceFilters();
  }

  void selectCategory(String slug) {
    // Toggle: tap the same category again to deselect
    selectedCategorySlug.value = selectedCategorySlug.value == slug ? '' : slug;
    resetVisibleCount();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    resetVisibleCount();
    _applyExperienceFilters();
  }

  void updateSort(String option) {
    sortBy.value = option;
  }

  // ── Lead / Callback form ───────────────────────────────────────────────────

  Future<bool> requestCallback({
    required String name,
    required String phone,
    required String dateStr,
    required String budgetStr,
    required String requirements,
  }) async {
    if (!AppValidators.isValidName(name)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid name (at least 2 letters).",
      );
      return false;
    }
    if (!AppValidators.isValidPhone(phone)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
      );
      return false;
    }

    try {
      isSubmittingLead.value = true;
      final cleanedPhone = AppValidators.cleanPhone(phone);
      final budget = double.tryParse(budgetStr) ?? 0.0;
      final eventDate = DateTime.tryParse(dateStr);

      final lead = Lead(
        id: '',
        name: name.trim(),
        phone: cleanedPhone,
        email: '',
        requestType: 'callback',
        eventDate: eventDate,
        budget: budget > 0 ? budget : null,
        requirements: requirements.trim(),
        status: 'new',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await submitLead(lead);

      // If customer is logged in, link lead to customer portal
      final authCtrl = Get.find<CustomerAuthController>();
      final customerId = authCtrl.rxCustomerProfile.value?.id ?? '';
      if (customerId.isNotEmpty) {
        final leadId = DateTime.now().millisecondsSinceEpoch.toString();
        final customerLeadRef = FirebaseFirestore.instance.collection(AppCollections.customerLeads).doc(leadId);
        await customerLeadRef.set({
          'customerId': customerId,
          'leadNumber': 'L-${DateTime.now().millisecondsSinceEpoch}',
          'date': DateTime.now().toIso8601String(),
          'service': requirements.trim().isNotEmpty ? requirements.trim() : 'Event Inquiry',
          'branch': authCtrl.rxCustomerProfile.value?.branch ?? 'Ahmedabad',
          'budget': budget,
          'eventDate': eventDate?.toIso8601String() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'status': 'Pending',
          'adminNotes': '',
        });
      }

      Get.snackbar(
        "Inquiry Received",
        "Thank you! Our event manager will call you shortly.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on Failure catch (e) {
      Get.snackbar("Inquiry Failed", e.message);
      return false;
    } catch (e) {
      Get.snackbar("Inquiry Failed", e.toString());
      return false;
    } finally {
      isSubmittingLead.value = false;
    }
  }

  Future<void> _correctDatabaseRelationships() async {
    try {
      final itemsCol = FirebaseFirestore.instance.collection(AppCollections.items);
      final catsCol = FirebaseFirestore.instance.collection(AppCollections.categories);

      // Define multi-category mapping table
      final Map<String, List<String>> experienceCategoryMappings = {
        'wild-one-safari': ['grand-entries', 'birthday', 'balloon--flower-decoration'],
        'pastel-dream-birthday': ['baby', 'shrimant-sanskar', 'flower-decoration', 'balloon--flower-decoration'],
        'ivory-vow-stage': ['chhathi-poojan', 'baby', 'flower-decoration', 'balloon--flower-decoration'],
        'saffron-ring-ceremony': ['wedding', 'flower-decoration'],
        'little-cloud-welcome': ['wedding', 'flower-decoration'],
        'teddy-garden-shower': ['baby', 'balloon--flower-decoration', 'flower-decoration'],
        'signature-brand-launch': ['grand-entries', 'wedding'],
        'opening-day-essentials': ['wedding', 'flower-decoration', 'balloon--flower-decoration'],
        'moonlit-marry-me': ['birthday', 'balloon--flower-decoration'],
        'terrace-sunset-story': ['grand-entries', 'wedding'],
        'royal-fog-entry': ['birthday', 'balloon--flower-decoration'],
        'flower-shower-walk': ['grand-entries', 'flower-decoration'],
      };

      // Perform dynamic batch migration for multi-category support
      for (final entry in experienceCategoryMappings.entries) {
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
              print("DATABASE MIGRATION: Migrated $itemId to multiple categories $targetCatIds");
            }
          }
        }
      }
    } catch (e) {
      print("DATABASE MIGRATION ERROR: $e");
    }
  }
}
