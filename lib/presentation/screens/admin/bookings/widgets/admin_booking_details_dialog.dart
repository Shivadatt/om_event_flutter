import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/booking_status_helper.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/admin_booking_controller.dart';

void showAdminBookingDetailsDialog(BuildContext context, Quotation booking) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => AdminBookingDetailsDialog(booking: booking),
  );
}

class AdminBookingDetailsDialog extends StatelessWidget {
  final Quotation booking;

  const AdminBookingDetailsDialog({super.key, required this.booking});

  static const goldColor = Color(0xFFECC24A);

  Color _getStatusColor(Quotation booking, {bool isCancellationRequested = false}) {
    return BookingStatusHelper.getStatusColor(
      booking,
      isCancellationRequested: isCancellationRequested,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 9.5,
          color: goldColor,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: goldColor.withValues(alpha: 0.75)),
          const SizedBox(width: 8),
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "—",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminBookingController controller) {
    final reasonCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1E19),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: goldColor.withValues(alpha: 0.3), width: 1),
        ),
        title: Text(
          "Reject Booking Request",
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please state the reason for rejecting booking ${booking.publicId}. The client will be notified.",
              style: const TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                labelText: "Rejection Reason *",
                labelStyle: const TextStyle(color: goldColor, fontSize: 11.5),
                hintText: "e.g. Date fully booked / Outside service zone",
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                filled: true,
                fillColor: const Color(0xFF081410),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                labelText: "Additional Notes (Optional)",
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 11.5),
                filled: true,
                fillColor: const Color(0xFF081410),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white60, fontSize: 11)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(ctx).pop();
              final ok = await controller.rejectBooking(booking, reason, noteCtrl.text.trim());
              if (context.mounted && ok) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("CONFIRM REJECTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminBookingController>();
    final serviceName = booking.items.firstOrNull?.name ?? "Event Decor";
    final packageName = booking.items.firstOrNull?.theme ?? (booking.bookingDetails ?? "Standard");
    final clientNotes = booking.notes
        .split('\n')
        .where((line) => !line.toLowerCase().startsWith('expected guests:'))
        .join('\n')
        .trim();

    final isCancRequested = booking.customerAction == 'cancellation_requested' &&
        booking.status != QuotationStatus.cancelled;
    final statusCol = _getStatusColor(booking, isCancellationRequested: isCancRequested);
    final statusLabel = isCancRequested
        ? "CANCELLATION REQ"
        : BookingStatusHelper.getDisplayBookingStatus(booking).toUpperCase();

    return Obx(() {
      final isSubmitting = controller.isActionSubmitting.value;
      final action = controller.submittingAction.value;

      return PopScope(
        canPop: !isSubmitting,
        child: Dialog(
          backgroundColor: const Color(0xFF0B1713),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: goldColor.withValues(alpha: 0.32), width: 1.1),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: (MediaQuery.of(context).size.height * 0.9).clamp(380.0, 720.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header (Compact)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF162B21), width: 0.9)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  booking.publicId.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: goldColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusCol.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusCol.withValues(alpha: 0.75), width: 0.8),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: statusCol,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Created on ${AppFormatters.formatDate(booking.createdAt)}",
                              style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isSubmitting ? Colors.white24 : Colors.white70,
                          size: 18,
                        ),
                        tooltip: "Close",
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ),

            // 2. Compact Content Body (Scrolls only if constrained by screen height)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CUSTOMER INFORMATION
                    _buildSectionHeader("Customer Information"),
                    _buildDetailRow(
                      icon: Icons.person_outline_rounded,
                      label: "Client Name",
                      value: booking.customerName,
                    ),
                    _buildDetailRow(
                      icon: Icons.phone_outlined,
                      label: "Phone Number",
                      value: booking.customerPhone,
                      trailing: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: booking.customerPhone));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Phone number copied",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: const Color(0xFF0F1E19),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: goldColor.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1E19),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 0.8),
                          ),
                          child: const Icon(Icons.copy_rounded, size: 13, color: goldColor),
                        ),
                      ),
                    ),
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: "Customer UID",
                      value: booking.customerId,
                    ),

                    // EVENT DETAILS
                    _buildSectionHeader("Event Details"),
                    _buildDetailRow(
                      icon: Icons.celebration_outlined,
                      label: "Service Type",
                      value: serviceName,
                    ),
                    _buildDetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: "Package",
                      value: packageName,
                    ),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: "Event Date",
                      value: AppFormatters.formatDate(booking.eventDate),
                    ),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      label: "Event Time",
                      value: booking.eventTime,
                    ),
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: "Venue / Address",
                      value: booking.location,
                    ),
                    if (clientNotes.isNotEmpty)
                      _buildDetailRow(
                        icon: Icons.edit_note_rounded,
                        label: "Client Notes",
                        value: clientNotes,
                      ),

                    // FINANCIAL OVERVIEW
                    _buildSectionHeader("Financial Overview"),
                    _buildDetailRow(
                      icon: Icons.currency_rupee_rounded,
                      label: "Base Package",
                      value: AppFormatters.formatCurrency(booking.subtotal),
                    ),
                    if (booking.travelCharge > 0)
                      _buildDetailRow(
                        icon: Icons.local_shipping_outlined,
                        label: "Travel & Logistics",
                        value: AppFormatters.formatCurrency(booking.travelCharge),
                      ),
                    if (booking.discount > 0)
                      _buildDetailRow(
                        icon: Icons.discount_outlined,
                        label: "Discount Applied",
                        value: "-${AppFormatters.formatCurrency(booking.discount)}",
                      ),
                    const Divider(color: Color(0xFF162B21), height: 14, thickness: 0.7),
                    _buildDetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: "Total Amount",
                      value: AppFormatters.formatCurrency(booking.grandTotal),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Action Footer (Directly beneath content with zero empty void)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF162B21), width: 0.9)),
              ),
              child: Builder(builder: (_) {
                if (booking.status == QuotationStatus.published ||
                    booking.status == QuotationStatus.draft ||
                    booking.status == QuotationStatus.viewed ||
                    booking.status == QuotationStatus.republished) {
                  final isRejecting = action == 'reject';
                  final isAccepting = action == 'accept';

                  return Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: isSubmitting ? null : () => _showRejectDialog(context, controller),
                        icon: isRejecting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                            : const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
                        label: Text(
                          isRejecting ? "REJECTING..." : "REJECT",
                          style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444), width: 0.9),
                          backgroundColor: const Color(0xFF261212).withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final ok = await controller.acceptBooking(booking);
                                if (context.mounted && ok) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: isAccepting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF091410)))
                            : const Icon(Icons.check_circle_outline_rounded, size: 15, color: Color(0xFF091410)),
                        label: Text(
                          isAccepting ? "ACCEPTING..." : "ACCEPT BOOKING",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF091410)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  );
                }

                if (booking.status == QuotationStatus.acceptedByClient) {
                  final isRejecting = action == 'reject';
                  final isConfirming = action == 'confirm';

                  return Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: isSubmitting ? null : () => _showRejectDialog(context, controller),
                        icon: isRejecting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                            : const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
                        label: Text(
                          isRejecting ? "REJECTING..." : "REJECT",
                          style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444), width: 0.9),
                          backgroundColor: const Color(0xFF261212).withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final ok = await controller.confirmBooking(booking);
                                if (context.mounted && ok) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: isConfirming
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.verified_rounded, size: 15, color: Colors.white),
                        label: Text(
                          isConfirming ? "CONFIRMING..." : "CONFIRM BOOKING (LOCK DATE)",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  );
                }

                if (booking.status == QuotationStatus.bookingConfirmed ||
                    booking.status == QuotationStatus.inProgress) {
                  final isCompleting = action == 'complete';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final ok = await controller.completeBooking(booking);
                                if (context.mounted && ok) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: isCompleting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF091410)))
                            : const Icon(Icons.task_alt_rounded, size: 15, color: Color(0xFF091410)),
                        label: Text(
                          isCompleting ? "COMPLETING..." : "MARK COMPLETED",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF091410)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text("CLOSE", style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
});
}
}
