import 'package:cloud_firestore/cloud_firestore.dart';

class BatchInsertService {
  final FirebaseFirestore _firestore;

  BatchInsertService(this._firestore);

  /// Inserts a list of document maps into a Firestore collection using WriteBatch.
  /// Automatically slices operations into chunks of 400 documents to respect write limits.
  Future<void> insertDocuments(
    String collectionName,
    List<Map<String, dynamic>> documents,
  ) async {
    if (documents.isEmpty) return;

    final int chunkSize = 400;
    for (int i = 0; i < documents.length; i += chunkSize) {
      final end =
          (i + chunkSize < documents.length) ? i + chunkSize : documents.length;
      final chunk = documents.sublist(i, end);

      final WriteBatch batch = _firestore.batch();
      for (final doc in chunk) {
        final id = doc['id'] as String;
        final docRef = _firestore.collection(collectionName).doc(id);
        // Exclude the ID field from payload to avoid redundancy inside document values
        final Map<String, dynamic> data = Map.from(doc)..remove('id');
        batch.set(docRef, data);
      }
      await batch.commit();
    }
  }
}
