import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_gateway_service.dart';

class LocalNotificationTriggerService extends GetxService {
  static LocalNotificationTriggerService get to => Get.find();

  final SupabaseClient _client = Supabase.instance.client;

  // Track subscriptions to cancel on dispose (Task 10)
  final List<StreamSubscription> _subscriptions = [];

  // In-memory status caches to detect inserts and state changes
  final Map<String, String> _bookingStatusCache = {};
  final Map<String, String> _leadStatusCache = {};
  final Map<String, String> _paymentStatusCache = {};
  final Map<String, String> _quotationStatusCache = {};

  @override
  void onInit() {
    super.onInit();
    _startLocalListeners();
  }

  /// 1. Trigger outbox queue tasks when Supabase records change
  void _startLocalListeners() {
    // A. Bookings Stream
    final subBookings = _client.from('bookings').stream(primaryKey: ['id']).listen((rows) {
      for (var row in rows) {
        final id = row['id'] as String;
        final status = row['status'] ?? 'pending';

        if (!_bookingStatusCache.containsKey(id)) {
          _bookingStatusCache[id] = status;
          
          // Notify Admin
          _queueAdminNotification(
            eventType: 'Booking Created',
            description: 'New booking submitted by ${row['customer_name'] ?? 'Customer'}.',
            params: {'customer_name': row['customer_name'] ?? 'Customer'},
          );

          // Notify Customer
          final customerId = row['customer_id'] ?? '';
          final email = row['customer_email'] ?? 'customer@gmail.com';
          final phone = row['customer_phone'] ?? '';
          _queueCustomerNotification(
            customerId: customerId,
            title: 'Booking Confirmed!',
            body: 'Thank you for your event booking request ${row['booking_number'] ?? ''}. We will verify details and approve shortly.',
            email: email,
            phone: phone,
            whatsappTemplate: 'booking_confirmation',
            whatsappParams: [row['booking_number'] ?? ''],
            variables: {'booking_number': row['booking_number'] ?? ''},
          );

          _scheduleEventDayReminders(id, row);
        } else if (_bookingStatusCache[id] != status) {
          _bookingStatusCache[id] = status;

          final customerId = row['customer_id'] ?? '';
          final email = row['customer_email'] ?? 'customer@gmail.com';
          final phone = row['customer_phone'] ?? '';
          final bookingNumber = row['booking_number'] ?? '';

          if (status == 'confirmed' || status == 'approved') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Approved!',
              body: 'Your event booking request $bookingNumber has been approved.',
              email: email,
              phone: phone,
              whatsappTemplate: 'booking_approved',
              whatsappParams: [bookingNumber],
              variables: {'booking_number': bookingNumber},
            );
          } else if (status == 'cancelled' || status == 'rejected') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Cancelled',
              body: 'Your event booking $bookingNumber has been updated to: CANCELLED.',
              email: email,
              phone: phone,
              whatsappTemplate: 'booking_rejected',
              whatsappParams: [bookingNumber],
              variables: {'booking_number': bookingNumber},
            );
          } else if (status == 'completed') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Completed!',
              body: 'Thank you for choosing Om Events. Your booking $bookingNumber has been completed.',
              email: email,
              phone: phone,
              whatsappTemplate: 'booking_completed',
              whatsappParams: [bookingNumber],
              variables: {'booking_number': bookingNumber},
            );
          }
        }
      }
    });
    _subscriptions.add(subBookings);

    // B. Leads Stream
    final subLeads = _client.from('leads').stream(primaryKey: ['id']).listen((rows) {
      for (var row in rows) {
        final id = row['id'] as String;
        final status = row['status'] ?? 'pending';

        if (!_leadStatusCache.containsKey(id)) {
          _leadStatusCache[id] = status;
          _queueAdminNotification(
            eventType: 'Lead Created',
            description: 'New customer lead generated from ${row['customer_name'] ?? 'Customer'}.',
            params: {'customer_name': row['customer_name'] ?? 'Customer'},
          );
        }
      }
    });
    _subscriptions.add(subLeads);

    // C. Payments Stream
    final subPayments = _client.from('payments').stream(primaryKey: ['id']).listen((rows) {
      for (var row in rows) {
        final id = row['id'] as String;
        final status = row['status'] ?? 'pending';

        if (!_paymentStatusCache.containsKey(id)) {
          _paymentStatusCache[id] = status;
          _queueAdminNotification(
            eventType: 'Payment Uploaded',
            description: 'Payment receipt uploaded: ₹${row['amount'] ?? 0.0}.',
            params: {'amount': (row['amount'] ?? 0.0).toString()},
          );
        } else if (_paymentStatusCache[id] != status) {
          _paymentStatusCache[id] = status;

          final customerId = row['customer_id'] ?? '';
          final amount = (row['amount'] ?? 0.0).toString();
          final phone = row['customer_phone'] ?? '';

          if (status == 'approved' || status == 'verified') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Payment Verification Approved',
              body: 'Receipt verified successfully for ₹$amount.',
              email: 'customer@gmail.com',
              phone: phone,
              whatsappTemplate: 'payment_approved',
              whatsappParams: [amount],
              variables: {'amount': amount},
            );
          }
        }
      }
    });
    _subscriptions.add(subPayments);

    // D. Quotations Stream
    final subQuotations = _client.from('quotations').stream(primaryKey: ['id']).listen((rows) {
      for (var row in rows) {
        final id = row['id'] as String;
        final status = row['status'] ?? 'pending';

        if (!_quotationStatusCache.containsKey(id)) {
          _quotationStatusCache[id] = status;
        } else if (_quotationStatusCache[id] != status) {
          _quotationStatusCache[id] = status;

          final customerId = row['customer_id'] ?? '';
          final customerName = row['customer_name'] ?? 'Customer';
          final publicId = row['public_id'] ?? id;
          final email = row['customer_email'] ?? 'customer@gmail.com';
          final phone = row['customer_phone'] ?? '';

          if (status == 'approved' || status == 'accepted' || status == 'booked') {
            // Notify Admin
            _queueAdminNotification(
              eventType: 'Quotation Approved',
              description: 'Quotation $publicId has been approved/booked by $customerName.',
              params: {
                'public_id': publicId,
                'customer_name': customerName,
              },
            );

            // Notify Customer
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Quotation Approved',
              body: 'Your quotation $publicId has been booked successfully.',
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
              body: 'Your quotation $publicId has been rejected.',
              email: email,
              phone: phone,
              whatsappTemplate: 'quotation_rejected',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          }
        }
      }
    });
    _subscriptions.add(subQuotations);
  }

  @override
  void onClose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  void _scheduleEventDayReminders(String bookingId, Map<String, dynamic> bookingData) {
    final customerId = bookingData['customer_id'] ?? '';
    final email = bookingData['customer_email'] ?? 'customer@gmail.com';
    final dateStr = bookingData['event_date'] ?? '';

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
    _client.from('customer_notifications').insert({
      'customer_id': customerId,
      'title': title,
      'body': body,
      'type': 'Alert',
      'is_read': false,
      'branch': 'Ahmedabad',
      'priority': 'normal',
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
    if (customerId.isNotEmpty) {
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
}
