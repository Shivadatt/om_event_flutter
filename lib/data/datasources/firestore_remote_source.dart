import 'package:cloud_firestore/cloud_firestore.dart';
import 'sql_seed_data.dart';

class FirestoreRemoteSource {
  final FirebaseFirestore _firestore;
  FirestoreRemoteSource(this._firestore);

  // Auto-seed check
  Future<void> ensureSeeded() async {
    final catSnap = await _firestore.collection('categories').limit(1).get();
    if (catSnap.docs.isEmpty) {
      await _seedDatabase();
    }
  }

  // Categories
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchCategories() async {
    final snap = await _firestore
        .collection('categories')
        .where('is_active', isEqualTo: true)
        .orderBy('sort_order')
        .get();
    return snap.docs;
  }

  // Experiences (Items)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchExperiences({
    String? categorySlug,
    String? searchQuery,
    String? themeFilter,
    bool? featuredOnly,
    String? sortBy,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('items').where('is_active', isEqualTo: true);

    if (categorySlug != null && categorySlug.isNotEmpty) {
      query = query.where('category_id', isEqualTo: categorySlug);
    }
    if (featuredOnly == true) {
      query = query.where('is_featured', isEqualTo: true);
    }

    final snap = await query.get();
    var docs = snap.docs;

    // Direct memory filtering for search query and theme filter (since Firestore does not support text searches like Q objects in Django)
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
      // popular
      docs.sort((a, b) {
        final pa = (a.data()['popularity'] ?? 0) as num;
        final pb = (b.data()['popularity'] ?? 0) as num;
        return pb.compareTo(pa);
      });
    }

    return docs;
  }

  // Experience Detail
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchExperienceDetail(String slug) async {
    final snap = await _firestore.collection('items').where('slug', isEqualTo: slug).limit(1).get();
    if (snap.docs.isEmpty) {
      throw Exception("Experience details not found.");
    }
    final doc = snap.docs.first;
    // Increment popularity in background
    _firestore.collection('items').doc(doc.id).update({
      'popularity': FieldValue.increment(1),
    });
    return doc;
  }

  // Reviews
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchPublishedReviews() async {
    final snap = await _firestore
        .collection('reviews')
        .where('is_published', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(12)
        .get();
    return snap.docs;
  }

  // Leads
  Future<DocumentReference<Map<String, dynamic>>> submitLead(Map<String, dynamic> leadJson) async {
    return await _firestore.collection('leads').add({
      ...leadJson,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLeads() async {
    final snap = await _firestore.collection('leads').orderBy('created_at', descending: true).get();
    return snap.docs;
  }

  Future<void> updateLeadStatus(String id, String status) async {
    await _firestore.collection('leads').doc(id).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Quotations
  Future<void> submitQuotation(Map<String, dynamic> quoteJson, String quoteId) async {
    await _firestore.collection('quotations').doc(quoteId).set({
      ...quoteJson,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchQuotations() async {
    final snap = await _firestore.collection('quotations').orderBy('created_at', descending: true).get();
    return snap.docs;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchQuotationByPublicId(String publicId) async {
    final snap = await _firestore.collection('quotations').where('public_id', isEqualTo: publicId).limit(1).get();
    if (snap.docs.isEmpty) {
      throw Exception("Quotation not found.");
    }
    return snap.docs.first;
  }

  Future<void> updateQuotationStatus(String id, String status) async {
    await _firestore.collection('quotations').doc(id).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Customer Management
  Future<void> upsertCustomer({
    required String phone,
    required String name,
    required String email,
  }) async {
    final docRef = _firestore.collection('customers').doc(phone);
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

  // Admin CRUD for Categories
  Future<void> createCategory(Map<String, dynamic> json) async {
    await _firestore.collection('categories').doc(json['slug'] as String).set(json);
  }
  Future<void> updateCategory(String slug, Map<String, dynamic> json) async {
    await _firestore.collection('categories').doc(slug).update(json);
  }
  Future<void> deleteCategory(String slug) async {
    await _firestore.collection('categories').doc(slug).delete();
  }

  // Admin CRUD for Experiences (Items)
  Future<void> createExperience(Map<String, dynamic> json) async {
    await _firestore.collection('items').doc(json['slug'] as String).set(json);
  }
  Future<void> updateExperience(String slug, Map<String, dynamic> json) async {
    await _firestore.collection('items').doc(slug).update(json);
  }
  Future<void> deleteExperience(String slug) async {
    await _firestore.collection('items').doc(slug).delete();
  }

  // Admin CRUD for Customers
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchCustomers() async {
    final snap = await _firestore.collection('customers').orderBy('created_at', descending: true).get();
    return snap.docs;
  }
  Future<void> deleteCustomer(String phone) async {
    await _firestore.collection('customers').doc(phone).delete();
  }
  Future<void> updateCustomerDetails(String phone, Map<String, dynamic> json) async {
    await _firestore.collection('customers').doc(phone).update(json);
  }

  // Admin CRUD for User Profiles
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    final snap = await _firestore.collection('users').get();
    return snap.docs;
  }
  Future<void> createUserProfile(String uid, Map<String, dynamic> json) async {
    await _firestore.collection('users').doc(uid).set(json);
  }
  Future<void> updateUserProfile(String uid, Map<String, dynamic> json) async {
    await _firestore.collection('users').doc(uid).update(json);
  }
  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // Admin Roles RBAC collection queries
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAdminRoles() async {
    final snap = await _firestore.collection('admin').get();
    return snap.docs;
  }
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchAdminRole(String uid) async {
    return await _firestore.collection('admin').doc(uid).get();
  }
  Future<void> upsertAdminRole(String uid, Map<String, dynamic> json) async {
    await _firestore.collection('admin').doc(uid).set(json);
  }
  Future<void> deleteAdminRole(String uid) async {
    await _firestore.collection('admin').doc(uid).delete();
  }

  // Seeding Logic
  Future<void> _seedDatabase() async {
    final batch = _firestore.batch();

    for (var cat in SqlSeedData.categories) {
      final ref = _firestore.collection('categories').doc(cat['slug'] as String);
      batch.set(ref, cat);
    }

    for (var item in SqlSeedData.decorationItems) {
      final ref = _firestore.collection('items').doc(item['slug'] as String);
      batch.set(ref, item);
    }

    for (var review in SqlSeedData.reviews) {
      final ref = _firestore.collection('reviews').doc();
      batch.set(ref, review);
    }

    await batch.commit();
  }
}
