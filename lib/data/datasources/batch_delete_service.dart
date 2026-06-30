import 'package:cloud_firestore/cloud_firestore.dart';

class BatchDeleteService {
  final FirebaseFirestore _firestore;

  BatchDeleteService(this._firestore);

  /// Deletes all documents in the specified Firestore collections in batches of 200.
  Future<void> deleteCollections(List<String> collectionNames, Function(String currentCollection) onCollectionCleared) async {
    for (final collection in collectionNames) {
      onCollectionCleared(collection);
      await _clearCollection(collection);
    }
  }

  Future<void> _clearCollection(String collectionName) async {
    final collectionRef = _firestore.collection(collectionName);
    while (true) {
      final snapshot = await collectionRef.limit(200).get();
      if (snapshot.docs.isEmpty) {
        break;
      }
      final WriteBatch batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
