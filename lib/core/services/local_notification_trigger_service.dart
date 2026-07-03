import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';
import 'notification_gateway_service.dart';

class LocalNotificationTriggerService extends GetxService {
  static LocalNotificationTriggerService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _startLocalListeners();
    // Local queue runner and scheduler loops are disabled.
    // Queue processing and schedules promotion are handled on the backend via Supabase Edge Functions.
  }

  /// 1. Trigger outbox queue tasks when Firestore core records change
  void _startLocalListeners() {
    _firestore.collection(AppCollections.bookings).snapshots().listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            // Notify Admin
            _queueAdminNotification(
              eventType: 'Booking Created',
              description: 'New booking submitted by {{customer_name}}.',
              params: {'customer_name': data['customer_name'] ?? 'Customer'},
            );

            // Notify Customer
            final customerId = data['customerId'] ?? '';
            final email = data['customer_email'] ?? data['customerEmail'] ?? 'customer@gmail.com';
            final phone = data['customer_phone'] ?? data['customerPhone'] ?? '';
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Confirmed!',
              body: 'Thank you for your event booking request {{booking_number}}. We will verify details and approve shortly.',
              email: email,
              phone: phone,
              whatsappTemplate: 'booking_confirmation',
              whatsappParams: [data['booking_number'] ?? ''],
              variables: {'booking_number': data['booking_number'] ?? ''},
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
            } else if (status == 'completed') {
              _queueCustomerNotification(
                customerId: customerId,
                title: 'Booking Completed!',
                body: 'Thank you for choosing Om Events. Your booking {{booking_number}} has been completed.',
                email: email,
                phone: phone,
                whatsappTemplate: 'booking_completed',
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
        final finalTriggerAt = triggerAt.isAfter(DateTime.now())
            ? triggerAt
            : DateTime.now().add(const Duration(seconds: 40));

        NotificationGatewayService.to.queueScheduledNotification(
          eventId: bookingId,
          eventType: 'Booking Event Reminder',
          recipient: email,
          recipientId: customerId,
          triggerAt: finalTriggerAt,
          title: '${item['label']}: Om Events',
          body: 'Your event scheduled on $dateStr is coming up in $days days!',
          channel: 'email',
          priority: 'normal',
        );
      }
    } catch (_) {}
  }

  void _queueAdminNotification({
    required String eventType,
    required String description,
    Map<String, String>? params,
  }) {
    // 1. Email Alert
    NotificationGatewayService.to.queueNotification(
      recipient: 'admin@omevents.com',
      recipientId: 'admin_main',
      type: eventType,
      title: 'Om Events Alert: $eventType',
      body: description,
      channel: 'email',
      variables: params,
    );

    // 2. WhatsApp Alert
    NotificationGatewayService.to.queueNotification(
      recipient: '9512149944',
      recipientId: 'admin_main',
      type: eventType,
      title: 'WhatsApp Alert',
      body: description,
      channel: 'whatsapp',
      variables: {
        'templateName': 'admin_alerts',
        'parameters': [eventType, description],
        'variables': params ?? {},
      },
    );

    // 3. Push Notification Alert
    NotificationGatewayService.to.queueNotification(
      recipient: 'admin_main',
      recipientId: 'admin_main',
      type: eventType,
      title: 'Om Events Alert: $eventType',
      body: description,
      channel: 'push',
      variables: params,
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
    // Preserve local in-app notifications inbox feature
    _firestore.collection('customer_notifications').add({
      'customerId': customerId,
      'title': title,
      'body': body,
      'type': 'Alert',
      'isRead': false,
      'branch': 'Ahmedabad',
      'priority': 'normal',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 1. Email Alert
    if (email.isNotEmpty) {
      NotificationGatewayService.to.queueNotification(
        recipient: email,
        recipientId: customerId,
        type: 'Customer Alert',
        title: title,
        body: body,
        channel: 'email',
        variables: variables,
      );
    }

    // 2. WhatsApp Alert
    if (phone.isNotEmpty) {
      NotificationGatewayService.to.queueNotification(
        recipient: phone,
        recipientId: customerId,
        type: 'Customer Alert',
        title: 'WhatsApp Alert',
        body: body,
        channel: 'whatsapp',
        variables: {
          'templateName': whatsappTemplate,
          'parameters': whatsappParams,
          'variables': variables ?? {},
        },
      );
    }

    // 3. Push Notification Alert
    NotificationGatewayService.to.queueNotification(
      recipient: customerId,
      recipientId: customerId,
      type: 'Customer Alert',
      title: title,
      body: body,
      channel: 'push',
      variables: variables,
    );
  }
}
