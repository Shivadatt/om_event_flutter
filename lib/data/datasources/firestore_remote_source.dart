import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_collections.dart';

part 'parts/firestore_catalog.dart';
part 'parts/firestore_orders.dart';

/// Low-level Firestore data access layer.
/// All collection strings are sourced from [AppCollections].
class FirestoreRemoteSource {
  final FirebaseFirestore _firestore;

  /// Creates a [FirestoreRemoteSource] instance.
  FirestoreRemoteSource(this._firestore);
}
