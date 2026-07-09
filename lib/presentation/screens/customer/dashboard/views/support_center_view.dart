import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final replyCtrls = <String, TextEditingController>{};

  // Mock list of support tickets for layout display
  final rxTickets = <_MockTicket>[
    _MockTicket('T-102', 'Flower setup delay', 'Open', ['Customer: Can we add orange roses?', 'Support: Yes, checking with coordinator.']),
    _MockTicket('T-101', 'Invoice receipt mismatch', 'Closed', ['Customer: Uploaded receipt, please check.', 'Support: Verified, thank you!']),
  ].obs;

  @override
  void dispose() {
    subjectCtrl.dispose();
    messageCtrl.dispose();
    for (var ctrl in replyCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CONCIERGE HELP & CHAT",
                    style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Premium Concierge Center",
                    style: GoogleFonts.italiana(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_comment_outlined, size: 16),
                label: const Text("RAISE SUPPORT TICKET"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF091210),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: _showRaiseTicketDialog,
              )
            ],
          ),
          const SizedBox(height: 24),

          // Quick contact buttons
          Row(
            children: [
              _buildContactButton("WHATSAPP CHAT", Icons.chat_bubble_outline, const Color(0xFF7CA68E), () {}),
              const SizedBox(width: 16),
              _buildContactButton("CALL HOTLINE", Icons.phone_in_talk_outlined, const Color(0xFFD4AF37), () {}),
              const SizedBox(width: 16),
              _buildContactButton("EMAIL DESK", Icons.mail_outline, const Color(0xFFE6C98D), () {}),
            ],
          ),
          const SizedBox(height: 32),

          // Tickets list
          Text(
            "TICKET HISTORY",
            style: GoogleFonts.italiana(fontSize: 18, color: const Color(0xFFD4AF37), letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (rxTickets.isEmpty) {
                return Center(
                  child: Text("No support tickets raised yet.", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: rxTickets.length,
                itemBuilder: (context, index) {
                  final ticket = rxTickets[index];
                  if (!replyCtrls.containsKey(ticket.ticketId)) {
                    replyCtrls[ticket.ticketId] = TextEditingController();
                  }
                  final replyCtrl = replyCtrls[ticket.ticketId]!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171411),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1AD4AF37)),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: const Color(0xFFD4AF37),
                        collapsedIconColor: Colors.white70,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(
                          "${ticket.ticketId}: ${ticket.subject.toUpperCase()}",
                          style: GoogleFonts.italiana(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "STATUS: ${ticket.status == 'Open' ? 'ACTIVE REVIEW' : 'RESOLVED'}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ticket.status == 'Open' ? const Color(0xFFE6C98D) : Colors.white30,
                            ),
                          ),
                        ),
                        children: [
                          const Divider(color: Color(0x1AD4AF37), height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...ticket.messages.map((msg) {
                                  final isCustomer = msg.startsWith("Customer:");
                                  final cleanText = msg.replaceFirst(isCustomer ? "Customer: " : "Support: ", "");

                                  return Align(
                                    alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isCustomer ? const Color(0xFF2A241F) : const Color(0xFF0F0D0B),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft: Radius.circular(isCustomer ? 12 : 0),
                                          bottomRight: Radius.circular(isCustomer ? 0 : 12),
                                        ),
                                        border: Border.all(
                                          color: isCustomer ? const Color(0x22D4AF37) : Colors.white10,
                                        ),
                                      ),
                                      child: Text(
                                        cleanText,
                                        style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),
                                if (ticket.status == 'Open') ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: replyCtrl,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: "Type reply message...",
                                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                                            filled: true,
                                            fillColor: Colors.black26,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Colors.white10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                                            ),
                                          ),
                                          onSubmitted: (val) {
                                            if (val.isNotEmpty) {
                                              setState(() {
                                                ticket.messages.add("Customer: $val");
                                                replyCtrl.clear();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(Icons.send_outlined, color: Color(0xFFD4AF37)),
                                        onPressed: () {
                                          if (replyCtrl.text.isNotEmpty) {
                                            setState(() {
                                              ticket.messages.add("Customer: ${replyCtrl.text}");
                                              replyCtrl.clear();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFC95C5C),
                                      side: const BorderSide(color: Color(0x66C95C5C)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        ticket.status = 'Closed';
                                      });
                                      Get.snackbar("Ticket Closed", "Concierge support ticket has been archived.");
                                    },
                                    child: const Text("CLOSE TICKET", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
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
    return Expanded(
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          title,
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white.withValues(alpha: 0.02),
        ),
        onPressed: onTap,
      ),
    );
  }

  void _showRaiseTicketDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF171411),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x33D4AF37), width: 1.5),
        ),
        title: Text(
          "RAISE CONCIERGE TICKET",
          style: AppTheme.serifHeader(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(subjectCtrl, "Subject / Topic", "e.g., Flower arrangement modification"),
            const SizedBox(height: 16),
            _buildDialogField(messageCtrl, "Description", "Please describe your query in detail...", maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("CANCEL", style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
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
            child: const Text("SUBMIT", style: TextStyle(color: Color(0xFF091210), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
      ],
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
