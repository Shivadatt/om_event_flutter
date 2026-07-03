import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/notification_gateway_service.dart';
import '../../../../core/config/app_theme.dart';

class SettingsNotificationsTab extends StatefulWidget {
  const SettingsNotificationsTab({super.key});

  @override
  State<SettingsNotificationsTab> createState() => _SettingsNotificationsTabState();
}

class _SettingsNotificationsTabState extends State<SettingsNotificationsTab> {
  Timer? _pollingTimer;

  // Local State fetched from Supabase
  List<Map<String, dynamic>> _queueTasks = [];
  List<Map<String, dynamic>> _scheduledNotifications = [];
  List<Map<String, dynamic>> _notificationLogs = [];
  List<Map<String, dynamic>> _dlqTasks = [];
  Map<String, dynamic> _analytics = {
    'pending': 0,
    'processing': 0,
    'sent': 0,
    'failed': 0,
    'retry': 0,
    'dead': 0,
    'success_rate': 100.0,
    'avg_delivery_time_ms': 0.0,
  };

  bool _loading = true;

  // Configurations
  final resendKeyCtrl = TextEditingController(text: 're_1234567890');
  final whatsappTokenCtrl = TextEditingController(text: 'EAABw...');
  final whatsappPhoneIdCtrl = TextEditingController(text: '1029384756');
  final whatsappBusinessIdCtrl = TextEditingController(text: '9876543210');
  final senderEmailCtrl = TextEditingController(text: 'notifications@omevents.com');

  // Manual Test Inputs
  final testUserIdCtrl = TextEditingController();
  final testPushTitleCtrl = TextEditingController();
  final testPushBodyCtrl = TextEditingController();
  final testEmailRecipientCtrl = TextEditingController();
  final testEmailSubjectCtrl = TextEditingController();
  final testEmailContentCtrl = TextEditingController();
  final testWaPhoneCtrl = TextEditingController();
  final testWaTemplateCtrl = TextEditingController();
  final testWaParamsCtrl = TextEditingController();

  // Search & Filters
  String logSearchQuery = '';
  String dlqSearchQuery = '';

  // Broadcast & Segmentation
  final broadcastTitleCtrl = TextEditingController();
  final broadcastBodyCtrl = TextEditingController();
  String selectedSegment = 'ALL';
  String selectedPriority = 'normal'; // 'normal' | 'high'

  // Versioning
  String activeTemplateVersion = 'v1.0.0';
  String draftTemplateVersion = 'v1.1.0-draft';

  bool isPushEnabled = true;
  bool isEmailEnabled = true;
  bool isWhatsappEnabled = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    resendKeyCtrl.dispose();
    whatsappTokenCtrl.dispose();
    whatsappPhoneIdCtrl.dispose();
    whatsappBusinessIdCtrl.dispose();
    senderEmailCtrl.dispose();
    testUserIdCtrl.dispose();
    testPushTitleCtrl.dispose();
    testPushBodyCtrl.dispose();
    testEmailRecipientCtrl.dispose();
    testEmailSubjectCtrl.dispose();
    testEmailContentCtrl.dispose();
    testWaPhoneCtrl.dispose();
    testWaTemplateCtrl.dispose();
    testWaParamsCtrl.dispose();
    broadcastTitleCtrl.dispose();
    broadcastBodyCtrl.dispose();
    super.dispose();
  }

  void _startPolling() {
    _fetchData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final queue = await NotificationGatewayService.to.getQueueTasks();
      final scheduled = await NotificationGatewayService.to.getScheduledNotifications();
      final logs = await NotificationGatewayService.to.getNotificationLogs();
      final dlq = await NotificationGatewayService.to.getDeadLetterNotifications();
      final analytics = await NotificationGatewayService.to.getDashboardAnalytics();

      if (mounted) {
        setState(() {
          _queueTasks = queue;
          _scheduledNotifications = scheduled;
          _notificationLogs = logs;
          _dlqTasks = dlq;
          _analytics = analytics;
          _loading = false;
        });
      }
    } catch (_) {}
  }

  void _saveGatewaySettings() {
    NotificationGatewayService.to.updateCredentials(
      resendApiKey: resendKeyCtrl.text,
      whatsappToken: whatsappTokenCtrl.text,
      whatsappPhoneId: whatsappPhoneIdCtrl.text,
      whatsappBusinessId: whatsappBusinessIdCtrl.text,
      senderEmail: senderEmailCtrl.text,
    );
    Get.snackbar("Success", "Notification settings saved successfully.");
  }

  Future<void> _retryFailedTasks() async {
    try {
      final success = await NotificationGatewayService.to.retryAllFailedTasks();
      if (success) {
        Get.snackbar("Success", "Reset failed tasks back to pending.");
        _fetchData();
      } else {
        Get.snackbar("Outbox Empty", "No failed tasks found in the queue.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to reset tasks: $e");
    }
  }

  Future<void> _retrySingleTask(String taskId) async {
    try {
      final success = await NotificationGatewayService.to.retrySingleTask(taskId);
      if (success) {
        Get.snackbar("Success", "Task queued for retry.");
        _fetchData();
      } else {
        Get.snackbar("Error", "Failed to retry task.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to retry task: $e");
    }
  }

  Future<void> _retryDlqTask(String dlqId, Map<String, dynamic> payload) async {
    try {
      final success = await NotificationGatewayService.to.retryDlqTask(dlqId, payload);
      if (success) {
        Get.snackbar("Success", "Dead Letter task re-queued successfully.");
        _fetchData();
      } else {
        Get.snackbar("Error", "Failed to retry DLQ task.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to retry DLQ: $e");
    }
  }

  Future<void> _deleteDlqTask(String dlqId) async {
    try {
      final success = await NotificationGatewayService.to.deleteDlqTask(dlqId);
      if (success) {
        Get.snackbar("Success", "DLQ log deleted permanently.");
        _fetchData();
      } else {
        Get.snackbar("Error", "Failed to delete DLQ log.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete: $e");
    }
  }

  void _exportDlqTask(Map<String, dynamic> task) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("Export DLQ JSON Payload", style: AppTheme.serifHeader(fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Raw payload data available for debugging:", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black26,
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(task),
                  style: const TextStyle(fontFamily: 'monospace', color: Colors.amber, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Close", style: TextStyle(color: Color(0xFFC9A77E))),
          ),
        ],
      ),
    );
  }

  Future<void> _exportDeliveryLogs() async {
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF12271F),
          title: Text("Export Logs JSON Format", style: AppTheme.serifHeader(fontSize: 18)),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black26,
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(_notificationLogs),
                style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 11),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Close", style: TextStyle(color: Color(0xFFC9A77E))),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar("Error", "Export failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notification Settings CMS", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 8),
          Text("Configure FCM, Resend API key, Meta WhatsApp Cloud API credentials, and monitor delivery outbox queues.", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 24),

          // 1. Live Analytics Dashboard
          _buildAnalyticsDashboard(),
          const SizedBox(height: 24),

          // 2. Scheduled Reminders Queue Panel
          _buildCard(
            title: "SCHEDULED CRON REMINDERS QUEUE",
            children: [
              const Text("Reminders automatically processed by Cloud Scheduler cron triggers.", style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _scheduledNotifications.isEmpty
                        ? const Center(child: Text("No scheduled reminders pending.", style: TextStyle(color: Colors.white38, fontSize: 12)))
                        : ListView.builder(
                            itemCount: _scheduledNotifications.length,
                            itemBuilder: (context, index) {
                              final rem = _scheduledNotifications[index];
                              final isSent = rem['status'] == 'sent' || rem['status'] == 'queued';
                              final channel = (rem['channel'] ?? 'email').toString().toUpperCase();

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("${rem['title'] ?? 'Reminder'} [$channel]", style: const TextStyle(color: Colors.white, fontSize: 13)),
                                subtitle: Text(
                                  "Trigger Date: ${rem['trigger_at'] != null ? rem['trigger_at'].toString().split('.')[0].replaceFirst('T', ' ') : 'Pending'}",
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSent ? Colors.green.withAlpha(26) : Colors.orange.withAlpha(26),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: isSent ? Colors.green.withAlpha(102) : Colors.orange.withAlpha(102)),
                                  ),
                                  child: Text(
                                    isSent ? "QUEUED" : "PENDING",
                                    style: TextStyle(color: isSent ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Integration Credentials Card
          _buildCard(
            title: "API GATEWAYS CREDENTIALS",
            children: [
              _buildTextField("Resend Email API Key", resendKeyCtrl, isObscure: true),
              const SizedBox(height: 12),
              _buildTextField("Verified Sender Email Address", senderEmailCtrl),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              _buildTextField("Meta WhatsApp Temporary Token", whatsappTokenCtrl, isObscure: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField("WhatsApp Phone Number ID", whatsappPhoneIdCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("WhatsApp Business Account ID", whatsappBusinessIdCtrl)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                icon: const Icon(Icons.save),
                label: const Text("Save Gateway Configuration"),
                onPressed: _saveGatewaySettings,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Outbox Queue Dashboard
          _buildCard(
            title: "OUTBOX DELIVERY QUEUE",
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Asynchronous Queue Tasks", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry All Failed"),
                    onPressed: _retryFailedTasks,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _queueTasks.isEmpty
                        ? const Center(child: Text("No tasks in outbox queue.", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _queueTasks.length,
                            itemBuilder: (context, index) {
                              final task = _queueTasks[index];
                              final taskId = task['id'];
                              final status = task['status'] ?? 'pending';
                              final channel = (task['channel'] ?? 'push').toString().toUpperCase();
                              final recipient = task['recipient'] ?? '';

                              Color statusColor = Colors.grey;
                              if (status == 'sent') statusColor = Colors.green;
                              if (status == 'processing') statusColor = Colors.blue;
                              if (status == 'failed' || status == 'retry') statusColor = Colors.red;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("${task['title'] ?? 'Task'} [$channel]", style: const TextStyle(color: Colors.white, fontSize: 13)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Recipient: $recipient | Retries: ${task['retry_count'] ?? 0}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    if (task['error_message'] != null && task['error_message'].toString().isNotEmpty)
                                      Text("Error: ${task['error_message']}", style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(26),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: statusColor.withAlpha(102)),
                                      ),
                                      child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                    if (status == 'failed' || status == 'retry') ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.replay, color: Colors.orange, size: 18),
                                        onPressed: () => _retrySingleTask(taskId),
                                      ),
                                    ]
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Dead Letter Queue (DLQ) Card
          _buildCard(
            title: "DEAD LETTER QUEUE (DLQ)",
            children: [
              TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(0xFFC9A77E), size: 16),
                  hintText: "Search dead letter logs...",
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.black12,
                  filled: true,
                ),
                onChanged: (val) {
                  setState(() => dlqSearchQuery = val.toLowerCase());
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _dlqTasks.where((d) {
                        final reason = (d['reason'] ?? '').toString().toLowerCase();
                        return reason.contains(dlqSearchQuery);
                      }).isEmpty
                        ? const Center(child: Text("Dead letter queue is empty.", style: TextStyle(color: Colors.green, fontSize: 12)))
                        : ListView.builder(
                            itemCount: _dlqTasks.length,
                            itemBuilder: (context, index) {
                              final dlq = _dlqTasks[index];
                              final dlqId = dlq['id'];
                              final payload = Map<String, dynamic>.from(dlq['payload'] ?? {});

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("Reason: ${dlq['reason'] ?? 'Execution Error'} [${dlq['channel'] ?? 'PUSH'}]", style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                                subtitle: Text("Retries: ${dlq['retry_count'] ?? 5} | Timestamp: ${dlq['timestamp'] != null ? dlq['timestamp'].toString().split('.')[0].replaceFirst('T', ' ') : 'Now'}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow, color: Colors.green, size: 20),
                                      tooltip: "Retry & Delete from DLQ",
                                      onPressed: () => _retryDlqTask(dlqId, payload),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                      tooltip: "Inspect Raw Payload",
                                      onPressed: () => _exportDlqTask(dlq),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      tooltip: "Delete Permanently",
                                      onPressed: () => _deleteDlqTask(dlqId),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 8. Channel Test Panels
          _buildCard(
            title: "CHANNEL TEST PANELS",
            children: [
              ExpansionTile(
                title: const Text("FCM Push Test Panel", style: TextStyle(color: Color(0xFFC9A77E), fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _buildTextField("Recipient User ID (Leave blank for self)", testUserIdCtrl),
                        const SizedBox(height: 8),
                        _buildTextField("Push Title", testPushTitleCtrl),
                        const SizedBox(height: 8),
                        _buildTextField("Push Body Message", testPushBodyCtrl),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (isPushEnabled) {
                              final success = await NotificationGatewayService.to.queueNotification(
                                recipient: testUserIdCtrl.text.isNotEmpty ? testUserIdCtrl.text : 'self-token-sandbox',
                                recipientId: testUserIdCtrl.text.isNotEmpty ? testUserIdCtrl.text : 'self-uid',
                                type: 'Manual Test Push',
                                title: testPushTitleCtrl.text.isNotEmpty ? testPushTitleCtrl.text : "FCM Test Push",
                                body: testPushBodyCtrl.text,
                                channel: 'push',
                              );
                              if (success) {
                                Get.snackbar("Queued", "Test push queued successfully.");
                                _fetchData();
                              }
                            } else {
                              Get.snackbar("FCM Disabled", "Enable push notifications channel first.");
                            }
                          },
                          child: const Text("Test FCM Push"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("Resend Email Test Panel", style: TextStyle(color: Color(0xFFC9A77E), fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _buildTextField("Test Recipient Email", testEmailRecipientCtrl),
                        const SizedBox(height: 8),
                        _buildTextField("Email Subject", testEmailSubjectCtrl),
                        const SizedBox(height: 8),
                        _buildTextField("Email HTML Content", testEmailContentCtrl),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (!isEmailEnabled) {
                              Get.snackbar("Email Disabled", "Enable email channel first.");
                              return;
                            }
                            await NotificationGatewayService.to.sendEmail(
                              recipientEmail: testEmailRecipientCtrl.text,
                              subject: testEmailSubjectCtrl.text,
                              htmlContent: testEmailContentCtrl.text,
                              eventType: 'Manual Test Email',
                            );
                            Get.snackbar("Queued", "Test email queued successfully in outbox.");
                            _fetchData();
                          },
                          child: const Text("Test Resend Email"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("Meta WhatsApp Test Panel", style: TextStyle(color: Color(0xFFC9A77E), fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _buildTextField("Test Recipient Mobile (+91...)", testWaPhoneCtrl),
                        const SizedBox(height: 8),
                        _buildTextField("Meta Template Name", testWaTemplateCtrl),
                        const SizedBox(height: 8),
                        _buildTextField("Body Params (Comma separated)", testWaParamsCtrl),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (!isWhatsappEnabled) {
                              Get.snackbar("WhatsApp Disabled", "Enable WhatsApp channel first.");
                              return;
                            }
                            final params = testWaParamsCtrl.text.split(',').map((e) => e.trim()).toList();
                            await NotificationGatewayService.to.sendWhatsApp(
                              recipientPhone: testWaPhoneCtrl.text,
                              templateName: testWaTemplateCtrl.text,
                              parameters: params,
                              eventType: 'Manual Test WhatsApp',
                            );
                            Get.snackbar("Queued", "Test WhatsApp message queued successfully.");
                            _fetchData();
                          },
                          child: const Text("Test Meta WhatsApp"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 9. Segmented Broadcast Campaigns with Priority Selectors
          _buildCard(
            title: "SEGMENTED BROADCAST CAMPAIGNS",
            children: [
              Row(
                children: [
                  const Text("Audience Segment: ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF12271F),
                    value: selectedSegment,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text("All Customers")),
                      DropdownMenuItem(value: 'Ahmedabad', child: Text("Ahmedabad Branch Only")),
                      DropdownMenuItem(value: 'Baroda', child: Text("Baroda Branch Only")),
                      DropdownMenuItem(value: 'Confirmed Bookings', child: Text("Confirmed Bookings Only")),
                      DropdownMenuItem(value: 'Leads Only', child: Text("Inactive Leads Only")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedSegment = val);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text("Priority: ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF12271F),
                    value: selectedPriority,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text("Normal")),
                      DropdownMenuItem(value: 'high', child: Text("High (Bypass DND)")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPriority = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Broadcast Title", broadcastTitleCtrl),
              const SizedBox(height: 12),
              _buildTextField("Broadcast Message Body", broadcastBodyCtrl),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                icon: const Icon(Icons.campaign),
                label: const Text("Broadcast to Target Audience"),
                onPressed: () async {
                  if (broadcastTitleCtrl.text.isEmpty || broadcastBodyCtrl.text.isEmpty) {
                    Get.snackbar("Error", "Please enter broadcast details.");
                    return;
                  }

                  final success = await NotificationGatewayService.to.queueBroadcast(
                    title: broadcastTitleCtrl.text,
                    body: broadcastBodyCtrl.text,
                    segment: selectedSegment,
                    priority: selectedPriority,
                  );

                  if (success) {
                    broadcastTitleCtrl.clear();
                    broadcastBodyCtrl.clear();
                    Get.snackbar("Success", "Segment campaign queued successfully.");
                    _fetchData();
                  } else {
                    Get.snackbar("Error", "No users matched the selected segment filter.");
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 10. Notification Dispatch Logs
          _buildCard(
            title: "NOTIFICATION SYSTEM AUDIT LOGS",
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Color(0xFFC9A77E), size: 16),
                        hintText: "Search audit logs...",
                        hintStyle: TextStyle(color: Colors.white30),
                        fillColor: Colors.black12,
                        filled: true,
                      ),
                      onChanged: (val) {
                        setState(() => logSearchQuery = val.toLowerCase());
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: Colors.black),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text("Export Logs"),
                    onPressed: _exportDeliveryLogs,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _notificationLogs.where((d) {
                        final title = (d['title'] ?? '').toString().toLowerCase();
                        final body = (d['body'] ?? '').toString().toLowerCase();
                        final recipient = (d['recipient_id'] ?? '').toString().toLowerCase();
                        return title.contains(logSearchQuery) || body.contains(logSearchQuery) || recipient.contains(logSearchQuery);
                      }).isEmpty
                        ? const Center(child: Text("No notification logs registered.", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _notificationLogs.length > 20 ? 20 : _notificationLogs.length,
                            itemBuilder: (context, index) {
                              final log = _notificationLogs[index];
                              final status = log['status'] ?? 'sent';
                              final channels = log['channel'] != null ? log['channel'].toString().toUpperCase() : 'PUSH';
                              final variant = log['ab_variant'] ?? 'Variant A';

                              Color statusColor = Colors.grey;
                              if (status == 'sent') statusColor = Colors.green;
                              if (status == 'delivered') statusColor = Colors.teal;
                              if (status == 'opened' || status == 'read') statusColor = Colors.blue;
                              if (status == 'clicked') statusColor = Colors.purple;
                              if (status == 'failed') statusColor = Colors.red;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("${log['title'] ?? 'Notification Log'} [$variant]", style: const TextStyle(color: Colors.white, fontSize: 13)),
                                subtitle: Text(
                                  "Recipient: ${log['recipient_id']} | Channel: $channels",
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(26),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: statusColor.withAlpha(102)),
                                      ),
                                      child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log['sent_at'] != null
                                          ? log['sent_at'].toString().split('.')[0].replaceFirst('T', ' ')
                                          : 'Now',
                                      style: const TextStyle(color: Colors.white24, fontSize: 9),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    final total = _analytics['sent'] + _analytics['failed'] + _analytics['dead'];
    final deliveryRate = _analytics['success_rate'];
    final avgTime = _analytics['avg_delivery_time_ms'];

    // Simulated variant metrics derived from active logs list
    final variantATotal = _notificationLogs.where((log) => log['ab_variant'] == 'Variant A').length;
    final variantAClicked = _notificationLogs.where((log) => log['ab_variant'] == 'Variant A' && log['status'] == 'clicked').length;
    final variantBTotal = _notificationLogs.where((log) => log['ab_variant'] == 'Variant B').length;
    final variantBClicked = _notificationLogs.where((log) => log['ab_variant'] == 'Variant B' && log['status'] == 'clicked').length;

    final double rateA = variantATotal > 0 ? (variantAClicked / variantATotal) * 100 : 0.0;
    final double rateB = variantBTotal > 0 ? (variantBClicked / variantBTotal) * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "TOTAL ATTEMPTS",
                value: total.toString(),
                color: const Color(0xFFC9A77E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "SUCCESS RATE",
                value: "${deliveryRate.toString()}%",
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "AVG TIME (MS)",
                value: avgTime.toString(),
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "PENDING QUEUE",
                value: _analytics['pending'].toString(),
                color: Colors.amberAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "PROCESSING / RETRY",
                value: "${_analytics['processing']} / ${_analytics['retry']}",
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "DEAD LETTER (DLQ)",
                value: _analytics['dead'].toString(),
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12271F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withAlpha(51)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("A/B SPLIT TESTING SUMMARY (CLICK METRICS)", style: TextStyle(color: Color(0xFFC9A77E), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Variant A (Control): $variantATotal sent | Click Rate: ${rateA.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text("Variant B (Promo copy): $variantBTotal sent | Click Rate: ${rateB.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC9A77E), letterSpacing: 1.5)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isObscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFC9A77E), fontSize: 12),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC9A77E))),
      ),
    );
  }
}
