import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/booking_communication_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import 'booking_tracker_dialog.dart';

class QuoteSuccessActionButtons extends StatelessWidget {
  final dynamic quote;
  final Color goldColor;

  const QuoteSuccessActionButtons({
    super.key,
    required this.quote,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              final quoteObj = quote;
              final ref = quoteObj?.publicId ?? '';
              final service =
                  quoteObj?.items.firstOrNull?.name ?? 'Event Decor';
              final date =
                  quoteObj != null
                      ? AppFormatters.formatDate(quoteObj.eventDate)
                      : '';
              final venue = quoteObj?.location ?? '';

              final buffer = StringBuffer();
              buffer.writeln("Hello Om Events & Decorators,");
              buffer.writeln();
              buffer.writeln("I have submitted a new booking request.");
              buffer.writeln();
              buffer.writeln("Booking ID: $ref");
              buffer.writeln("Service: $service");
              if (date.isNotEmpty) buffer.writeln("Event Date: $date");
              if (venue.isNotEmpty) buffer.writeln("Venue: $venue");
              buffer.writeln();
              buffer.write(
                "Please confirm my date and provide styling proposal.",
              );

              await BookingCommunicationHelper.openWhatsApp(
                message: buffer.toString(),
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              "CONFIRM ON WHATSAPP",
              style: AppTheme.sansBody(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () {
              showBookingTrackerDialog(
                context,
                initialReferenceId: quote?.publicId,
              );
            },
            icon: Icon(Icons.track_changes_rounded, size: 18, color: goldColor),
            label: Text(
              "TRACK BOOKING STATUS",
              style: AppTheme.sansBody(
                fontSize: 12,
                color: goldColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: goldColor, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (quote != null && (quote.pdfUrl as String).isNotEmpty) ...[
          CustomButton(
            text: "Download PDF proposal",
            isPrimary: false,
            onPressed: () async {
              final uri = Uri.parse(quote.pdfUrl as String);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: 12),
        ],
        CustomButton(
          text: "Return to home",
          isPrimary: false,
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ],
    );
  }
}
