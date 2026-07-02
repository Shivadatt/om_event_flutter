import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Support Ticket and Hotline communications view for customers.
class SupportCenterView extends StatefulWidget {
  final CustomerDashboardController controller;

  const SupportCenterView({
    super.key,
    required this.controller,
  });

  @override
  State<SupportCenterView> createState() => _SupportCenterViewState();
}

class _SupportCenterViewState extends State<SupportCenterView> {
  final subjectCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  // Mock list of support tickets for layout display
  final rxTickets = <_MockTicket>[
    _MockTicket('T-102', 'Flower setup delay', 'Open', ['Customer: Can we add orange roses?', 'Support: Yes, checking with coordinator.']),
    _MockTicket('T-101', 'Invoice receipt mismatch', 'Closed', ['Customer: Uploaded receipt, please check.', 'Support: Verified, thank you!']),
  ].obs;

  @override
  void dispose() {
    subjectCtrl.dispose();
    messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Support Center & Hotlines", style: AppTheme.serifHeader(fontSize: 24)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_comment_outlined, size: 16),
                label: const Text("Raise Support Ticket"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                onPressed: _showRaiseTicketDialog,
              )
            ],
          ),
          const SizedBox(height: 16),

          // Quick contact buttons
          Row(
            children: [
              _buildContactButton("WhatsApp Chat", Icons.chat_bubble_outline, Colors.green, () {}),
              const SizedBox(width: 12),
              _buildContactButton("Call Support", Icons.phone_in_talk_outlined, const Color(0xFFC9A77E), () {}),
              const SizedBox(width: 12),
              _buildContactButton("Email Desk", Icons.mail_outline, Colors.blue, () {}),
            ],
          ),
          const SizedBox(height: 24),

          // Tickets list
          Text("Ticket History", style: AppTheme.serifHeader(fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (rxTickets.isEmpty) {
                return const Center(child: Text("No support tickets raised yet."));
              }
              return ListView.builder(
                itemCount: rxTickets.length,
                itemBuilder: (context, index) {
                  final ticket = rxTickets[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      iconColor: const Color(0xFFC9A77E),
                      collapsedIconColor: Colors.white70,
                      title: Text("${ticket.ticketId}: ${ticket.subject}"),
                      subtitle: Text("Status: ${ticket.status}", style: TextStyle(color: ticket.status == 'Open' ? Colors.orange : Colors.grey)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...ticket.messages.map((msg) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                              )),
                              const SizedBox(height: 16),
                              if (ticket.status == 'Open') ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: const InputDecoration(hintText: "Type reply message...", hintStyle: TextStyle(color: Colors.white30)),
                                        style: const TextStyle(color: Colors.white),
                                        onSubmitted: (val) {
                                          if (val.isNotEmpty) {
                                            setState(() {
                                              ticket.messages.add("Customer: $val");
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send, color: Color(0xFFC9A77E)),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      ticket.status = 'Closed';
                                    });
                                    Get.snackbar("Ticket Closed", "Support ticket has been closed.");
                                  },
                                  child: const Text("Close Ticket", style: TextStyle(color: Colors.white)),
                                ),
                              ]
                            ],
                          ),
                        )
                      ],
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

  Widget _buildContactButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16, color: color),
      label: Text(title, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF12271F),
        foregroundColor: Colors.white,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      onPressed: onTap,
    );
  }

  void _showRaiseTicketDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF12271F),
        title: Text("Raise Support Ticket", style: AppTheme.serifHeader(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: "Subject / Topic", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(labelText: "Detailed Description", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
            onPressed: () {
              if (subjectCtrl.text.isNotEmpty) {
                setState(() {
                  rxTickets.insert(0, _MockTicket('T-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', subjectCtrl.text, 'Open', ['Customer: ${messageCtrl.text}']));
                });
                subjectCtrl.clear();
                messageCtrl.clear();
                Get.back();
              }
            },
            child: const Text("Submit", style: TextStyle(color: Color(0xFF091210))),
          ),
        ],
      ),
    );
  }
}

class _MockTicket {
  final String ticketId;
  final String subject;
  String status;
  final List<String> messages;
  _MockTicket(this.ticketId, this.subject, this.status, this.messages);
}
