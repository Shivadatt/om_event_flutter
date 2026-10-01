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
  /// Preserves all existing extended profile fields (address, city, state, pincode, profile_image_url).
  Future<void> upsertCustomer({
    required String phone,
    required String name,
    required String email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? branch,
    String? gender,
    dynamic dateOfBirth,
    String? profileImageUrl,
  }) async {
    try {
      final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
      final tenDigit = cleanDigits.length >= 10
          ? cleanDigits.substring(cleanDigits.length - 10)
          : phone.trim();
      final docId = tenDigit.isNotEmpty ? tenDigit : phone.trim();
      if (docId.isEmpty) return;

      final docRef = _firestore.collection(AppCollections.customers).doc(docId);
      final Map<String, dynamic> data = {
        'name': name.trim(),
        'full_name': name.trim(),
        'phone': phone.trim(),
        if (email.isNotEmpty) 'email': email.trim(),
        if (address != null && address.isNotEmpty) 'address': address.trim(),
        if (city != null && city.isNotEmpty) 'city': city.trim(),
        if (state != null && state.isNotEmpty) 'state': state.trim(),
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode.trim(),
        if (branch != null && branch.isNotEmpty) 'branch': branch.trim(),
        if (gender != null && gender.isNotEmpty) 'gender': gender.trim(),
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth is DateTime ? dateOfBirth.toIso8601String() : dateOfBirth.toString().trim(),
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) ...{
          'profile_image_url': profileImageUrl.trim(),
          'profileImageUrl': profileImageUrl.trim(),
        },
        'updated_at': FieldValue.serverTimestamp(),
      };
      await docRef.set(data, SetOptions(merge: true));
    } catch (_) {
      // Best-effort CRM lead update for guest/anonymous sessions
    }
  }

  /// Fetch all CRM customers without filtering out docs missing created_at.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchCustomers() async {
    final snap = await _firestore
        .collection(AppCollections.customers)
        .get();
    return snap.docs;
  }

  /// Realtime stream of all CRM customer documents.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamCustomers() {
    return _firestore
        .collection(AppCollections.customers)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// Create a new customer document keyed by phone/id.
  Future<void> createCustomer(Map<String, dynamic> json) async {
    final docId = (json['id'] ?? json['phone'] ?? '').toString().trim();
    if (docId.isEmpty) {
      throw ArgumentError("Customer document ID / Phone cannot be empty");
    }
    await _firestore
        .collection(AppCollections.customers)
        .doc(docId)
        .set(json, SetOptions(merge: true));
  }

  /// Delete a customer record by ID or phone.
  Future<void> deleteCustomer(String idOrPhone) async {
    await _firestore.collection(AppCollections.customers).doc(idOrPhone).delete();
  }

  /// Update specific fields on a customer record.
  Future<void> updateCustomerDetails(String idOrPhone, Map<String, dynamic> json) async {
    await _firestore
        .collection(AppCollections.customers)
        .doc(idOrPhone)
        .set(json, SetOptions(merge: true));
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
