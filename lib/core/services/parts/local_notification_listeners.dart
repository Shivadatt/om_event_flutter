part of '../local_notification_trigger_service.dart';

extension LocalNotificationListenersExtension on LocalNotificationTriggerService {
  /// Receives leads updates from ListenerRegistryService.
  void handleLeadsSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    if (!kDebugMode) return;
    if (!hasInitialLeadsSnapshotLoaded) {
      for (final doc in snap.docs) {
        knownLeadIds.add(doc.id);
      }
      hasInitialLeadsSnapshotLoaded = true;
      return;
    }
    for (final doc in snap.docs) {
      if (!knownLeadIds.contains(doc.id)) {
        knownLeadIds.add(doc.id);
        final data = doc.data();
        _queueAdminNotification(
          eventType: 'Lead Created',
          description: 'New customer lead generated from {{customer_name}}.',
          params: {'customer_name': data['name'] ?? 'Customer'},
        );
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
    // 1. Initial snapshot guard: populate in-memory status map without triggering any notifications
    if (!hasInitialQuotationSnapshotLoaded) {
      for (final doc in snap.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString();
        lastKnownQuotationStatuses[doc.id] = status;
      }
      hasInitialQuotationSnapshotLoaded = true;
      AppLogger.info(
        "LocalNotificationTriggerService: Initialized ${snap.docs.length} quotation statuses without triggering startup notifications.",
        layer: LogLayer.service,
        className: "LocalNotificationListenersExtension",
        methodName: "_processQuotationChanges",
      );
      return;
    }

    // 2. Subsequent delta snapshots: process real-time status transitions or new submissions
    for (final doc in snap.docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString();
      final previousStatus = lastKnownQuotationStatuses[doc.id];
      final isNew = previousStatus == null;
      final isChanged = previousStatus != status;

      lastKnownQuotationStatuses[doc.id] = status;

      // Only evaluate events if the status actually changed or this is a brand new submission
      if (!isNew && !isChanged) continue;

      final customerId = data['customerId'] ?? '';
      final customerName = data['customer_name'] ?? data['customerName'] ?? 'Customer';
      final publicId = data['public_id'] ?? data['publicId'] ?? doc.id;
      final quotationId = doc.id;
      final email = data['customer_email'] ?? data['customerEmail'] ?? 'customer@gmail.com';
      final phone = data['customer_phone'] ?? data['customerPhone'] ?? '';

      if (status == 'acceptedByClient' || status == 'bookingConfirmed' || status == 'accepted') {
        if (isChanged) {
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
        }
      } else if (status == 'declinedByClient' || status == 'rejected') {
        if (isChanged) {
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
        }
      } else if (status == 'cancelled') {
        if (isChanged) {
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
        }
      } else if (status == 'cancellationRequested') {
        if (isChanged) {
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
        }
      } else if (status == 'cancellationApproved') {
        if (isChanged) {
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
        }
      } else if (status == 'cancellationRejected') {
        if (isChanged) {
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
        }
      } else if (isNew && (status == 'pending' || status == 'draft')) {
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

  void _queueAdminNotification({
    required String eventType,
    required String description,
    Map<String, String>? params,
  }) {
    // Early return: Notifications temporarily disabled
    return;
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
    // Early return: Notifications temporarily disabled
    return;
  }
}
