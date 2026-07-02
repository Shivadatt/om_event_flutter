import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import 'notification_gateway_service.dart';
import 'fcm_notification_service.dart';

class LocalNotificationTriggerService extends GetxService {
  static LocalNotificationTriggerService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _schedulerTimer;
  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    _startLocalListeners();
    _startLocalQueueRunner();
    _startLocalSchedulerSimulator();
  }

  @override
  void onClose() {
    _schedulerTimer?.cancel();
    super.onClose();
  }

  /// 1. Trigger outbox queue tasks when core records change
  void _startLocalListeners() {
    _firestore.collection(AppCollections.bookings).snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _queueAdminNotification(
              eventType: 'Booking Created',
              description: 'New booking submitted by {{customer_name}}.',
              params: {'customer_name': data['customer_name'] ?? 'Customer'},
            );

            _scheduleEventDayReminders(change.doc.id, data);
          }
        } else if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null) {
            final status = data['status'] ?? 'pending';
            final customerId = data['customerId'] ?? '';
            final email = data['customer_email'] ?? data['customerEmail'] ?? 'customer@gmail.com';
            final phone = data['customer_phone'] ?? data['customerPhone'] ?? '';

            if (status == 'confirmed' || status == 'approved') {
              _queueCustomerNotification(
                customerId: customerId,
                title: 'Booking Approved!',
                body: 'Your event booking request {{booking_number}} has been approved.',
                email: email,
                phone: phone,
                whatsappTemplate: 'booking_approved',
                whatsappParams: [data['booking_number'] ?? ''],
                variables: {'booking_number': data['booking_number'] ?? ''},
              );
            } else if (status == 'cancelled' || status == 'rejected') {
              _queueCustomerNotification(
                customerId: customerId,
                title: 'Booking Cancelled',
                body: 'Your event booking {{booking_number}} has been updated to: CANCELLED.',
                email: email,
                phone: phone,
                whatsappTemplate: 'booking_rejected',
                whatsappParams: [data['booking_number'] ?? ''],
                variables: {'booking_number': data['booking_number'] ?? ''},
              );
            }
          }
        }
      }
    });

    _firestore.collection(AppCollections.leads).snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _queueAdminNotification(
              eventType: 'Lead Created',
              description: 'New customer lead generated from {{customer_name}}.',
              params: {'customer_name': data['name'] ?? 'Customer'},
            );
          }
        }
      }
    });

    _firestore.collection(AppCollections.payments).snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _queueAdminNotification(
              eventType: 'Payment Uploaded',
              description: 'Payment receipt uploaded: ₹{{amount}}.',
              params: {'amount': (data['amount'] ?? 0.0).toString()},
            );
          }
        } else if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null) {
            final status = data['status'] ?? 'pending';
            final customerId = data['customerId'] ?? '';
            final amount = (data['amount'] ?? 0.0).toString();
            final phone = data['customer_phone'] ?? '';

            if (status == 'approved' || status == 'verified') {
              _queueCustomerNotification(
                customerId: customerId,
                title: 'Payment Verification Approved',
                body: 'Receipt verified successfully for ₹{{amount}}.',
                email: 'customer@gmail.com',
                phone: phone,
                whatsappTemplate: 'payment_approved',
                whatsappParams: [amount],
                variables: {'amount': amount},
              );
            }
          }
        }
      }
    });

    _firestore.collection(AppCollections.quotations).snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data != null) {
            final status = data['status'] ?? 'pending';
            final customerId = data['customerId'] ?? '';
            final customerName = data['customer_name'] ?? data['customerName'] ?? 'Customer';
            final publicId = data['public_id'] ?? data['publicId'] ?? change.doc.id;
            final email = data['customer_email'] ?? data['customerEmail'] ?? 'customer@gmail.com';
            final phone = data['customer_phone'] ?? data['customerPhone'] ?? '';

            if (status == 'approved' || status == 'accepted' || status == 'booked') {
              // Notify Admin
              _queueAdminNotification(
                eventType: 'Quotation Approved',
                description: 'Quotation {{public_id}} has been approved/booked by {{customer_name}}.',
                params: {
                  'public_id': publicId,
                  'customer_name': customerName,
                },
              );

              // Notify Customer
              _queueCustomerNotification(
                customerId: customerId,
                title: 'Quotation Approved',
                body: 'Your quotation {{public_id}} has been booked successfully.',
                email: email,
                phone: phone,
                whatsappTemplate: 'quotation_approved',
                whatsappParams: [publicId],
                variables: {'public_id': publicId},
              );
            } else if (status == 'rejected') {
              _queueCustomerNotification(
                customerId: customerId,
                title: 'Quotation Rejected',
                body: 'Your quotation {{public_id}} has been rejected.',
                email: email,
                phone: phone,
                whatsappTemplate: 'quotation_rejected',
                whatsappParams: [publicId],
                variables: {'public_id': publicId},
              );
            }
          }
        }
      }
    });
  }

  /// 2. Local Queue Runner: Simulates DND quiet hour pauses, A/B Testing split, and placeholder variables replacements
  void _startLocalQueueRunner() {
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

  void _scheduleEventDayReminders(String bookingId, Map<String, dynamic> bookingData) {
    final customerId = bookingData['customerId'] ?? '';
    final email = bookingData['customer_email'] ?? bookingData['customerEmail'] ?? 'customer@gmail.com';
    final dateStr = bookingData['event_date'] ?? bookingData['eventDate'] ?? '';

    if (dateStr.isEmpty) return;
    try {
      final eventDate = DateTime.parse(dateStr);
      final list = [
        {'days': 30, 'label': '30 Days Event Reminder'},
        {'days': 7, 'label': '7 Days Prep Reminder'},
        {'days': 1, 'label': '1 Day Out Briefing'},
      ];

      for (var item in list) {
        final days = item['days'] as int;
        final triggerAt = eventDate.subtract(Duration(days: days));

        _firestore.collection(AppCollections.scheduledNotifications).add({
          'eventId': bookingId,
          'eventType': 'Booking Event Reminder',
          'recipient': email,
          'recipientId': customerId,
          'triggerAt': Timestamp.fromDate(triggerAt.isAfter(DateTime.now()) ? triggerAt : DateTime.now().add(const Duration(seconds: 40))),
          'title': '${item['label']}: Om Events',
          'body': 'Your event scheduled on $dateStr is coming up in $days days!',
          'channel': 'email',
          'status': 'pending',
          'priority': 'normal',
        });
      }
    } catch (_) {}
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

  void _queueAdminNotification({
    required String eventType,
    required String description,
    Map<String, String>? params,
  }) {
    NotificationGatewayService.to.queueNotification(
      recipient: 'admin@omevents.com',
      recipientId: 'admin_main',
      type: eventType,
      title: 'Om Events Alert: $eventType',
      body: description,
      channel: 'email',
      metadata: {'variables': params ?? {}},
    );

    NotificationGatewayService.to.queueNotification(
      recipient: '9512149944',
      recipientId: 'admin_main',
      type: eventType,
      title: 'WhatsApp Alert',
      body: description,
      channel: 'whatsapp',
      metadata: {
        'templateName': 'admin_alerts',
        'parameters': [eventType, description],
        'variables': params ?? {},
      },
    );
  }

  void _queueCustomerNotification({
    required String customerId,
    required String title,
    required String body,
    required String email,
    required String phone,
    required String whatsappTemplate,
    required List<String> whatsappParams,
    Map<String, String>? variables,
  }) {
    _firestore.collection(AppCollections.customerNotifications).add({
      'customerId': customerId,
      'title': title,
      'body': body,
      'type': 'Alert',
      'isRead': false,
      'branch': 'Ahmedabad',
      'priority': 'normal',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (email.isNotEmpty) {
      NotificationGatewayService.to.queueNotification(
        recipient: email,
        recipientId: customerId,
        type: 'Customer Alert',
        title: title,
        body: body,
        channel: 'email',
        metadata: {'variables': variables ?? {}},
      );
    }

    if (phone.isNotEmpty) {
      NotificationGatewayService.to.queueNotification(
        recipient: phone,
        recipientId: customerId,
        type: 'Customer Alert',
        title: 'WhatsApp Alert',
        body: body,
        channel: 'whatsapp',
        metadata: {
          'templateName': whatsappTemplate,
          'parameters': whatsappParams,
          'variables': variables ?? {},
        },
      );
    }
  }
}
