import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationGatewayService extends GetxService {
  static NotificationGatewayService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _supabaseUrl = 'https://kwegyvbgdaednljyhcgm.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_bN91Or0DGzltjdDFB3b4zw_oosYJUa8';

  // Credentials configured in Admin CMS
  String _resendApiKey = 're_1234567890';
  String _whatsappToken = 'EAABw...';
  String _whatsappPhoneId = '1029384756';
  // ignore: unused_field
  String _whatsappBusinessId = '9876543210';
  String _senderEmail = 'notifications@omevents.com';

  @override
  void onInit() {
    super.onInit();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      final doc = await _firestore.collection('system_config').doc('notifications').get();
      if (doc.exists) {
        final data = doc.data()!;
        _resendApiKey = data['resendApiKey'] ?? 're_1234567890';
        _whatsappToken = data['whatsappToken'] ?? 'EAABw...';
        _whatsappPhoneId = data['whatsappPhoneId'] ?? '1029384756';
        _whatsappBusinessId = data['whatsappBusinessId'] ?? '9876543210';
        _senderEmail = data['senderEmail'] ?? 'notifications@omevents.com';
      }
    } catch (_) {}
  }

  /// Update configurations dynamically from admin settings UI
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

    _firestore.collection('system_config').doc('notifications').set({
      'resendApiKey': _resendApiKey,
      'whatsappToken': _whatsappToken,
      'whatsappPhoneId': _whatsappPhoneId,
      'whatsappBusinessId': _whatsappBusinessId,
      'senderEmail': _senderEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── Supabase Outbox Queue Integration ──────────────────────────────────────

  /// Write task to Supabase notification_queue table to trigger Edge Function delivery
  Future<bool> queueNotification({
    required String recipient,
    required String recipientId,
    required String type,
    required String title,
    required String body,
    required String channel,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? metadata,
    String priority = 'normal',
    String? scheduledAt,
  }) async {
    final payload = {
      'recipient': recipient,
      'recipient_id': recipientId,
      'notification_type': type,
      'title': title,
      'body': body,
      'channel': channel,
      'priority': priority,
      'status': 'pending',
      'retry_count': 0,
      'error_message': '',
      'variables': variables ?? {},
      'payload': metadata ?? {},
      'scheduled_at': scheduledAt,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final url = '$_supabaseUrl/rest/v1/notification_queue';
      final headers = {
        'Content-Type': 'application/json',
        'apikey': _supabaseAnonKey,
        'Authorization': 'Bearer $_supabaseAnonKey',
      };

      print("INFO: Queueing notification to Supabase...");
      print("DEBUG HTTP Request URL: $url");
      print("DEBUG HTTP Request Headers: ${jsonEncode(headers)}");
      print("DEBUG HTTP Request Payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      print("DEBUG HTTP Response Status: ${response.statusCode}");
      print("DEBUG HTTP Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        print("SUCCESS: NotificationGatewayService: successfully queued notification to $recipient");
        return true;
      } else {
        print("WARNING: NotificationGatewayService: queue failed with status ${response.statusCode} body=${response.body}");
        return false;
      }
    } catch (e, stackTrace) {
      print("ERROR: NotificationGatewayService: failed to queue notification: $e");
      print("DEBUG HTTP Error Stack: $stackTrace");
      return false;
    }
  }

  /// Create future scheduled notification schedule registry in Supabase
  Future<bool> queueScheduledNotification({
    required String eventId,
    required String eventType,
    required String recipient,
    required String recipientId,
    required String title,
    required String body,
    required String channel,
    required DateTime triggerAt,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? metadata,
    String priority = 'normal',
  }) async {
    final payload = {
      'event_id': eventId,
      'event_type': eventType,
      'recipient': recipient,
      'recipient_id': recipientId,
      'title': title,
      'body': body,
      'channel': channel,
      'priority': priority,
      'trigger_at': triggerAt.toIso8601String(),
      'status': 'pending',
      'variables': variables ?? {},
      'metadata': metadata ?? {},
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final url = '$_supabaseUrl/rest/v1/scheduled_notifications';
      final headers = {
        'Content-Type': 'application/json',
        'apikey': _supabaseAnonKey,
        'Authorization': 'Bearer $_supabaseAnonKey',
      };

      print("INFO: Queueing scheduled notification to Supabase...");
      print("DEBUG HTTP Request URL: $url");
      print("DEBUG HTTP Request Headers: ${jsonEncode(headers)}");
      print("DEBUG HTTP Request Payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      print("DEBUG HTTP Response Status: ${response.statusCode}");
      print("DEBUG HTTP Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        print("SUCCESS: NotificationGatewayService: successfully queued scheduled notification");
        return true;
      } else {
        print("WARNING: NotificationGatewayService: queue scheduled failed with status ${response.statusCode} body=${response.body}");
        return false;
      }
    } catch (e, stackTrace) {
      print("ERROR: NotificationGatewayService: failed to queue scheduled notification: $e");
      print("DEBUG HTTP Error Stack: $stackTrace");
      return false;
    }
  }

  /// Send email wrapper
  Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String htmlContent,
    required String eventType,
  }) async {
    return queueNotification(
      recipient: recipientEmail,
      recipientId: recipientEmail,
      type: eventType,
      title: subject,
      body: htmlContent,
      channel: 'email',
    );
  }

  /// Send WhatsApp wrapper
  Future<bool> sendWhatsApp({
    required String recipientPhone,
    required String templateName,
    required List<String> parameters,
    required String eventType,
  }) async {
    return queueNotification(
      recipient: recipientPhone,
      recipientId: recipientPhone,
      type: eventType,
      title: 'WhatsApp Template: $templateName',
      body: parameters.join(', '),
      channel: 'whatsapp',
      variables: {
        'templateName': templateName,
        'parameters': parameters,
      },
    );
  }

  // ─── Supabase Data Queries for Admin Dashboard CMS ─────────────────────────

  Future<List<Map<String, dynamic>>> getQueueTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/notification_queue?order=updated_at.desc&limit=20'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/scheduled_notifications?order=trigger_at.asc&limit=20'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getNotificationLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/notification_logs?order=sent_at.desc&limit=50'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, dynamic>>> getDeadLetterNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/dead_letter_notifications?order=timestamp.desc&limit=30'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return [];
  }

  // ─── Dashboard Analytics Metrics ───────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/rpc/get_notification_analytics'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return {
      'pending': 0,
      'processing': 0,
      'sent': 0,
      'failed': 0,
      'retry': 0,
      'dead': 0,
      'success_rate': 100.0,
      'avg_delivery_time_ms': 0.0,
    };
  }

  // ─── Operations & Actions ──────────────────────────────────────────────────

  Future<bool> retrySingleTask(String taskId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_supabaseUrl/rest/v1/notification_queue?id=eq.$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode({
          'status': 'pending',
          'retry_count': 0,
          'error_message': '',
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {}
    return false;
  }

  Future<bool> retryAllFailedTasks() async {
    try {
      final response = await http.patch(
        Uri.parse('$_supabaseUrl/rest/v1/notification_queue?status=in.(failed,retry)'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode({
          'status': 'pending',
          'retry_count': 0,
          'error_message': '',
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {}
    return false;
  }

  Future<bool> retryDlqTask(String dlqId, Map<String, dynamic> payload) async {
    try {
      // 1. Re-queue in Supabase notification_queue
      final success = await queueNotification(
        recipient: payload['recipient'] ?? '',
        recipientId: payload['recipient_id'] ?? '',
        type: payload['notification_type'] ?? 'DLQ Retry',
        title: payload['title'] ?? '',
        body: payload['body'] ?? '',
        channel: payload['channel'] ?? 'push',
        variables: payload['variables'],
        metadata: payload['payload'],
        priority: payload['priority'] ?? 'normal',
      );
      if (success) {
        // 2. Delete from DLQ
        await deleteDlqTask(dlqId);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteDlqTask(String dlqId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_supabaseUrl/rest/v1/dead_letter_notifications?id=eq.$dlqId'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {}
    return false;
  }

  Future<bool> queueBroadcast({
    required String title,
    required String body,
    required String segment,
    required String priority,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('customer_profiles');
      if (segment == 'Ahmedabad' || segment == 'Baroda') {
        query = query.where('branch', isEqualTo: segment);
      }

      final usersSnap = await query.get();
      if (usersSnap.docs.isEmpty) return false;

      for (var doc in usersSnap.docs) {
        final data = doc.data();
        final email = data['email'] ?? '';
        final phone = data['phone'] ?? '';
        final customerId = doc.id;

        // Add to customer notifications inbox in Firestore (to preserve in-app notifications inbox feature)
        _firestore.collection('customer_notifications').add({
          'customerId': customerId,
          'title': title,
          'body': body,
          'type': 'Announcement',
          'isRead': false,
          'branch': segment,
          'priority': priority,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Queue in Supabase for FCM push notification delivery
        if (phone.isNotEmpty) {
          await queueNotification(
            recipient: phone,
            recipientId: customerId,
            type: 'Broadcast Announcement',
            title: title,
            body: body,
            channel: 'push',
            priority: priority,
          );
        } else if (email.isNotEmpty) {
          await queueNotification(
            recipient: email,
            recipientId: customerId,
            type: 'Broadcast Announcement',
            title: title,
            body: body,
            channel: 'email',
            priority: priority,
          );
        }
      }
      return true;
    } catch (_) {}
    return false;
  }
}
