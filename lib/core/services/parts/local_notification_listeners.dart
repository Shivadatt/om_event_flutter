part of '../local_notification_trigger_service.dart';

extension LocalNotificationListenersExtension on LocalNotificationTriggerService {
  /// 1. Trigger outbox queue tasks when core records change
  void startLocalListeners() {
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
