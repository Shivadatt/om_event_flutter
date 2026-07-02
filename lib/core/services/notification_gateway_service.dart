import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_collections.dart';

class NotificationGatewayService extends GetxService {
  static NotificationGatewayService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sandbox credentials (only loaded for config preview; client never performs active dispatch)
  String _resendApiKey = 're_1234567890';
  String _whatsappToken = 'EAABw...';
  String _whatsappPhoneId = '1029384756';
  // ignore: unused_field
  String _whatsappBusinessId = '9876543210';
  String _senderEmail = 'notifications@omevents.com';

  /// Update configurations dynamically from admin settings UI (for saving variables back to backend)
  void updateCredentials({
    required String resendApiKey,
    required String whatsappToken,
    required String whatsappPhoneId,
    required String whatsappBusinessId,
    required String senderEmail,
  }) {
    _resendApiKey = resendApiKey;
    _whatsappToken = whatsappToken;
    _whatsappPhoneId = whatsappPhoneId;
    _whatsappBusinessId = whatsappBusinessId;
    _senderEmail = senderEmail;

    // Save configurations back to dynamic settings doc
    _firestore.collection('system_config').doc('notifications').set({
      'resendApiKey': _resendApiKey,
      'whatsappToken': _whatsappToken,
      'whatsappPhoneId': _whatsappPhoneId,
      'whatsappBusinessId': _whatsappBusinessId,
      'senderEmail': _senderEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Write task to notification outbox queue collection to trigger Cloud Function delivery
  Future<void> queueNotification({
    required String recipient,
    required String recipientId,
    required String type,
    required String title,
    required String body,
    required String channel,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(AppCollections.notificationQueue).add({
        'recipient': recipient,
        'recipientId': recipientId,
        'type': type,
        'title': title,
        'body': body,
        'channel': channel,
        'status': 'pending',
        'retryCount': 0,
        'errorMessage': '',
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Fail silently
    }
  }

  /// Queue email to be processed asynchronously by Firebase Cloud Functions
  Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String htmlContent,
    required String eventType,
  }) async {
    await queueNotification(
      recipient: recipientEmail,
      recipientId: recipientEmail,
      type: eventType,
      title: subject,
      body: htmlContent,
      channel: 'email',
    );
    return true;
  }

  /// Queue WhatsApp alert to be processed asynchronously by Firebase Cloud Functions
  Future<bool> sendWhatsApp({
    required String recipientPhone,
    required String templateName,
    required List<String> parameters,
    required String eventType,
  }) async {
    await queueNotification(
      recipient: recipientPhone,
      recipientId: recipientPhone,
      type: eventType,
      title: 'WhatsApp Template: $templateName',
      body: parameters.join(', '),
      channel: 'whatsapp',
      metadata: {
        'templateName': templateName,
        'parameters': parameters,
      },
    );
    return true;
  }
}
