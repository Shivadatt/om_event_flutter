import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/admin_booking_controller.dart';

void showAdminCancellationReviewDialog(BuildContext context, Quotation booking) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => AdminCancellationReviewDialog(booking: booking),
  );
}

class AdminCancellationReviewDialog extends StatelessWidget {
  final Quotation booking;

  const AdminCancellationReviewDialog({super.key, required this.booking});

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : "—",
            style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showRejectionInput(BuildContext context, AdminBookingController controller) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF152621),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Reject Cancellation Request",
          style: GoogleFonts.italiana(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please state why the cancellation request cannot be accepted (e.g. advance preparation costs incurred or request within non-cancellation window).",
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "Rejection Reason *",
                labelStyle: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F1B18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              await controller.rejectCancellation(booking, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text("CONFIRM REJECTION"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminBookingController>();
    final goldColor = const Color(0xFFD4AF37);
    final serviceName = booking.items.firstOrNull?.name ?? "Event Decor";

    return Dialog(
      backgroundColor: const Color(0xFF122018),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.4), width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.event_busy_outlined, size: 24, color: Color(0xFFEF4444)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CANCELLATION REQUEST",
                        style: AppTheme.sansBody(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      Text(
                        booking.publicId,
                        style: AppTheme.serifHeader(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const Divider(color: Color(0xFF1E332B), height: 24),

            _buildField("Client Name", booking.customerName),
            _buildField("Contact Phone", booking.customerPhone),
            _buildField("Service / Event Date", "$serviceName • ${AppFormatters.formatDate(booking.eventDate)}"),
            _buildField("Booking Total", AppFormatters.formatCurrency(booking.grandTotal)),

            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF261919),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE57373).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CLIENT CANCELLATION REMARKS",
                    style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFFE57373), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (booking.revisionReason != null && booking.revisionReason!.isNotEmpty)
                        ? booking.revisionReason!
                        : (booking.notes.isNotEmpty ? booking.notes : "Client requested cancellation through portal."),
                    style: AppTheme.sansBody(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Obx(() {
              final isSubmitting = controller.isActionSubmitting.value;
              return Row(
                children: [
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => _showRejectionInput(context, controller),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text("REJECT CANCELLATION", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            Navigator.of(context).pop();
                            await controller.approveCancellation(booking);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("APPROVE & CANCEL", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
