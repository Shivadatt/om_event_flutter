import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_collections.dart';
import 'sql_seed_data.dart';

/// Low-level Firestore data access layer.
/// All collection strings are sourced from [AppCollections].
class FirestoreRemoteSource {
  final FirebaseFirestore _firestore;

  /// Creates a [FirestoreRemoteSource] instance.
  FirestoreRemoteSource(this._firestore);

  // ── Auto-seed ─────────────────────────────────────────────────────────────

  /// Ensures the database is seeded before any catalog fetch.
  Future<void> ensureSeeded() async {
    final catSnap =
        await _firestore.collection(AppCollections.categories).limit(1).get();
    if (catSnap.docs.isEmpty) {
      await _seedDatabase();
    }
  }

  // ── Categories ────────────────────────────────────────────────────────────

  /// Fetch all active event decoration categories.
  /// Used by the Customer Website — inactive categories are excluded.
  /// Sorted in-memory by [sort_order] to avoid requiring a composite Firestore index.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchCategories() async {
    final snap =
        await _firestore
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
  /// Used exclusively by the Admin Panel so inactive categories remain visible.
  /// Sorted in-memory by [sort_order] to avoid requiring a composite Firestore index.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchAllCategories() async {
    final snap =
        await _firestore
            .collection(AppCollections.categories)
            .get();
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

  // ── Realtime Streams ──────────────────────────────────────────────────────

  /// Realtime stream of active categories, sorted in-memory by [sort_order].
  /// Customer website subscribes to this — inactive categories are excluded.
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
    return _firestore
        .collection(AppCollections.categories)
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

  /// Realtime stream of ALL active decoration items (unfiltered).
  /// Filtering by category, search, and sort is done in-memory by the controller.
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
          final docs = snap.docs.toList();
          // Sort by created_at descending in-memory (no composite index needed)
          docs.sort((a, b) {
            final da = a.data()['created_at'] ?? '';
            final db = b.data()['created_at'] ?? '';
            return db.toString().compareTo(da.toString());
          });
          return docs.length > 12 ? docs.sublist(0, 12) : docs;
        });
  }

  // ── Experiences ───────────────────────────────────────────────────────────


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
      docs =
          docs.where((doc) {
            final data = doc.data();
            final name = (data['name'] as String? ?? '').toLowerCase();
            final desc = (data['description'] as String? ?? '').toLowerCase();
            final tags = (data['tags'] as List? ?? []).join(' ').toLowerCase();
            return name.contains(queryLower) ||
                desc.contains(queryLower) ||
                tags.contains(queryLower);
          }).toList();
    }

    if (themeFilter != null && themeFilter.isNotEmpty) {
      final themeLower = themeFilter.toLowerCase();
      docs =
          docs.where((doc) {
            final themes = List<String>.from(doc.data()['themes'] ?? []);
            return themes.any((t) => t.toLowerCase() == themeLower);
          }).toList();
    }

    // Sort in memory
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
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchExperienceDetail(
    String slug,
  ) async {
    final snap =
        await _firestore
            .collection(AppCollections.items)
            .where('slug', isEqualTo: slug)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) {
      throw Exception('Experience details not found.');
    }
    final doc = snap.docs.first;
    // Increment popularity in background
    _firestore.collection(AppCollections.items).doc(doc.id).update({
      'popularity': FieldValue.increment(1),
    });
    return doc;
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  /// Fetch the 12 most recent published reviews.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchPublishedReviews() async {
    final snap =
        await _firestore
            .collection(AppCollections.reviews)
            .where('is_published', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .limit(12)
            .get();
    return snap.docs;
  }

  // ── Leads ─────────────────────────────────────────────────────────────────

  /// Submit a new contact / inquiry lead.
  Future<DocumentReference<Map<String, dynamic>>> submitLead(
    Map<String, dynamic> leadJson,
  ) async {
    return await _firestore.collection(AppCollections.leads).add({
      ...leadJson,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all leads ordered by creation date descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLeads() async {
    final snap =
        await _firestore
            .collection(AppCollections.leads)
            .orderBy('created_at', descending: true)
            .get();
    return snap.docs;
  }

  /// Update the status of an existing lead.
  Future<void> updateLeadStatus(String id, String status) async {
    await _firestore.collection(AppCollections.leads).doc(id).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ── Quotations ────────────────────────────────────────────────────────────

  /// Submit or overwrite a quotation document.
  Future<void> submitQuotation(
    Map<String, dynamic> quoteJson,
    String quoteId,
  ) async {
    await _firestore.collection(AppCollections.quotations).doc(quoteId).set({
      ...quoteJson,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all quotations ordered by creation date descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchQuotations() async {
    final snap =
        await _firestore
            .collection(AppCollections.quotations)
            .orderBy('created_at', descending: true)
            .get();
    return snap.docs;
  }

  /// Fetch a single quotation by its public share ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchQuotationByPublicId(
    String publicId,
  ) async {
    final snap =
        await _firestore
            .collection(AppCollections.quotations)
            .where('public_id', isEqualTo: publicId)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) {
      throw Exception('Quotation not found.');
    }
    return snap.docs.first;
  }

  /// Update the status of an existing quotation.
  Future<void> updateQuotationStatus(String id, String status) async {
    await _firestore.collection(AppCollections.quotations).doc(id).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ── Customer Management ───────────────────────────────────────────────────

  /// Create or update a CRM customer record keyed by phone number.
  Future<void> upsertCustomer({
    required String phone,
    required String name,
    required String email,
  }) async {
    final docRef = _firestore.collection(AppCollections.customers).doc(phone);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'name': name,
        'phone': phone,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'name': name,
        'email': email,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Admin CRUD for Categories ─────────────────────────────────────────────

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

  // ── Admin CRUD for Experiences ────────────────────────────────────────────

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

  // ── Admin CRUD for Customers ──────────────────────────────────────────────

  /// Fetch all CRM customers ordered by creation date descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchCustomers() async {
    final snap =
        await _firestore
            .collection(AppCollections.customers)
            .orderBy('created_at', descending: true)
            .get();
    return snap.docs;
  }

  /// Delete a customer record.
  Future<void> deleteCustomer(String phone) async {
    await _firestore.collection(AppCollections.customers).doc(phone).delete();
  }

  /// Update specific fields on a customer record.
  Future<void> updateCustomerDetails(
    String phone,
    Map<String, dynamic> json,
  ) async {
    await _firestore
        .collection(AppCollections.customers)
        .doc(phone)
        .update(json);
  }

  // ── Admin CRUD for User Profiles ──────────────────────────────────────────

  /// Fetch all registered app users.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    final snap = await _firestore.collection(AppCollections.users).get();
    return snap.docs;
  }

  /// Create a new user profile document.
  Future<void> createUserProfile(String uid, Map<String, dynamic> json) async {
    await _firestore.collection(AppCollections.users).doc(uid).set(json);
  }

  /// Update an existing user profile document.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> json) async {
    await _firestore.collection(AppCollections.users).doc(uid).update(json);
  }

  /// Delete a user profile document.
  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection(AppCollections.users).doc(uid).delete();
  }

  // ── Admin Roles RBAC ──────────────────────────────────────────────────────

  /// Fetch all administrator role documents.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchAdminRoles() async {
    final snap = await _firestore.collection(AppCollections.admin).get();
    return snap.docs;
  }

  /// Fetch a single admin role document by UID.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchAdminRole(
    String uid,
  ) async {
    return await _firestore.collection(AppCollections.admin).doc(uid).get();
  }

  /// Create or overwrite an admin role document.
  Future<void> upsertAdminRole(String uid, Map<String, dynamic> json) async {
    await _firestore.collection(AppCollections.admin).doc(uid).set(json);
  }

  /// Delete an admin role document.
  Future<void> deleteAdminRole(String uid) async {
    await _firestore.collection(AppCollections.admin).doc(uid).delete();
  }

  // ── Seeding Logic ─────────────────────────────────────────────────────────

  Future<void> _seedDatabase() async {
    final batch = _firestore.batch();

    for (var cat in SqlSeedData.categories) {
      final ref = _firestore
          .collection(AppCollections.categories)
          .doc(cat['slug'] as String);
      batch.set(ref, cat);
    }

    for (var item in SqlSeedData.decorationItems) {
      final ref = _firestore
          .collection(AppCollections.items)
          .doc(item['slug'] as String);
      batch.set(ref, item);
    }

    for (var review in SqlSeedData.reviews) {
      final ref = _firestore.collection(AppCollections.reviews).doc();
      batch.set(ref, review);
    }

    await batch.commit();
  }
}
