part of '../local_notification_trigger_service.dart';

extension LocalNotificationQueueExtension on LocalNotificationTriggerService {
  /// 2. Local Queue Runner: Simulates DND quiet hour pauses, A/B Testing split, and placeholder variables replacements
  void startLocalQueueRunner() {
    _firestore
        .collection(AppCollections.notificationQueue)
        .where('status', whereIn: ['pending', 'paused_dnd'])
        .snapshots()
        .listen((snap) async {
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

          _simulateWebhookCallback(taskId, channel);
        } else {
          final retryCount = (data['retryCount'] ?? 0) + 1;
          if (retryCount >= 5) {
            await _firestore.collection(AppCollections.deadLetterNotifications).add({
              'reason': errMsg,
              'channel': channel,
              'payload': data,
              'retryCount': retryCount,
              'timestamp': FieldValue.serverTimestamp(),
              'stackTrace': 'Local runner execution trace exceptions.',
            });
            await _firestore.collection(AppCollections.notificationQueue).doc(taskId).delete();
          } else {
            await _firestore
                .collection(AppCollections.notificationQueue)
                .doc(taskId)
                .update({
              'status': 'retry',
              'retryCount': retryCount,
              'errorMessage': errMsg,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          await _firestore.collection(AppCollections.notificationLogs).add({
            'recipientId': recipient,
            'type': type,
            'title': title,
            'body': 'Failed (Attempt $retryCount/5): $errMsg',
            'channelsUsed': [channel],
            'status': 'failed',
            'sentAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  /// Check quiet hours DND preferences for customer
  Future<bool> _checkRecipientQuietHours(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final doc = await _firestore
          .collection(AppCollections.customerNotificationPreferences)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final dndEnabled = data['dndEnabled'] ?? false;
        if (!dndEnabled) return false;

        final quietStartStr = data['quietHoursStart'] ?? '22:00';
        final quietEndStr = data['quietHoursEnd'] ?? '07:00';

        final now = DateTime.now();
        final startParts = quietStartStr.split(':').map((e) => int.parse(e)).toList();
        final endParts = quietEndStr.split(':').map((e) => int.parse(e)).toList();

        final startTime = DateTime(now.year, now.month, now.day, startParts[0], startParts[1]);
        var endTime = DateTime(now.year, now.month, now.day, endParts[0], endParts[1]);

        if (endTime.isBefore(startTime)) {
          // Spans midnight
          if (now.isAfter(startTime) || now.isBefore(endTime)) return true;
        } else {
          if (now.isAfter(startTime) && now.isBefore(endTime)) return true;
        }
      }
    } catch (_) {}
    return false;
  }

  void _simulateWebhookCallback(String logId, String channel) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _updateDeliveryStatus(logId, 'delivered', channel);

    await Future.delayed(const Duration(milliseconds: 1500));
    final String nextStatus = channel == 'whatsapp' ? 'read' : 'opened';
    _updateDeliveryStatus(logId, nextStatus, channel);

    if (channel == 'email') {
      await Future.delayed(const Duration(milliseconds: 1200));
      _updateDeliveryStatus(logId, 'clicked', channel);
    }
  }

  Future<void> _updateDeliveryStatus(String logId, String status, String channel) async {
    try {
      await _firestore.collection(AppCollections.notificationDeliveryEvents).add({
        'logId': logId,
        'event': status,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'details': {'source': 'Local simulator callback', 'channel': channel},
      });

      await _firestore.collection(AppCollections.notificationLogs).doc(logId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
