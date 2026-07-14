import 'package:flutter/material.dart';
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

    final aligns = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe 
        ? const Color(0xFFD4AF37).withValues(alpha: 0.15) 
        : Colors.white.withValues(alpha: 0.05);
    final borderColor = isMe 
        ? const Color(0xFFD4AF37).withValues(alpha: 0.3) 
        : Colors.white.withValues(alpha: 0.1);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: aligns,
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
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      msg.senderName.toUpperCase(),
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  if (!isMe) const SizedBox(height: 4),
                  if (msg.type == 'text')
                    Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                  if (msg.type == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(msg.content, fit: BoxFit.cover),
                    ),
                  if (msg.type == 'pdf' || msg.type == 'document')
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          msg.type == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            msg.attachments.isNotEmpty ? msg.attachments.first.fileName : "View Attachment",
                            style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white24, fontSize: 9),
                ),
                if (isMe) const SizedBox(width: 4),
                if (isMe)
                  msg.id.startsWith('temp_')
                      ? const Icon(
                          Icons.access_time_rounded,
                          size: 11,
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
    );
  }
}
