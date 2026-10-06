import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/feature_flags.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/quotation_collaboration_controller.dart';
import 'quotes_chat_bubble.dart';
import 'chat_contact_cta_widget.dart';

/// Full-width Collaboration & Discussions workspace matching Option 2 Modern Card Style.
/// Displays an authentic real-time chat interface with message bubbles, customer/coordinator
/// roles, dynamic empty states, attachment support, and active message composer.
class QuotesChatSection extends StatefulWidget {
  final Quotation activeQuote;

  const QuotesChatSection({super.key, required this.activeQuote});

  @override
  State<QuotesChatSection> createState() => _QuotesChatSectionState();
}

class _QuotesChatSectionState extends State<QuotesChatSection> {
  QuotationCollaborationController? _chatController;

  @override
  void initState() {
    super.initState();
    // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
    // REASON: Not required for current business flow.
    // DO NOT DELETE - Keep for future reactivation.
    if (FeatureFlags.realtimeQuotationChat) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final currentUserName = FirebaseAuth.instance.currentUser?.displayName;

      _chatController = Get.put(
        QuotationCollaborationController(
          quotationId: widget.activeQuote.id,
          senderId: widget.activeQuote.customerId.isNotEmpty
              ? widget.activeQuote.customerId
              : (currentUserId ?? 'client_user'),
          senderName: widget.activeQuote.customerName.isNotEmpty
              ? widget.activeQuote.customerName
              : (currentUserName ?? 'Client'),
          senderRole: 'client',
        ),
        tag: widget.activeQuote.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TEMP DISABLED - OM EVENTS ADVANCED FEATURE
    // REASON: Not required for current business flow.
    // DO NOT DELETE - Keep for future reactivation.
    if (!FeatureFlags.realtimeQuotationChat || _chatController == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eyebrow Section Title ─────────────────────────────────────────────
          Text(
            "DIRECT CONTACT & COORDINATION",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // ── Proposal Assistance Contact Card ─────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF111713),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 4)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F1512),
                    border: Border(bottom: BorderSide(color: Color(0x1AD4AF37), width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "PROPOSAL ASSISTANCE",
                        style: GoogleFonts.italiana(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    "Have questions regarding this proposal or need customizations? Reach out directly via WhatsApp or Instagram for immediate coordination with our planning team.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                const ChatContactCtaWidget(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      );
    }

    final chatCtrl = _chatController!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Eyebrow Section Title ─────────────────────────────────────────────
        Text(
          "COLLABORATION & DISCUSSIONS",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),

        // ── Main Chat Interface Card ──────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Chat Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1512),
                  border: Border(bottom: BorderSide(color: Color(0x1AD4AF37), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "PROPOSAL COORDINATION CHAT",
                          style: GoogleFonts.italiana(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      final count = chatCtrl.combinedMessages.length;
                      return Text(
                        count == 0 ? "No messages yet" : "$count ${count == 1 ? 'message' : 'messages'}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 2. Chat Feed / Empty State Area
              Container(
                height: 250,
                color: const Color(0xFF0C110E),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Obx(() {
                  final messages = chatCtrl.combinedMessages;

                  // Empty State: Professional invitation to start discussion
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                              border: Border.all(color: const Color(0x33D4AF37)),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Color(0xFFD4AF37),
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Start a discussion",
                            style: GoogleFonts.italiana(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ask questions or request modifications.\nOur curation team will respond to your proposal.",
                            textAlign: TextAlign.center,
                            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }

                  // Active Conversation Feed
                  return ListView.builder(
                    controller: chatCtrl.scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, idx) {
                      final msg = messages[idx];
                      final isMe = msg.senderRole == 'client';
                      return QuotesChatBubble(msg: msg, isMe: isMe);
                    },
                  );
                }),
              ),

              // Contact Options CTA (Shown after 2 actual chat messages have been exchanged)
              Obx(() {
                final actualMessageCount = chatCtrl.combinedMessages.where((m) {
                  final t = m.type.toLowerCase();
                  final role = m.senderRole.toLowerCase();
                  return role != 'system' &&
                      t != 'system' &&
                      t != 'pricechange' &&
                      t != 'revision';
                }).length;

                if (actualMessageCount >= 2) {
                  return const ChatContactCtaWidget();
                }
                return const SizedBox.shrink();
              }),

              // 3. Upload Progress Indicator
              Obx(() {
                if (chatCtrl.isUploading.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: const Color(0x1AD4AF37),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFD4AF37)),
                        ),
                        SizedBox(width: 8),
                        Text("Uploading attachment...", style: TextStyle(color: Color(0xFFE6C98D), fontSize: 11)),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // 4. Integrated Message Composer Bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0x1AD4AF37), width: 1)),
                  color: Color(0xFF0D1410),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    // Attachment Action
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: Color(0xFFD4AF37), size: 20),
                      onPressed: () => chatCtrl.pickAndUploadAttachment(),
                      tooltip: "Attach Floorplan or Reference",
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(width: 6),

                    // Text Input Field
                    Expanded(
                      child: TextField(
                        controller: chatCtrl.textController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: "Type a message or request a modification...",
                          hintStyle: TextStyle(color: Colors.white30, fontSize: 12.5),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => chatCtrl.sendTextMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send Button with dynamic state & loading indicator
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: chatCtrl.textController,
                      builder: (context, value, _) {
                        final hasText = value.text.trim().isNotEmpty;
                        return Obx(() {
                          if (chatCtrl.isSending.value) {
                            return const SizedBox(
                              width: 32,
                              height: 32,
                              child: Center(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)),
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: hasText ? const Color(0xFFD4AF37) : const Color(0x22D4AF37),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color: hasText ? const Color(0xFF091210) : Colors.white30,
                                size: 16,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: hasText ? () => chatCtrl.sendTextMessage() : null,
                              tooltip: "Send Message",
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
