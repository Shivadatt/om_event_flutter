part of '../firestore_remote_source.dart';

extension FirestoreOrders on FirestoreRemoteSource {
  /// Submit a new contact / inquiry lead.
  Future<DocumentReference<Map<String, dynamic>>> submitLead(Map<String, dynamic> leadJson) async {
    return await _firestore.collection(AppCollections.leads).add({
      ...leadJson,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all leads ordered by creation date descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLeads() async {
    final snap = await _firestore
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

  /// Submit or overwrite a quotation document.
  Future<void> submitQuotation(Map<String, dynamic> quoteJson, String quoteId) async {
    await _firestore.collection(AppCollections.quotations).doc(quoteId).set({
      ...quoteJson,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all quotations ordered by creation date descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchQuotations() async {
    final snap = await _firestore
        .collection(AppCollections.quotations)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs;
  }

  /// Fetch a single quotation by its public share ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchQuotationByPublicId(String publicId) async {
    final snap = await _firestore
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

  /// Fetch all CRM customers ordered by creation date descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchCustomers() async {
    final snap = await _firestore
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
  Future<void> updateCustomerDetails(String phone, Map<String, dynamic> json) async {
    await _firestore
        .collection(AppCollections.customers)
        .doc(phone)
        .update(json);
  }

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

  /// Fetch all administrator role documents.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAdminRoles() async {
    final snap = await _firestore.collection(AppCollections.admin).get();
    return snap.docs;
  }

  /// Fetch a single admin role document by UID.
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchAdminRole(String uid) async {
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
}
