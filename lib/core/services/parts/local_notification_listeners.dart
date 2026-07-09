part of '../local_notification_trigger_service.dart';

extension LocalNotificationListenersExtension on LocalNotificationTriggerService {
  /// 1. Trigger outbox queue tasks when core records change
  void startLocalListeners() {

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

            if (status == 'acceptedByClient' || status == 'bookingConfirmed') {
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
            } else if (status == 'declinedByClient') {
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
