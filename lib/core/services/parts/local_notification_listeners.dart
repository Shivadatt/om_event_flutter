part of '../local_notification_trigger_service.dart';

extension LocalNotificationListenersExtension on LocalNotificationTriggerService {
  /// Receives leads updates from ListenerRegistryService.
  void handleLeadsSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    if (!kDebugMode) return;
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
  }

  /// Receives quotations updates from ListenerRegistryService.
  void handleQuotationsSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    _processQuotationChanges(snap);
  }

  /// Receives queue updates from ListenerRegistryService.
  void handleQueueSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    processQueueSnapshot(snap);
  }

  void _processQuotationChanges(QuerySnapshot<Map<String, dynamic>> snap) {
    for (var change in snap.docChanges) {
      if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
        final data = change.doc.data();
        if (data != null) {
          final status = (data['status'] ?? '').toString();
          final customerId = data['customerId'] ?? '';
          final customerName = data['customer_name'] ?? data['customerName'] ?? 'Customer';
          final publicId = data['public_id'] ?? data['publicId'] ?? change.doc.id;
          final quotationId = change.doc.id;
          final email = data['customer_email'] ?? data['customerEmail'] ?? 'customer@gmail.com';
          final phone = data['customer_phone'] ?? data['customerPhone'] ?? '';

          if (status == 'acceptedByClient' || status == 'bookingConfirmed' || status == 'accepted') {
            // Notify Admin
            _queueAdminNotification(
              eventType: 'Quotation Approved',
              description: 'Booking $publicId has been confirmed by $customerName.',
              params: {
                'public_id': publicId,
                'customer_name': customerName,
              },
            );

            // Notify Customer
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Accepted',
              body: 'Your booking $publicId has been accepted.',
              type: 'booking_accepted',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'quotation_approved',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          } else if (status == 'declinedByClient' || status == 'rejected') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Rejected',
              body: 'Your booking request $publicId was rejected.',
              type: 'booking_rejected',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'quotation_rejected',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          } else if (status == 'cancelled') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Cancelled',
              body: 'Your booking $publicId has been cancelled.',
              type: 'booking_cancelled',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'booking_cancelled',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          } else if (status == 'cancellationRequested') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Cancellation Requested',
              body: 'Your cancellation request for $publicId has been received.',
              type: 'cancellation_requested',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'cancellation_requested',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          } else if (status == 'cancellationApproved') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Cancellation Approved',
              body: 'Your cancellation request for $publicId has been approved.',
              type: 'cancellation_approved',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'cancellation_approved',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          } else if (status == 'cancellationRejected') {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Cancellation Rejected',
              body: 'Your cancellation request for $publicId has been rejected.',
              type: 'cancellation_rejected',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'cancellation_rejected',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          } else if (change.type == DocumentChangeType.added && (status == 'pending' || status == 'draft')) {
            _queueCustomerNotification(
              customerId: customerId,
              title: 'Booking Submitted',
              body: 'Your booking request $publicId has been received.',
              type: 'booking_submitted',
              bookingId: quotationId,
              publicBookingId: publicId,
              email: email,
              phone: phone,
              whatsappTemplate: 'booking_submitted',
              whatsappParams: [publicId],
              variables: {'public_id': publicId},
            );
          }
        }
      }
    }
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
    String? type,
    String? bookingId,
    String? publicBookingId,
  }) {
    _firestore.collection(AppCollections.customerNotifications).add({
      'customerId': customerId,
      'title': title,
      'body': body,
      'type': type ?? 'Alert',
      'bookingId': bookingId ?? '',
      'publicBookingId': publicBookingId ?? '',
      'isRead': false,
      'read': false,
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
