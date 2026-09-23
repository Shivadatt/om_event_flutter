import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/utils/booking_communication_helper.dart';
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

  Color _getStatusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.published:
      case QuotationStatus.draft:
      case QuotationStatus.viewed:
      case QuotationStatus.republished:
        return const Color(0xFFF59E0B);
      case QuotationStatus.acceptedByClient:
        return const Color(0xFF3B82F6);
      case QuotationStatus.bookingConfirmed:
      case QuotationStatus.inProgress:
        return const Color(0xFF10B981);
      case QuotationStatus.completed:
        return const Color(0xFFD4AF37);
      case QuotationStatus.cancelled:
      case QuotationStatus.rejectedByClient:
        return const Color(0xFFEF4444);
      default:
        return Colors.white54;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.sansBody(
          fontSize: 10,
          color: const Color(0xFFD4AF37),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "—",
              style: AppTheme.sansBody(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing,
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
        backgroundColor: const Color(0xFF152621),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Reject Booking Request",
          style: GoogleFonts.italiana(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please state the reason for rejecting booking ${booking.publicId}. The client will be notified.",
              style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "Rejection Reason *",
                labelStyle: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                hintText: "e.g. Date fully booked / Outside service zone",
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F1B18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "Additional Notes (Optional)",
                labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
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
              await controller.rejectBooking(booking, reason, noteCtrl.text.trim());
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
    final packageName = booking.items.firstOrNull?.theme ?? (booking.bookingDetails ?? "Standard");

    return Dialog(
      backgroundColor: const Color(0xFF122018),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: goldColor.withValues(alpha: 0.3), width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E332B), width: 1)),
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
                              booking.publicId,
                              style: AppTheme.serifHeader(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _getStatusColor(booking.status)),
                              ),
                              child: Text(
                                booking.status.name.toUpperCase(),
                                style: AppTheme.sansBody(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(booking.status),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Created on ${AppFormatters.formatDate(booking.createdAt)}",
                          style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
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
            ),

            // Content body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Info
                    _buildSectionHeader("Customer Information"),
                    _buildDetailRow("Client Name", booking.customerName),
                    _buildDetailRow(
                      "Phone Number",
                      booking.customerPhone,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_outlined, size: 18, color: Color(0xFFD4AF37)),
                            tooltip: "Call Customer",
                            onPressed: () => BookingCommunicationHelper.openCall(booking.customerPhone),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF4EBA7A)),
                            tooltip: "WhatsApp Customer",
                            onPressed: () async {
                              final msg = BookingCommunicationHelper.generateBookingWhatsAppMessage(
                                bookingId: booking.publicId,
                                serviceName: serviceName,
                                packageName: packageName,
                                eventDate: booking.eventDate,
                                status: booking.status,
                              );
                              await BookingCommunicationHelper.openWhatsApp(message: msg);
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDetailRow("Customer UID", booking.customerId),

                    // Event Information
                    _buildSectionHeader("Event Details"),
                    _buildDetailRow("Service Type", serviceName),
                    _buildDetailRow("Package", packageName),
                    _buildDetailRow("Event Date", AppFormatters.formatDate(booking.eventDate)),
                    _buildDetailRow("Event Time", booking.eventTime),
                    _buildDetailRow("Venue / Address", booking.location),
                    if (booking.notes.isNotEmpty)
                      _buildDetailRow("Client Notes", booking.notes),

                    // Financial Overview
                    _buildSectionHeader("Financial Overview"),
                    _buildDetailRow("Base Package", AppFormatters.formatCurrency(booking.subtotal)),
                    if (booking.travelCharge > 0)
                      _buildDetailRow("Travel & Logistics", AppFormatters.formatCurrency(booking.travelCharge)),
                    if (booking.discount > 0)
                      _buildDetailRow("Discount Applied", "-${AppFormatters.formatCurrency(booking.discount)}"),
                    const Divider(color: Color(0xFF1E332B), height: 18),
                    _buildDetailRow(
                      "Total Amount",
                      AppFormatters.formatCurrency(booking.grandTotal),
                    ),
                  ],
                ),
              ),
            ),

            // Action Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1E332B), width: 1)),
              ),
              child: Obx(() {
                final isSubmitting = controller.isActionSubmitting.value;

                if (booking.status == QuotationStatus.published ||
                    booking.status == QuotationStatus.draft ||
                    booking.status == QuotationStatus.viewed ||
                    booking.status == QuotationStatus.republished) {
                  return Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: isSubmitting ? null : () => _showRejectDialog(context, controller),
                        icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFEF4444)),
                        label: const Text("REJECT", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                Navigator.of(context).pop();
                                await controller.acceptBooking(booking);
                              },
                        icon: isSubmitting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text("ACCEPT BOOKING", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: const Color(0xFF0F1B18),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  );
                }

                if (booking.status == QuotationStatus.acceptedByClient) {
                  return Row(
                    children: [
                      OutlinedButton(
                        onPressed: isSubmitting ? null : () => _showRejectDialog(context, controller),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("REJECT", style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                Navigator.of(context).pop();
                                await controller.confirmBooking(booking);
                              },
                        icon: const Icon(Icons.verified_rounded, size: 16),
                        label: const Text("CONFIRM BOOKING (LOCK DATE)", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  );
                }

                if (booking.status == QuotationStatus.bookingConfirmed ||
                    booking.status == QuotationStatus.inProgress) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                Navigator.of(context).pop();
                                await controller.completeBooking(booking);
                              },
                        icon: const Icon(Icons.task_alt_rounded, size: 16),
                        label: const Text("MARK COMPLETED", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: const Color(0xFF0F1B18),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("CLOSE", style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
