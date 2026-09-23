import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../controllers/quotation_controller.dart';
import 'widgets/booking_tracker_dialog.dart';
import '../../../core/utils/booking_communication_helper.dart';

class QuoteSuccessScreen extends StatelessWidget {
  const QuoteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteController = Get.find<QuotationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quote = quoteController.rxCreatedQuotation.value;
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goldColor.withValues(alpha: 0.12),
                      border: Border.all(color: goldColor.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 44,
                      color: goldColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Booking Request Received!",
                    textAlign: TextAlign.center,
                    style: AppTheme.serifHeader(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your event booking has been securely registered in our system. Our decor design team is reviewing your requirements and preparing the styling moodboard.",
                    textAlign: TextAlign.center,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                      height: 1.6,
                    ),
                  ),
                  if (quote != null) ...[
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "BOOKING REFERENCE ID",
                                    style: AppTheme.sansBody(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    quote.publicId,
                                    style: AppTheme.serifHeader(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: goldColor,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                color: goldColor,
                                tooltip: "Copy Reference ID",
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: quote.publicId));
                                  Get.snackbar(
                                    "Copied to Clipboard",
                                    "Reference ID ${quote.publicId} copied.",
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _detailRow(
                            "EVENT SERVICE",
                            quote.items.firstOrNull?.name ?? "Event Decor",
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            "EVENT DATE",
                            AppFormatters.formatDate(quote.eventDate),
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            "VENUE LOCATION",
                            quote.location,
                            isDark,
                          ),
                          const SizedBox(height: 8),
                          _detailRow(
                            "ESTIMATED TOTAL",
                            AppFormatters.formatCurrency(quote.grandTotal),
                            isDark,
                            isBold: true,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4EBA7A).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF4EBA7A).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.security, size: 14, color: Color(0xFF4EBA7A)),
                                const SizedBox(width: 8),
                                Text(
                                  "1 EVENT PER DAY POLICY: Slot Reserved For Review",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4EBA7A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),

                  // WhatsApp Direct Confirmation CTA
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final quoteObj = quote;
                        final ref = quoteObj?.publicId ?? '';
                        final service = quoteObj?.items.firstOrNull?.name ?? 'Event Decor';
                        final date = quoteObj != null ? AppFormatters.formatDate(quoteObj.eventDate) : '';
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
                        buffer.write("Please confirm my date and provide styling proposal.");

                        await BookingCommunicationHelper.openWhatsApp(message: buffer.toString());
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
                      label: Text(
                        "CONFIRM ON WHATSAPP",
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Track My Booking Button
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
                        style: AppTheme.sansBody(fontSize: 12, color: goldColor, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: goldColor, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (quote != null && quote.pdfUrl.isNotEmpty) ...[
                    CustomButton(
                      text: "Download PDF proposal",
                      isPrimary: false,
                      onPressed: () async {
                        final uri = Uri.parse(quote.pdfUrl);
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
            letterSpacing: 1,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTheme.sansBody(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
