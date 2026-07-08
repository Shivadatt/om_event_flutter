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
        ],
      ),
    );
  }
}
