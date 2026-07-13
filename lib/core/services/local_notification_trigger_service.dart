import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import '../../domain/entities/quotation.dart';
import '../../data/models/quotation_model.dart';
import 'notification_gateway_service.dart';
import 'fcm_notification_service.dart';

part 'parts/local_notification_listeners.dart';
part 'parts/local_notification_queue_runner.dart';

/// Service managing local simulation triggers (e.g. queue runners and scheduler tests in Debug Mode).
/// Crucial: Zero auth listener duplicates. Zero direct stream attachments on initialization.
class LocalNotificationTriggerService extends GetxService {
  static LocalNotificationTriggerService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _schedulerTimer;
  final Random _random = Random();


  @override
  void onClose() {
    teardown();
    super.onClose();
  }

  /// Initialize trigger states based on the resolved authenticated user's role.
  /// Triggered exclusively by ListenerRegistryService/BootstrapService.
  void initForUser(String uid, String role) {
    teardown();
    debugPrint("LocalNotificationTriggerService: Initializing trigger tasks for UID: $uid, Role: $role");
    
    if (role == 'admin' || role == 'staff' || role == 'demo_admin' || role == 'super_admin') {
      if (kDebugMode) {
        _startLocalSchedulerSimulator();
      }
    }
  }

  /// Cleanly cancels all background simulator timers.
  void teardown() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
    debugPrint("LocalNotificationTriggerService: Terminated trigger services and simulator timers.");
  }

  /// 3. Cron Scheduler Simulator (Debug Mode Only)
  void _startLocalSchedulerSimulator() {
    if (!kDebugMode) {
      debugPrint("LocalNotificationTriggerService: Local Scheduler Simulator disabled in Release build.");
      return;
    }
    _schedulerTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _runAutomationSettingsCheck();
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

  Future<void> _runAutomationSettingsCheck() async {
    try {
      final settingsSnap = await _firestore
          .collection(AppCollections.settings)
          .doc('automation')
          .get();

      bool isEnabled = true;
      int expiryDurationDays = 7;
      int followUpIntervalDays = 3;
      if (settingsSnap.exists) {
        final d = settingsSnap.data()!;
        isEnabled = d['isEnabled'] ?? true;
        expiryDurationDays = d['expiryDurationDays'] ?? 7;
        followUpIntervalDays = d['followUpIntervalDays'] ?? 3;
      }

      if (!isEnabled) return;

      final now = DateTime.now();
      final quotesSnap = await _firestore.collection(AppCollections.quotations).get();
      if (quotesSnap.docs.isEmpty) return;

      for (var doc in quotesSnap.docs) {
        final quoteModel = QuotationModel.fromJson(doc.data(), doc.id);
        final status = quoteModel.status;
        final publicId = quoteModel.publicId;

        if (status == QuotationStatus.completed ||
            status == QuotationStatus.cancelled ||
            status == QuotationStatus.archived ||
            status == QuotationStatus.expired) {
          continue;
        }

        final validFrom = quoteModel.publishedAt ?? quoteModel.createdAt;
        final expiryDate = validFrom.add(Duration(days: expiryDurationDays));

        final updatedSentReminders = List<String>.from(quoteModel.sentReminders);
        bool shouldUpdateDb = false;
        QuotationStatus? nextStatus;

        // Expiry Check
        if (now.isAfter(expiryDate)) {
          nextStatus = QuotationStatus.expired;
          shouldUpdateDb = true;

          await _firestore.collection(AppCollections.quotationAutomationLogs).add({
            'quotationId': doc.id,
            'automationType': 'Expiry Check',
            'executedAt': now.toIso8601String(),
            'status': 'Success',
            'details': 'Quotation expired automatically after passing valid until window.',
            'duration': 150,
            'executedBy': 'Local Simulator',
          });

          await _queueNotification(
            recipient: 'Client',
            recipientId: quoteModel.customerId,
            title: 'Quotation Expired',
            body: 'Your quotation $publicId has expired.',
            type: 'Expired',
          );
          await _queueNotification(
            recipient: 'Admin',
            recipientId: 'Admin',
            title: 'Quotation Expired',
            body: 'Quotation $publicId has expired automatically.',
            type: 'Expired',
          );
        } else {
          // Expiry Reminders
          if (status == QuotationStatus.published ||
              status == QuotationStatus.republished ||
              status == QuotationStatus.viewed) {
            
            final reminder24hTime = expiryDate.subtract(const Duration(hours: 24));
            if (now.isAfter(reminder24hTime) && !updatedSentReminders.contains('24h_before_expiry')) {
              updatedSentReminders.add('24h_before_expiry');
              shouldUpdateDb = true;

              await _firestore.collection(AppCollections.quotationAutomationLogs).add({
                'quotationId': doc.id,
                'automationType': 'Expiry Reminder 24h',
                'executedAt': now.toIso8601String(),
                'status': 'Success',
                'details': '24-hour pre-expiry reminder triggered for quotation $publicId.',
                'duration': 80,
                'executedBy': 'Local Simulator',
              });

              await _queueNotification(
                recipient: 'Client',
                recipientId: quoteModel.customerId,
                title: 'Quotation Expires Tomorrow',
                body: 'Quotation expires tomorrow.',
                type: 'Reminder Sent',
              );
            }

            final reminder2hTime = expiryDate.subtract(const Duration(hours: 2));
            if (now.isAfter(reminder2hTime) && !updatedSentReminders.contains('2h_before_expiry')) {
              updatedSentReminders.add('2h_before_expiry');
              shouldUpdateDb = true;

              await _firestore.collection(AppCollections.quotationAutomationLogs).add({
                'quotationId': doc.id,
                'automationType': 'Expiry Reminder 2h',
                'executedAt': now.toIso8601String(),
                'status': 'Success',
                'details': '2-hour pre-expiry reminder triggered for quotation $publicId.',
                'duration': 75,
                'executedBy': 'Local Simulator',
              });

              await _queueNotification(
                recipient: 'Client',
                recipientId: quoteModel.customerId,
                title: 'Quotation Expires Soon',
                body: 'Reminder',
                type: 'Reminder Sent',
              );
            }
          }

          // Follow-up
          if (status == QuotationStatus.viewed && quoteModel.customerViewedAt != null) {
            final followUpTime = quoteModel.customerViewedAt!.add(Duration(days: followUpIntervalDays));
            if (now.isAfter(followUpTime) && !updatedSentReminders.contains('viewed_followup')) {
              updatedSentReminders.add('viewed_followup');
              shouldUpdateDb = true;

              await _firestore.collection(AppCollections.quotationAutomationLogs).add({
                'quotationId': doc.id,
                'automationType': 'Inactivity Follow-up',
                'executedAt': now.toIso8601String(),
                'status': 'Success',
                'details': 'Admin follow-up triggered for viewed quotation $publicId after client inactivity.',
                'duration': 90,
                'executedBy': 'Local Simulator',
              });

              await _queueNotification(
                recipient: 'Admin',
                recipientId: 'Admin',
                title: 'Customer has not responded.',
                body: 'Customer has not responded to quotation $publicId.',
                type: 'Follow-up Sent',
              );
            }
          }
        }

        if (shouldUpdateDb) {
          final updates = <String, dynamic>{
            'sentReminders': updatedSentReminders,
            'updatedAt': FieldValue.serverTimestamp(),
          };
          if (nextStatus != null) {
            updates['status'] = nextStatus.name;
          }
          await _firestore.collection(AppCollections.quotations).doc(doc.id).update(updates);
        }
      }
    } catch (_) {}
  }

  Future<void> _queueNotification({
    required String recipient,
    required String recipientId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _firestore.collection(AppCollections.notificationQueue).add({
        'recipient': recipient,
        'recipientId': recipientId,
        'type': type,
        'title': title,
        'body': body,
        'channel': 'email',
        'status': 'pending',
        'retryCount': 0,
        'errorMessage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
