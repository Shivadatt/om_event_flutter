import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import 'notification_gateway_service.dart';
import 'fcm_notification_service.dart';

part 'parts/local_notification_listeners.dart';
part 'parts/local_notification_queue_runner.dart';

class LocalNotificationTriggerService extends GetxService {
  static LocalNotificationTriggerService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _schedulerTimer;
  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    startLocalListeners();
    startLocalQueueRunner();
    _startLocalSchedulerSimulator();
  }

  @override
  void onClose() {
    _schedulerTimer?.cancel();
    super.onClose();
  }

  /// 3. Cron Scheduler Simulator
  void _startLocalSchedulerSimulator() {
    _schedulerTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        final now = Timestamp.now();
        final snap = await _firestore
            .collection(AppCollections.scheduledNotifications)
            .where('status', isEqualTo: 'pending')
            .where('triggerAt', isLessThanOrEqualTo: now)
            .get();

        if (snap.docs.isEmpty) return;

        final batch = _firestore.batch();
        for (var doc in snap.docs) {
          final data = doc.data();

          final queueRef = _firestore.collection(AppCollections.notificationQueue).doc();
          batch.set(queueRef, {
            'recipient': data['recipient'] ?? '',
            'recipientId': data['recipientId'] ?? '',
            'type': data['eventType'] ?? 'Scheduled Reminder',
            'title': data['title'] ?? '',
            'body': data['body'] ?? '',
            'channel': data['channel'] ?? 'email',
            'status': 'pending',
            'priority': data['priority'] ?? 'normal',
            'retryCount': 0,
            'errorMessage': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          batch.update(doc.reference, {
            'status': 'sent',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      } catch (_) {}
    });
  }
}
