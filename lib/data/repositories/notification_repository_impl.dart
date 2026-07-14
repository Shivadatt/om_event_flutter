import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/customer_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/customer_portal_models.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl(this._firestore);

  @override
  Future<Map<String, dynamic>?> getPreferences(String customerId) async {
    final doc = await _firestore
        .collection(AppCollections.customerNotificationPreferences)
        .doc(customerId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<void> savePreferences(String customerId, Map<String, dynamic> preferences) async {
    await _firestore
        .collection(AppCollections.customerNotificationPreferences)
        .doc(customerId)
        .set(preferences, SetOptions(merge: true));
  }

  @override
  Stream<List<CustomerNotification>> getNotifications(String customerId) {
    return _firestore
        .collection(AppCollections.customerNotifications)
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CustomerNotificationModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(AppCollections.customerNotifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String customerId) async {
    final snap = await _firestore
        .collection(AppCollections.customerNotifications)
        .where('customerId', isEqualTo: customerId)
        .where('isRead', isEqualTo: false)
        .get();
    
    if (snap.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> archiveNotification(String notificationId, bool isArchived) async {
    await _firestore
        .collection(AppCollections.customerNotifications)
        .doc(notificationId)
        .update({'isArchived': isArchived});
  }
}
