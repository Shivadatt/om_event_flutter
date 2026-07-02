import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/admin_customer_portal_controller.dart';

/// Admin sub-view for composing and broadcasting notification alerts.
class NotificationsAdminView extends StatefulWidget {
  final AdminCustomerPortalController portalController;

  const NotificationsAdminView({
    super.key,
    required this.portalController,
  });

  @override
  State<NotificationsAdminView> createState() => _NotificationsAdminViewState();
}

class _NotificationsAdminViewState extends State<NotificationsAdminView> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF12271F), borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Broadcast Notification", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "Title"),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(labelText: "Body Message"),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                      widget.portalController.adminSendNotification(
                        customerId: 'MOCK_CUSTOMER_ID',
                        title: titleCtrl.text,
                        body: bodyCtrl.text,
                        type: 'Announcement',
                      );
                      titleCtrl.clear();
                      bodyCtrl.clear();
                    }
                  },
                  child: const Text("Broadcast", style: TextStyle(color: Color(0xFF091210))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: widget.portalController.rxAllNotifications.length,
                itemBuilder: (context, index) {
                  final notif = widget.portalController.rxAllNotifications[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    child: ListTile(
                      title: Text(notif.title),
                      subtitle: Text(notif.body),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
