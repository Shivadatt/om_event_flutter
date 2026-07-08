part of '../settings_notifications_tab.dart';

extension _NotifCampaignsExtension on _SettingsNotificationsTabState {
  Widget _buildChannelTestPanel() {
    return Column(
      children: [
        ExpansionTile(
          title: const Text(
            "FCM Push Test Panel",
            style: TextStyle(
              color: Color(0xFFC9A77E),
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  _buildTextField(
                    "Recipient User ID (Leave blank for self)",
                    testUserIdCtrl,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField("Push Title", testPushTitleCtrl),
                  const SizedBox(height: 8),
                  _buildTextField("Push Body Message", testPushBodyCtrl),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (isPushEnabled) {
                        Get.snackbar(
                          testPushTitleCtrl.text.isNotEmpty
                              ? testPushTitleCtrl.text
                              : "FCM Test Push",
                          testPushBodyCtrl.text,
                        );
                      } else {
                        Get.snackbar(
                          "FCM Disabled",
                          "Enable push notifications channel first.",
                        );
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
          title: const Text(
            "Resend Email Test Panel",
            style: TextStyle(
              color: Color(0xFFC9A77E),
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  _buildTextField(
                    "Test Recipient Email",
                    testEmailRecipientCtrl,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField("Email Subject", testEmailSubjectCtrl),
                  const SizedBox(height: 8),
                  _buildTextField("Email HTML Content", testEmailContentCtrl),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isEmailEnabled) {
                        Get.snackbar(
                          "Email Disabled",
                          "Enable email channel first.",
                        );
                        return;
                      }
                      await NotificationGatewayService.to.sendEmail(
                        recipientEmail: testEmailRecipientCtrl.text,
                        subject: testEmailSubjectCtrl.text,
                        htmlContent: testEmailContentCtrl.text,
                        eventType: 'Manual Test Email',
                      );
                      Get.snackbar(
                        "Queued",
                        "Test email queued successfully in outbox.",
                      );
                    },
                    child: const Text("Test Resend Email"),
                  ),
                ],
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text(
            "Meta WhatsApp Test Panel",
            style: TextStyle(
              color: Color(0xFFC9A77E),
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  _buildTextField(
                    "Test Recipient Mobile (+91...)",
                    testWaPhoneCtrl,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField("Meta Template Name", testWaTemplateCtrl),
                  const SizedBox(height: 8),
                  _buildTextField(
                    "Body Params (Comma separated)",
                    testWaParamsCtrl,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isWhatsappEnabled) {
                        Get.snackbar(
                          "WhatsApp Disabled",
                          "Enable WhatsApp channel first.",
                        );
                        return;
                      }
                      final params = testWaParamsCtrl.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                      await NotificationGatewayService.to.sendWhatsApp(
                        recipientPhone: testWaPhoneCtrl.text,
                        templateName: testWaTemplateCtrl.text,
                        parameters: params,
                        eventType: 'Manual Test WhatsApp',
                      );
                      Get.snackbar(
                        "Queued",
                        "Test WhatsApp message queued successfully.",
                      );
                    },
                    child: const Text("Test Meta WhatsApp"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _executeSegmentedBroadcast() async {
    if (broadcastTitleCtrl.text.isEmpty || broadcastBodyCtrl.text.isEmpty) {
      Get.snackbar("Error", "Please enter broadcast details.");
      return;
    }

    Query<Map<String, dynamic>> query =
        _firestore.collection(AppCollections.customerProfiles);
    if (selectedSegment == 'Ahmedabad' || selectedSegment == 'Baroda') {
      query = query.where('branch', isEqualTo: selectedSegment);
    }

    final usersSnap = await query.get();
    if (usersSnap.docs.isEmpty) {
      Get.snackbar(
        "Outbox Empty",
        "No users matched the selected segment filter.",
      );
      return;
    }

    final batch = _firestore.batch();
    for (var doc in usersSnap.docs) {
      final notifRef =
          _firestore.collection(AppCollections.customerNotifications).doc();
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
    Get.snackbar(
      "Highlight Campaign",
      "Broadcast campaign queued to ${usersSnap.docs.length} customers.",
    );
  }
}
