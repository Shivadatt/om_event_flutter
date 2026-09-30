import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:om_event/domain/entities/quotation_message.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders a single chat bubble (text, image, PDF, or system log) inside the coordination feed.
class QuotesChatBubble extends StatelessWidget {
  final QuotationMessage msg;
  final bool isMe;

  const QuotesChatBubble({
    super.key,
    required this.msg,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (msg.type == 'system' || msg.type == 'priceChange' || msg.type == 'revision') {
      Color bannerColor = const Color(0xFFD4AF37).withValues(alpha: 0.1);
      Color textColor = const Color(0xFFD4AF37);
      IconData icon = Icons.info_outline_rounded;

      if (msg.type == 'priceChange') {
        bannerColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
        textColor = const Color(0xFF81C784);
        icon = Icons.monetization_on_outlined;
      } else if (msg.type == 'revision') {
        bannerColor = const Color(0xFFE57373).withValues(alpha: 0.1);
        textColor = const Color(0xFFEF9A9A);
        icon = Icons.published_with_changes_rounded;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.content,
                style: TextStyle(color: textColor.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    final timeStr = DateFormat('h:mm a').format(msg.timestamp);

    if (isMe) {
      // ── Customer Message (Right-aligned with Gold Tint Bubble and User Avatar) ──
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message Content Column
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (msg.type == 'image' || msg.type == 'pdf' || msg.type == 'document')
                        ? () async {
                            try {
                              final uri = Uri.parse(msg.content);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            } catch (_) {}
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282114),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(color: const Color(0x44D4AF37), width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "You",
                            style: TextStyle(
                              color: Color(0xFFE5C378),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (msg.type == 'text')
                            Text(
                              msg.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          if (msg.type == 'image')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(msg.content, fit: BoxFit.cover),
                            ),
                          if (msg.type == 'pdf' || msg.type == 'document')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    msg.attachments.isNotEmpty
                                        ? msg.attachments.first.fileName
                                        : "View Attachment",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(color: Colors.white30, fontSize: 9.5),
                        ),
                        const SizedBox(width: 4),
                        msg.id.startsWith('temp_')
                            ? const Icon(
                                Icons.access_time_rounded,
                                size: 10,
                                color: Colors.white24,
                              )
                            : Icon(
                                msg.isReadByAdmin ? Icons.done_all_rounded : Icons.done_rounded,
                                size: 11,
                                color: msg.isReadByAdmin ? const Color(0xFFD4AF37) : Colors.white24,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // User Avatar (Right)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF262013),
                border: Border.all(color: const Color(0x66D4AF37), width: 1.2),
              ),
              child: const ClipOval(
                child: Center(
                  child: Icon(Icons.person_rounded, color: Color(0xFFE5C378), size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Coordinator Message (Left-aligned with Coordinator Avatar) ─────────────
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coordinator Avatar (Left)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF142018),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            ),
            child: const ClipOval(
              child: Center(
                child: Icon(Icons.support_agent_rounded, color: Color(0xFFD4AF37), size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Message Content Column
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: (msg.type == 'image' || msg.type == 'pdf' || msg.type == 'document')
                      ? () async {
                          try {
                            final uri = Uri.parse(msg.content);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          } catch (_) {}
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.senderName.isNotEmpty ? msg.senderName : "Coordinator",
                          style: const TextStyle(
                            color: Color(0xFFE5C378),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (msg.type == 'text')
                          Text(
                            msg.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        if (msg.type == 'image')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(msg.content, fit: BoxFit.cover),
                          ),
                        if (msg.type == 'pdf' || msg.type == 'document')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Color(0xFFD4AF37),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  msg.attachments.isNotEmpty
                                      ? msg.attachments.first.fileName
                                      : "View Attachment",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    timeStr,
                    style: const TextStyle(color: Colors.white30, fontSize: 9.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
