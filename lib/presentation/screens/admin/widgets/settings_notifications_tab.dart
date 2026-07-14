import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_collections.dart';
import '../../../../core/services/notification_gateway_service.dart';
import '../../../../core/config/app_theme.dart';

part 'parts/notif_saves.dart';
part 'parts/notif_dashboard.dart';
part 'parts/notif_campaigns.dart';
part 'parts/notif_queues.dart';
part 'parts/notif_gateways.dart';
part 'parts/notif_lifecycle.dart';

class SettingsNotificationsTab extends StatefulWidget {
  const SettingsNotificationsTab({super.key});

  @override
  State<SettingsNotificationsTab> createState() =>
      _SettingsNotificationsTabState();
}

class _SettingsNotificationsTabState extends State<SettingsNotificationsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final resendKeyCtrl = TextEditingController(text: 're_1234567890'),
      whatsappTokenCtrl = TextEditingController(text: 'EAABw...'),
      whatsappPhoneIdCtrl = TextEditingController(text: '1029384756'),
      whatsappBusinessIdCtrl = TextEditingController(text: '9876543210'),
      senderEmailCtrl = TextEditingController(
        text: 'notifications@omevents.com',
      );

  final testUserIdCtrl = TextEditingController(),
      testPushTitleCtrl = TextEditingController(),
      testPushBodyCtrl = TextEditingController(),
      testEmailRecipientCtrl = TextEditingController(),
      testEmailSubjectCtrl = TextEditingController(),
      testEmailContentCtrl = TextEditingController(),
      testWaPhoneCtrl = TextEditingController(),
      testWaTemplateCtrl = TextEditingController(),
      testWaParamsCtrl = TextEditingController();

  String logSearchQuery = '';
  String dlqSearchQuery = '';

  final broadcastTitleCtrl = TextEditingController(),
      broadcastBodyCtrl = TextEditingController();
  String selectedSegment = 'ALL';
  String selectedPriority = 'normal';

  String activeTemplateVersion = 'v1.0.0';
  String draftTemplateVersion = 'v1.1.0-draft';

  bool isPushEnabled = true;
  bool isEmailEnabled = true;
  bool isWhatsappEnabled = true;

  bool isAutomationEnabled = true;
  final expiryDaysCtrl = TextEditingController(text: '7');
  final reminderHoursCtrl = TextEditingController(text: '24');
  final followUpDaysCtrl = TextEditingController(text: '3');
  bool isSettingsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAutomationSettings();
  }

  Future<void> _loadAutomationSettings() async {
    try {
      updateState(() => isSettingsLoading = true);
      final doc = await _firestore.collection(AppCollections.automationSettings).doc('global_config').get();
      if (doc.exists) {
        final data = doc.data()!;
        updateState(() {
          isAutomationEnabled = data['isEnabled'] ?? true;
          expiryDaysCtrl.text = (data['expiryDurationDays'] ?? 7).toString();
          reminderHoursCtrl.text = (data['reminderTimingHours'] ?? 24).toString();
          followUpDaysCtrl.text = (data['followUpIntervalDays'] ?? 3).toString();
        });
      }
    } catch (_) {} finally {
      updateState(() => isSettingsLoading = false);
    }
  }

  Future<void> _saveAutomationSettings() async {
    try {
      updateState(() => isSettingsLoading = true);
      await _firestore.collection(AppCollections.automationSettings).doc('global_config').set({
        'isEnabled': isAutomationEnabled,
        'expiryDurationDays': int.tryParse(expiryDaysCtrl.text) ?? 7,
        'reminderTimingHours': int.tryParse(reminderHoursCtrl.text) ?? 24,
        'followUpIntervalDays': int.tryParse(followUpDaysCtrl.text) ?? 3,
        'bookingReminderDays': [7, 3, 1],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar("Success", "Automation settings updated successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to update settings: $e");
    } finally {
      updateState(() => isSettingsLoading = false);
    }
  }

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
    expiryDaysCtrl.dispose();
    reminderHoursCtrl.dispose();
    followUpDaysCtrl.dispose();
    super.dispose();
  }

  void updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notification Settings CMS",
            style: AppTheme.serifHeader(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            "Configure FCM, Resend API key, Meta WhatsApp Cloud API credentials, and monitor delivery outbox queues.",
            style: AppTheme.sansBody(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 24),

          _buildAnalyticsDashboard(),
          const SizedBox(height: 24),

          _buildScheduledCronReminders(),
          const SizedBox(height: 24),

          _buildApiGatewaysCredentials(),
          const SizedBox(height: 24),

          _buildOutboxDeliveryQueue(),
          const SizedBox(height: 24),

          _buildDeadLetterQueue(),
          const SizedBox(height: 24),

          _buildTemplateVersionLifecycle(),
          const SizedBox(height: 24),

          _buildNotificationDispatchChannels(),
          const SizedBox(height: 24),

          _buildCard(
            title: "CHANNEL TEST PANELS",
            children: [
              _buildChannelTestPanel(),
            ],
          ),
          const SizedBox(height: 24),

          _buildCard(
            title: "SEGMENTED BROADCAST CAMPAIGNS",
            children: [
              Row(
                children: [
                  const Text(
                    "Audience Segment: ",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF12271F),
                    value: selectedSegment,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(
                        value: 'ALL',
                        child: Text("All Customers"),
                      ),
                      DropdownMenuItem(
                        value: 'Ahmedabad',
                        child: Text("Ahmedabad Branch Only"),
                      ),
                      DropdownMenuItem(
                        value: 'Baroda',
                        child: Text("Baroda Branch Only"),
                      ),
                      DropdownMenuItem(
                        value: 'Confirmed Bookings',
                        child: Text("Confirmed Bookings Only"),
                      ),
                      DropdownMenuItem(
                        value: 'Leads Only',
                        child: Text("Inactive Leads Only"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        updateState(() => selectedSegment = val);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Priority: ",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF12271F),
                    value: selectedPriority,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text("Normal")),
                      DropdownMenuItem(
                        value: 'high',
                        child: Text("High (Bypass DND)"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        updateState(() => selectedPriority = val);
                      }
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.campaign),
                label: const Text("Broadcast to Target Audience"),
                onPressed: _executeSegmentedBroadcast,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildNotificationSystemAuditLogs(),
          const SizedBox(height: 24),

          _buildQuotationAutomationSettingsPanel(),
        ],
      ),
    );
  }

  Widget _buildQuotationAutomationSettingsPanel() {
    if (isSettingsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildCard(
      title: "QUOTATION AUTOMATION & SCHEDULER SETTINGS",
      children: [
        const Text(
          "Manage automatic quotation expiry windows, pre-expiry reminders, and customer follow-up alerts.",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enable Scheduler Automation",
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: isAutomationEnabled,
              activeThumbColor: Colors.amber,
              onChanged: (val) {
                updateState(() => isAutomationEnabled = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField("Expiry Duration (Days)", expiryDaysCtrl),
        const SizedBox(height: 12),
        _buildTextField("Pre-Expiry Reminder Interval (Hours)", reminderHoursCtrl),
        const SizedBox(height: 12),
        _buildTextField("Inactivity Follow-Up Interval (Days)", followUpDaysCtrl),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.save_rounded),
          label: const Text("Save Automation Rules", style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _saveAutomationSettings,
        ),
      ],
    );
  }
}
