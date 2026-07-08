part of '../firestore_remote_source.dart';

extension FirestoreCatalog on FirestoreRemoteSource {
  /// Fetch all active event decoration categories.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchCategories() async {
    final snap = await _firestore
        .collection(AppCollections.categories)
        .where('is_active', isEqualTo: true)
        .get();
    final docs = snap.docs.toList();
    docs.sort((a, b) {
      final sa = (a.data()['sort_order'] ?? 999) as int;
      final sb = (b.data()['sort_order'] ?? 999) as int;
      return sa.compareTo(sb);
    });
    return docs;
  }

  /// Fetch ALL categories regardless of [is_active] status.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAllCategories() async {
    final snap = await _firestore.collection(AppCollections.categories).get();
    final docs = snap.docs.toList();
    docs.sort((a, b) {
      final sa = (a.data()['sort_order'] ?? 999) as int;
      final sb = (b.data()['sort_order'] ?? 999) as int;
      return sa.compareTo(sb);
    });
    return docs;
  }

  /// Toggle the [is_active] flag on a single category document.
  Future<void> toggleCategoryStatus(String slug, {required bool isActive}) async {
    await _firestore
        .collection(AppCollections.categories)
        .doc(slug)
        .update({'is_active': isActive});
  }

  /// Realtime stream of active categories, sorted in-memory by [sort_order].
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamActiveCategories() {
    return _firestore
        .collection(AppCollections.categories)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final sa = (a.data()['sort_order'] ?? 999) as int;
        final sb = (b.data()['sort_order'] ?? 999) as int;
        return sa.compareTo(sb);
      });
      return docs;
    });
  }

  /// Realtime stream of ALL categories (active + inactive) for the Admin Panel.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamAllCategories() {
    return _firestore.collection(AppCollections.categories).snapshots().map((snap) {
      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final sa = (a.data()['sort_order'] ?? 999) as int;
        final sb = (b.data()['sort_order'] ?? 999) as int;
        return sa.compareTo(sb);
      });
      return docs;
    });
  }

  /// Realtime stream of ALL active decoration items (unfiltered).
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamAllActiveItems() {
    return _firestore
        .collection(AppCollections.items)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// Realtime stream of published customer reviews, sorted descending by creation date.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamPublishedReviews() {
    return _firestore
        .collection(AppCollections.reviews)
        .where('is_published', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final docs = snap.docs.where((doc) {
        final data = doc.data();
        final isActive = data['is_active'] ?? data['isActive'] ?? true;
        return isActive == true;
      }).toList();

      docs.sort((a, b) {
        final dataA = a.data();
        final dataB = b.data();

        final featA = dataA['is_featured'] ?? dataA['isFeatured'] ?? false;
        final featB = dataB['is_featured'] ?? dataB['isFeatured'] ?? false;
        if (featA != featB) return featB ? 1 : -1;

        final orderA = dataA['display_order'] ?? dataA['displayOrder'] ?? 1;
        final orderB = dataB['display_order'] ?? dataB['displayOrder'] ?? 1;
        if (orderA != orderB) return orderA.compareTo(orderB);

        final dateA = dataA['created_at'] ?? '';
        final dateB = dataB['created_at'] ?? '';
        return dateB.toString().compareTo(dateA.toString());
      });

      return docs;
    });
  }

  /// Fetch active decoration items with optional filters and sorting.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
    bool? activeOnly,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(AppCollections.items);

    if (activeOnly != false) {
      query = query.where('is_active', isEqualTo: true);
    }

    if (categorySlug != null && categorySlug.isNotEmpty) {
      query = query.where('category_id', isEqualTo: categorySlug);
    }
    if (featuredOnly == true) {
      query = query.where('is_featured', isEqualTo: true);
    }

    final snap = await query.get();
    var docs = snap.docs;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      docs = docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] as String? ?? '').toLowerCase();
        final desc = (data['description'] as String? ?? '').toLowerCase();
        final tags = (data['tags'] as List? ?? []).join(' ').toLowerCase();
        return name.contains(queryLower) || desc.contains(queryLower) || tags.contains(queryLower);
      }).toList();
    }

    if (themeFilter != null && themeFilter.isNotEmpty) {
      final themeLower = themeFilter.toLowerCase();
      docs = docs.where((doc) {
        final themes = List<String>.from(doc.data()['themes'] ?? []);
        return themes.any((t) => t.toLowerCase() == themeLower);
      }).toList();
    }

    if (sortBy == 'price_low') {
      docs.sort((a, b) {
        final pa = (a.data()['offer_price'] ?? a.data()['price'] ?? 0) as num;
        final pb = (b.data()['offer_price'] ?? b.data()['price'] ?? 0) as num;
        return pa.compareTo(pb);
      });
    } else if (sortBy == 'price_high') {
      docs.sort((a, b) {
        final pa = (a.data()['offer_price'] ?? a.data()['price'] ?? 0) as num;
        final pb = (b.data()['offer_price'] ?? b.data()['price'] ?? 0) as num;
        return pb.compareTo(pa);
      });
    } else if (sortBy == 'latest') {
      docs.sort((a, b) {
        final da = a.data()['created_at'] ?? '';
        final db = b.data()['created_at'] ?? '';
        return db.toString().compareTo(da.toString());
      });
    } else {
      docs.sort((a, b) {
        final pa = (a.data()['popularity'] ?? 0) as num;
        final pb = (b.data()['popularity'] ?? 0) as num;
        return pb.compareTo(pa);
      });
    }

    return docs;
  }

  /// Fetch detail for a single experience by its URL slug.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchExperienceDetail(String slug) async {
    final snap = await _firestore
        .collection(AppCollections.items)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      throw Exception('Experience details not found.');
    }
    final doc = snap.docs.first;
    _firestore.collection(AppCollections.items).doc(doc.id).update({
      'popularity': FieldValue.increment(1),
    });
    return doc;
  }

  /// Fetch the 12 most recent published reviews.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchPublishedReviews() async {
    final snap = await _firestore
        .collection(AppCollections.reviews)
        .where('is_published', isEqualTo: true)
        .get();

    final docs = snap.docs.where((doc) {
      final data = doc.data();
      final isActive = data['is_active'] ?? data['isActive'] ?? true;
      return isActive == true;
    }).toList();

    docs.sort((a, b) {
      final dataA = a.data();
      final dataB = b.data();

      final featA = dataA['is_featured'] ?? dataA['isFeatured'] ?? false;
      final featB = dataB['is_featured'] ?? dataB['isFeatured'] ?? false;
      if (featA != featB) return featB ? 1 : -1;

      final orderA = dataA['display_order'] ?? dataA['displayOrder'] ?? 1;
      final orderB = dataB['display_order'] ?? dataB['displayOrder'] ?? 1;
      if (orderA != orderB) return orderA.compareTo(orderB);

      final dateA = dataA['created_at'] ?? '';
      final dateB = dataB['created_at'] ?? '';
      return dateB.toString().compareTo(dateA.toString());
    });

    return docs.length > 12 ? docs.sublist(0, 12) : docs;
  }

  /// Create a new category document keyed by its slug.
  Future<void> createCategory(Map<String, dynamic> json) async {
    await _firestore
        .collection(AppCollections.categories)
        .doc(json['slug'] as String)
        .set(json);
  }

  /// Update an existing category document.
  Future<void> updateCategory(String slug, Map<String, dynamic> json) async {
    await _firestore
        .collection(AppCollections.categories)
        .doc(slug)
        .update(json);
  }

  /// Delete a category document.
  Future<void> deleteCategory(String slug) async {
    await _firestore.collection(AppCollections.categories).doc(slug).delete();
  }

  /// Create a new experience document keyed by its slug.
  Future<void> createExperience(Map<String, dynamic> json) async {
    await _firestore
        .collection(AppCollections.items)
        .doc(json['slug'] as String)
        .set(json);
  }

  /// Update an existing experience document.
  Future<void> updateExperience(String slug, Map<String, dynamic> json) async {
    await _firestore.collection(AppCollections.items).doc(slug).update(json);
  }

  /// Delete an experience document.
  Future<void> deleteExperience(String slug) async {
    await _firestore.collection(AppCollections.items).doc(slug).delete();
  }
}
