import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/domain/entities/quotation.dart';
import 'package:om_event/presentation/controllers/customer_dashboard_controller.dart';
import 'digital_consent_dialog.dart';

/// Renders proposal action buttons (Accept, Decline, Download Contract PDF).
class QuotesActionsPanel extends StatelessWidget {
  final Quotation activeQuote;
  final CustomerDashboardController controller;

  const QuotesActionsPanel({
    super.key,
    required this.activeQuote,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (activeQuote.status == QuotationStatus.published || activeQuote.status == QuotationStatus.republished || activeQuote.status == QuotationStatus.viewed) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF091210),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              elevation: 4,
              shadowColor: const Color(0x33D4AF37),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => DigitalConsentDialog(
                  activeQuote: activeQuote,
                  onAccept: (signature) {
                    controller.acceptQuotation(activeQuote.id);
                  },
                ),
              );
            },
            child: const Text("ACCEPT & BOOK PROPOSAL"),
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 16,
              children: [
                if (activeQuote.status == QuotationStatus.published || activeQuote.status == QuotationStatus.republished || activeQuote.status == QuotationStatus.viewed)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC95C5C),
                      side: const BorderSide(color: Color(0x66C95C5C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: const Color(0xFF171411),
                          title: const Text("Decline Proposal"),
                          content: const Text("Are you sure you want to decline this curation proposal?"),
                          actions: [
                            TextButton(onPressed: () => Get.back(), child: const Text("CANCEL")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC95C5C)),
                              onPressed: () {
                                controller.rejectQuotation(activeQuote.id);
                                Get.back();
                              },
                              child: const Text("CONFIRM DECLINE"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("DECLINE PROPOSAL"),
                  ),
              ],
            ),
            if (activeQuote.pdfUrl.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 18, color: Color(0xFFD4AF37)),
                label: const Text("DOWNLOAD CONTRACT PDF"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0x33D4AF37)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                  textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                onPressed: () {
                  Get.snackbar(
                    "Download Triggered",
                    "Accessing secure storage bucket...",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF171411),
                    colorText: const Color(0xFFD4AF37),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
