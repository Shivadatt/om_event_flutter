import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/booking_status_helper.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../domain/entities/quotation.dart';
import 'admin_booking_details_dialog.dart';

class AdminBookingCard extends StatelessWidget {
  final Quotation booking;
  final bool isGridCard;

  const AdminBookingCard({
    super.key,
    required this.booking,
    this.isGridCard = false,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFECC24A);
    final isCancRequested = booking.customerAction == 'cancellation_requested' &&
        booking.status != QuotationStatus.cancelled;
    final statusCol = BookingStatusHelper.getStatusColor(
      booking,
      isCancellationRequested: isCancRequested,
    );
    final statusLabel = isCancRequested
        ? "CANCELLATION REQ"
        : BookingStatusHelper.getDisplayBookingStatus(booking).toUpperCase();

    final serviceName = booking.items.firstOrNull?.name ?? "Event Decor";
    final initial = booking.customerName.isNotEmpty ? booking.customerName[0].toUpperCase() : "C";

    return InkWell(
      onTap: () => showAdminBookingDetailsDialog(context, booking),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: isGridCard ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1914),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: goldColor.withValues(alpha: 0.18), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Booking ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.publicId.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      color: goldColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCancRequested
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : statusCol.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCancRequested
                          ? const Color(0xFFEF4444)
                          : statusCol.withValues(alpha: 0.7),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isCancRequested ? const Color(0xFFEF4444) : statusCol,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Customer Name & Phone
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF162B20),
                    shape: BoxShape.circle,
                    border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        booking.customerName.isNotEmpty ? booking.customerName : "Unnamed Customer",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (booking.customerPhone.isNotEmpty)
                        Text(
                          booking.customerPhone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Service Name
            Row(
              children: [
                const Icon(Icons.celebration_outlined, size: 13, color: goldColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Event Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12.5, color: goldColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${AppFormatters.formatShortDate(booking.eventDate)} • ${booking.eventTime.isNotEmpty ? booking.eventTime : 'Time TBA'}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Venue / Address
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: goldColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.location.isNotEmpty ? booking.location : "Venue TBA",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bottom Row: Amount + Details Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatCurrency(booking.grandTotal),
                  style: GoogleFonts.montserrat(
                    fontSize: 13.5,
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: goldColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF091410),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
