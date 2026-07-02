import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/services/notification_gateway_service.dart';
import '../../../../core/config/app_theme.dart';

class SettingsNotificationsTab extends StatefulWidget {
  const SettingsNotificationsTab({super.key});

  @override
  State<SettingsNotificationsTab> createState() => _SettingsNotificationsTabState();
}

class _SettingsNotificationsTabState extends State<SettingsNotificationsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  void dispose() {
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
      final snap = await _firestore
          .collection(AppCollections.notificationQueue)
          .where('status', whereIn: ['failed', 'retry'])
          .get();

      if (snap.docs.isEmpty) {
        Get.snackbar("Outbox Empty", "No failed tasks found in the queue.");
        return;
      }

      final batch = _firestore.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {
          'status': 'pending',
          'retryCount': 0,
          'errorMessage': '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      Get.snackbar("Success", "Reset ${snap.docs.length} failed tasks back to pending.");
    } catch (e) {
      Get.snackbar("Error", "Failed to reset tasks: $e");
    }
  }

  Future<void> _retrySingleTask(String taskId) async {
    try {
      await _firestore
          .collection(AppCollections.notificationQueue)
          .doc(taskId)
          .update({
        'status': 'pending',
        'retryCount': 0,
        'errorMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar("Success", "Task queued for retry.");
    } catch (e) {
      Get.snackbar("Error", "Failed to retry task: $e");
    }
  }

  Future<void> _retryDlqTask(String dlqId, Map<String, dynamic> payload) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final newQueueRef = _firestore.collection(AppCollections.notificationQueue).doc();
        transaction.set(newQueueRef, {
          ...payload,
          'status': 'pending',
          'retryCount': 0,
          'errorMessage': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final dlqRef = _firestore.collection(AppCollections.deadLetterNotifications).doc(dlqId);
        transaction.delete(dlqRef);
      });
      Get.snackbar("Success", "Dead Letter task re-queued successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to retry DLQ: $e");
    }
  }

  Future<void> _deleteDlqTask(String dlqId) async {
    try {
      await _firestore.collection(AppCollections.deadLetterNotifications).doc(dlqId).delete();
      Get.snackbar("Success", "DLQ log deleted permanently.");
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

  /// Bulk export delivery logs as JSON Dialog
  Future<void> _exportDeliveryLogs() async {
    try {
      final snap = await _firestore.collection(AppCollections.notificationLogs).limit(50).get();
      final logsList = snap.docs.map((d) => d.data()).toList();

      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF12271F),
          title: Text("Export Logs JSON Format", style: AppTheme.serifHeader(fontSize: 18)),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black26,
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(logsList),
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

          // 1. Live Analytics Dashboard (Delivery rates lifecycle & A/B conversion rates)
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection(AppCollections.scheduledNotifications)
                      .orderBy('triggerAt', descending: false)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text("No scheduled reminders pending.", style: TextStyle(color: Colors.white38, fontSize: 12)));
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final rem = docs[index].data();
                        final isSent = rem['status'] == 'sent';
                        final channel = (rem['channel'] ?? 'email').toString().toUpperCase();

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("${rem['title'] ?? 'Reminder'} [$channel]", style: const TextStyle(color: Colors.white, fontSize: 13)),
                          subtitle: Text(
                            "Trigger Date: ${rem['triggerAt'] != null ? (rem['triggerAt'] as Timestamp).toDate().toString().split('.')[0] : 'Pending'}",
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
                              isSent ? "SENT" : "PENDING",
                              style: TextStyle(color: isSent ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection(AppCollections.notificationQueue)
                      .orderBy('updatedAt', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text("No tasks in outbox queue.", style: TextStyle(color: Colors.white54)));
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final task = docs[index].data();
                        final taskId = docs[index].id;
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
                              Text("Recipient: $recipient | Retries: ${task['retryCount'] ?? 0}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              if (task['errorMessage'] != null && task['errorMessage'].toString().isNotEmpty)
                                Text("Error: ${task['errorMessage']}", style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
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
              // DLQ Search Input
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection(AppCollections.deadLetterNotifications)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs.where((d) {
                      final reason = (d['reason'] ?? '').toString().toLowerCase();
                      return reason.contains(dlqSearchQuery);
                    }).toList();

                    if (docs.isEmpty) {
                      return const Center(child: Text("Dead letter queue is empty.", style: TextStyle(color: Colors.green, fontSize: 12)));
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final dlq = doc.data();
                        final dlqId = doc.id;
                        final payload = Map<String, dynamic>.from(dlq['payload'] ?? {});

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Reason: ${dlq['reason'] ?? 'Execution Error'} [${dlq['channel'] ?? 'PUSH'}]", style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          subtitle: Text("Retries: ${dlq['retryCount'] ?? 5} | Timestamp: ${dlq['timestamp'] ?? 'Now'}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
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
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Template Version Manager
          _buildCard(
            title: "TEMPLATE VERSION LIFECYCLE",
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ACTIVE VERSION", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: Colors.black26,
                          child: Text(activeTemplateVersion, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("DRAFT VERSION", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: Colors.black26,
                          child: Text(draftTemplateVersion, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        activeTemplateVersion = 'v1.1.0';
                        draftTemplateVersion = 'v1.2.0-draft';
                      });
                      Get.snackbar("Template Published", "Draft v1.1.0-draft rolled out to active templates.");
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: Colors.black),
                    child: const Text("Publish Draft to Active"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        activeTemplateVersion = 'v1.0.0';
                        draftTemplateVersion = 'v1.1.0-draft';
                      });
                      Get.snackbar("Rollback Success", "Reverted active templates back to v1.0.0.");
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFC9A77E)), foregroundColor: const Color(0xFFC9A77E)),
                    child: const Text("Rollback to Previous"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7. Channel Master Controls
          _buildCard(
            title: "NOTIFICATION DISPATCH CHANNELS",
            children: [
              SwitchListTile(
                title: const Text("Enable FCM Push Notifications", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Deliver in-app and device pushes", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: isPushEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => isPushEnabled = val),
              ),
              SwitchListTile(
                title: const Text("Enable Email Notifications (Resend)", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Deliver custom HTML templates to customers", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: isEmailEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => isEmailEnabled = val),
              ),
              SwitchListTile(
                title: const Text("Enable WhatsApp Message Alerts", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Deliver official Meta API templates to phones", style: TextStyle(color: Colors.white54, fontSize: 11)),
                value: isWhatsappEnabled,
                activeColor: const Color(0xFFC9A77E),
                onChanged: (val) => setState(() => isWhatsappEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 8. Channel Test Suite
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
                          onPressed: () {
                            if (isPushEnabled) {
                              Get.snackbar(testPushTitleCtrl.text.isNotEmpty ? testPushTitleCtrl.text : "FCM Test Push", testPushBodyCtrl.text);
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
                  
                  Query<Map<String, dynamic>> query = _firestore.collection(AppCollections.customerProfiles);
                  if (selectedSegment == 'Ahmedabad' || selectedSegment == 'Baroda') {
                    query = query.where('branch', isEqualTo: selectedSegment);
                  }

                  final usersSnap = await query.get();
                  if (usersSnap.docs.isEmpty) {
                    Get.snackbar("Outbox Empty", "No users matched the selected segment filter.");
                    return;
                  }

                  final batch = _firestore.batch();
                  for (var doc in usersSnap.docs) {
                    final notifRef = _firestore.collection(AppCollections.customerNotifications).doc();
                    batch.set(notifRef, {
                      'customerId': doc.id,
                      'title': broadcastTitleCtrl.text,
                      'body': broadcastBodyCtrl.text,
                      'type': 'Announcement',
                      'isRead': false,
                      'branch': selectedSegment,
                      'priority': selectedPriority,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  }
                  await batch.commit();

                  await _firestore.collection(AppCollections.notificationLogs).add({
                    'recipientId': 'SEGMENT: $selectedSegment',
                    'type': 'Broadcast Announcement',
                    'title': broadcastTitleCtrl.text,
                    'body': broadcastBodyCtrl.text,
                    'channelsUsed': ['push'],
                    'status': 'success',
                    'priority': selectedPriority,
                    'sentAt': FieldValue.serverTimestamp(),
                  });

                  broadcastTitleCtrl.clear();
                  broadcastBodyCtrl.clear();
                  Get.snackbar("Success", "Segment campaign queued successfully to ${usersSnap.docs.length} customers.");
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
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection(AppCollections.notificationLogs)
                      .orderBy('sentAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs.where((d) {
                      final title = (d['title'] ?? '').toString().toLowerCase();
                      final body = (d['body'] ?? '').toString().toLowerCase();
                      final recipient = (d['recipientId'] ?? '').toString().toLowerCase();
                      return title.contains(logSearchQuery) || body.contains(logSearchQuery) || recipient.contains(logSearchQuery);
                    }).toList();

                    if (docs.isEmpty) {
                      return const Center(child: Text("No notification logs registered.", style: TextStyle(color: Colors.white54)));
                    }
                    return ListView.builder(
                      itemCount: docs.length > 20 ? 20 : docs.length,
                      itemBuilder: (context, index) {
                        final log = docs[index].data();
                        final status = log['status'] ?? 'sent';
                        final channels = (log['channelsUsed'] as List? ?? []).join(', ').toUpperCase();
                        final variant = log['variant'] ?? 'Variant A';

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
                            "Recipient: ${log['recipientId']} | Channels: $channels",
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
                                log['sentAt'] != null
                                    ? (log['sentAt'] as Timestamp).toDate().toString().split('.')[0]
                                    : 'Now',
                                style: const TextStyle(color: Colors.white24, fontSize: 9),
                              ),
                            ],
                          ),
                        );
                      },
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

  /// Upgraded Analytics Dashboard with variant conversions
  Widget _buildAnalyticsDashboard() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection(AppCollections.notificationLogs).snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int delivered = 0;
        int opened = 0;
        int read = 0;
        int clicked = 0;
        int failed = 0;

        int variantATotal = 0;
        int variantAClicked = 0;
        int variantBTotal = 0;
        int variantBClicked = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          total = docs.length;
          delivered = docs.where((d) {
            final data = d.data();
            return data['status'] == 'delivered';
          }).length;
          opened = docs.where((d) {
            final data = d.data();
            return data['status'] == 'opened';
          }).length;
          read = docs.where((d) {
            final data = d.data();
            return data['status'] == 'read';
          }).length;
          clicked = docs.where((d) {
            final data = d.data();
            return data['status'] == 'clicked';
          }).length;
          failed = docs.where((d) {
            final data = d.data();
            return data['status'] == 'failed';
          }).length;

          variantATotal = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant A';
          }).length;
          variantAClicked = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant A' && data['status'] == 'clicked';
          }).length;
          variantBTotal = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant B';
          }).length;
          variantBClicked = docs.where((d) {
            final data = d.data();
            return data['variant'] == 'Variant B' && data['status'] == 'clicked';
          }).length;
        }

        final int deliveredTotal = delivered + opened + clicked + read;
        final double deliveryRate = total > 0 ? (deliveredTotal / total) * 100 : 100.0;
        final double openRate = deliveredTotal > 0 ? ((opened + clicked) / deliveredTotal) * 100 : 0.0;
        final double clickRate = deliveredTotal > 0 ? (clicked / deliveredTotal) * 100 : 0.0;
        final double readRate = deliveredTotal > 0 ? (read / deliveredTotal) * 100 : 0.0;

        final double rateA = variantATotal > 0 ? (variantAClicked / variantATotal) * 100 : 0.0;
        final double rateB = variantBTotal > 0 ? (variantBClicked / variantBTotal) * 100 : 0.0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "TOTAL SENT",
                    value: total.toString(),
                    color: const Color(0xFFC9A77E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "DELIVERY RATE",
                    value: "${deliveryRate.toStringAsFixed(1)}%",
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "OPEN RATE",
                    value: "${openRate.toStringAsFixed(1)}%",
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
                    title: "CLICK RATE",
                    value: "${clickRate.toStringAsFixed(1)}%",
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "WHATSAPP READS",
                    value: "${readRate.toStringAsFixed(1)}%",
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "FAILURES / BOUNCES",
                    value: failed.toString(),
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // A/B testing card stats
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
      },
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
