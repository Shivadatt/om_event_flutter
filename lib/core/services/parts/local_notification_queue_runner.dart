part of '../local_notification_trigger_service.dart';

extension LocalNotificationQueueExtension on LocalNotificationTriggerService {
  /// 2. Local Queue Runner: Processes notification queue changes.
  /// PRODUCTION SAFETY: Only runs in debug builds. In production, the Supabase Edge Function processes the queue.
  void processQueueSnapshot(QuerySnapshot<Map<String, dynamic>> snap) async {
    if (!kDebugMode) {
      AppLogger.info('LocalNotificationTriggerService: Queue runner disabled in Release build — Supabase handles this.', layer: LogLayer.service, className: 'LocalNotificationQueueExtension', methodName: 'processQueueSnapshot');
      return;
    }
    for (var doc in snap.docs) {
      final data = doc.data();
      final taskId = doc.id;
      final recipientId = data['recipientId'] ?? '';
      final priority = data['priority'] ?? 'normal';

      // 1. DND QUIET HOURS CHECKING
      bool inQuietHours = false;
      if (priority != 'high') {
        inQuietHours = await _checkRecipientQuietHours(recipientId);
      }

      if (inQuietHours) {
        // Pause and wait
        await _firestore
            .collection(AppCollections.notificationQueue)
            .doc(taskId)
            .update({
          'status': 'paused_dnd',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        continue; // Defer execution
      }

      // Transition: pending/paused_dnd -> processing
      await _firestore
          .collection(AppCollections.notificationQueue)
          .doc(taskId)
          .update({
        'status': 'processing',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await Future.delayed(const Duration(milliseconds: 600));

      final channel = data['channel'] ?? 'push';
      final recipient = data['recipient'] ?? '';
      String title = data['title'] ?? '';
      String body = data['body'] ?? '';
      final type = data['type'] ?? 'Alert';

      // 2. DYNAMIC TEMPLATE VARIABLES REPLACEMENTS PARSER
      final variables = Map<String, dynamic>.from(data['variables'] ?? {});
      variables.forEach((key, val) {
        title = title.replaceAll('{{$key}}', val.toString());
        body = body.replaceAll('{{$key}}', val.toString());
      });

      // 3. A/B TESTING SPLIT (50/50 split payload tags)
      final String abVariant = _random.nextBool() ? 'Variant A' : 'Variant B';
      if (abVariant == 'Variant B') {
        body = '$body [Save 10% on next rebook!]'; // Variant B template body copy hook
      }

      bool success = true;
      String errMsg = '';
      if (recipient.toString().contains('fail') || recipient.toString().contains('invalid')) {
        success = false;
        errMsg = 'Simulated Delivery Failure: Target Endpoint Handshake timed out.';
      }

      if (success) {
        await _firestore
            .collection(AppCollections.notificationQueue)
            .doc(taskId)
            .update({
          'status': 'sent',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection(AppCollections.notificationLogs).doc(taskId).set({
          'recipientId': recipient,
          'type': type,
          'title': title,
          'body': body,
          'channelsUsed': [channel],
          'status': 'sent',
          'externalId': taskId,
          'variant': abVariant,
          'priority': priority,
          'sentAt': FieldValue.serverTimestamp(),
        });

        if (channel == 'push') {
          FcmNotificationService.to.requestPermissions();
        }
      } else {
        final nextRetry = (data['retryCount'] ?? 0) + 1;
        if (nextRetry >= 5) {
          // Dead letter queue
          await _firestore.collection('dead_letter_notifications').add({
            'queueId': taskId,
            'reason': errMsg,
            'channel': channel,
            'payload': data,
            'retryCount': nextRetry,
            'timestamp': FieldValue.serverTimestamp(),
          });

          await _firestore
              .collection(AppCollections.notificationQueue)
              .doc(taskId)
              .update({
            'status': 'failed_dlq',
            'retryCount': nextRetry,
            'errorMessage': errMsg,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await _firestore
              .collection(AppCollections.notificationQueue)
              .doc(taskId)
              .update({
            'status': 'pending',
            'retryCount': nextRetry,
            'errorMessage': errMsg,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        await _firestore.collection(AppCollections.notificationLogs).add({
          'recipientId': recipient,
          'type': type,
          'title': title,
          'body': 'Failed (Attempt $nextRetry): $errMsg',
          'channelsUsed': [channel],
          'status': 'failed',
          'sentAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<bool> _checkRecipientQuietHours(String userId) async {
    try {
      final doc = await _firestore
          .collection('customer_notification_preferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final dndEnabled = data['dndEnabled'] ?? false;
        if (!dndEnabled) return false;

        final quietStartStr = data['quietHoursStart'] ?? '22:00';
        final quietEndStr = data['quietHoursEnd'] ?? '07:00';

        final startParts = quietStartStr.split(':').map((e) => int.parse(e.toString())).toList();
        final endParts = quietEndStr.split(':').map((e) => int.parse(e.toString())).toList();

        final now = DateTime.now();
        final startTime = DateTime(now.year, now.month, now.day, startParts[0], startParts[1]);
        final endTime = DateTime(now.year, now.month, now.day, endParts[0], endParts[1]);

        if (endTime.isBefore(startTime)) {
          if (now.isAfter(startTime) || now.isBefore(endTime)) return true;
        } else {
          if (now.isAfter(startTime) && now.isBefore(endTime)) return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
