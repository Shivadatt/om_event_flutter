import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/booking_availability_service.dart';
import '../../../../core/utils/booking_status_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/quotation.dart';
import '../../../controllers/admin_booking_controller.dart';
import '../bookings/widgets/admin_booking_details_dialog.dart';
import 'widgets/admin_calendar_widget.dart';

class AdminAvailabilityScreen extends StatefulWidget {
  const AdminAvailabilityScreen({super.key});

  @override
  State<AdminAvailabilityScreen> createState() => _AdminAvailabilityScreenState();
}

class _AdminAvailabilityScreenState extends State<AdminAvailabilityScreen> {
  static const Color goldColor = Color(0xFFECC24A);
  static const Color pendingColor = Color(0xFFF59E0B);
  static const Color availableColor = Color(0xFF10B981);
  static const Color cardBg = Color(0xFF0C1914);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDefaultSelection();
    });
  }

  void _initDefaultSelection() {
    final controller = Get.find<AdminBookingController>();
    final currentSelected = controller.selectedCalendarDate.value;
    if (currentSelected != null && !BookingStatusHelper.isEventDatePassed(currentSelected)) {
      return;
    }

    final curMonth = controller.selectedCalendarMonth.value;
    final now = DateTime.now();

    // Find any ACTIVE / FUTURE booking in the current month to highlight first
    final bookingInMonth = controller.rxAllBookings.firstWhereOrNull((b) {
      if (b.status == QuotationStatus.cancelled ||
          b.status == QuotationStatus.rejectedByClient) {
        return false;
      }
      if (BookingStatusHelper.isEventDatePassed(b.eventDate)) {
        return false;
      }
      final ist = BookingAvailabilityService.toIst(b.eventDate);
      return ist.year == curMonth.year && ist.month == curMonth.month;
    });

    if (bookingInMonth != null) {
      final ist = BookingAvailabilityService.toIst(bookingInMonth.eventDate);
      controller.selectedCalendarDate.value = DateTime(ist.year, ist.month, ist.day);
    } else if (now.year == curMonth.year && now.month == curMonth.month) {
      controller.selectedCalendarDate.value = DateTime(now.year, now.month, now.day);
    } else {
      final firstOfMonth = DateTime(curMonth.year, curMonth.month, 1);
      if (!BookingStatusHelper.isEventDatePassed(firstOfMonth)) {
        controller.selectedCalendarDate.value = firstOfMonth;
      } else {
        controller.selectedCalendarDate.value = DateTime(now.year, now.month, now.day);
      }
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.5,
          height: 8.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatSelectedDate(DateTime date) {
    const monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminBookingController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Subtle Gold Luxury Flowing Waves Background ───────────────
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AvailabilityGoldWavesPainter(),
              ),
            ),
          ),

          // ── Main Content ─────────────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : 16,
              vertical: isDesktop ? 24 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page Header ─────────────────────────────────────────
                Text(
                  "AVAILABILITY CALENDAR",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Visual schedule of confirmed bookings and available event dates (1 event per day).",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Compact Horizontal Legend ───────────────────────────
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem("Confirmed / Accepted", goldColor),
                    _buildLegendItem("Pending Review", pendingColor),
                    _buildLegendItem("Available", const Color(0xFF142E24)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Calendar + Selected Date Inspector ──────────────────
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar takes ~63% of width
                      const Expanded(
                        flex: 63,
                        child: AdminCalendarWidget(),
                      ),
                      const SizedBox(width: 22),
                      // Details panel takes ~37% of width
                      Expanded(
                        flex: 37,
                        child: _buildDayInspector(context, controller),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      const AdminCalendarWidget(),
                      const SizedBox(height: 18),
                      _buildDayInspector(context, controller),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayInspector(BuildContext context, AdminBookingController controller) {
    return Obx(() {
      final selectedDate = controller.selectedCalendarDate.value;
      if (selectedDate == null || BookingStatusHelper.isEventDatePassed(selectedDate)) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_outlined, size: 32, color: Colors.white30),
              const SizedBox(height: 10),
              Text(
                "Select an Active Date",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Click today or any future day on the calendar to view scheduled bookings and availability details.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        );
      }

      final dateKey = BookingAvailabilityService.normalizeDateString(selectedDate);
      final booking = controller.bookingsByDateMap[dateKey] ??
          controller.rxAllBookings.firstWhereOrNull((b) {
            if (b.status == QuotationStatus.cancelled ||
                b.status == QuotationStatus.rejectedByClient) {
              return false;
            }
            final ist = BookingAvailabilityService.toIst(b.eventDate);
            return ist.year == selectedDate.year &&
                ist.month == selectedDate.month &&
                ist.day == selectedDate.day;
          });

      final bool isConfirmed = booking != null &&
          (booking.status == QuotationStatus.bookingConfirmed ||
              booking.status == QuotationStatus.acceptedByClient ||
              booking.status == QuotationStatus.inProgress ||
              booking.status == QuotationStatus.completed);

      final String badgeText = booking == null
          ? "AVAILABLE"
          : (isConfirmed ? "1 BOOKING SCHEDULED" : "1 BOOKING PENDING");

      final Color badgeColor = booking == null
          ? availableColor
          : (isConfirmed ? goldColor : pendingColor);

      final firstItem = booking?.items.firstOrNull;
      final itemName = firstItem?.name ?? 'Event Celebration';
      final itemTheme = firstItem?.theme ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.18),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Selected Date Title (e.g. 14 October 2026) ─────────────
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: goldColor,
                ),
                const SizedBox(width: 9),
                Text(
                  _formatSelectedDate(selectedDate),
                  style: GoogleFonts.montserrat(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Dynamic Status Badge (e.g. 1 BOOKING SCHEDULED) ───────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Booking Content or Available Empty State ──────────────
            if (booking != null) ...[
              // Booking Public ID
              Text(
                booking.publicId,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),

              // Customer Name
              Text(
                booking.customerName,
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),

              // Customer Phone
              Text(
                booking.customerPhone,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 12),

              // Service & Theme
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemTheme.isNotEmpty ? "$itemName ($itemTheme)" : itemName,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  if (itemTheme.isNotEmpty && itemTheme != itemName) ...[
                    const SizedBox(height: 2),
                    Text(
                      "($itemTheme)",
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Time & Venue
              Text(
                "Time: ${booking.eventTime} • Venue: ${booking.location}",
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 14),

              // Total Amount
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white70),
                  children: [
                    const TextSpan(text: "Total: "),
                    TextSpan(
                      text: AppFormatters.formatCurrency(booking.grandTotal),
                      style: GoogleFonts.montserrat(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => showAdminBookingDetailsDialog(context, booking),
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: Text(
                    "VIEW BOOKING DETAILS",
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: const Color(0xFF0C1813),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Available State
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: availableColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: availableColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: availableColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date is Available",
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: availableColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "No events scheduled. This date is completely free for new client reservations.",
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// Subtle luxury gold flowing waves painter across the background
class _AvailabilityGoldWavesPainter extends CustomPainter {
  const _AvailabilityGoldWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const goldColor = Color(0xFFECC24A);

    void drawWave(Path path, double opacity, double strokeWidth) {
      final paint = Paint()
        ..color = goldColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, paint);
    }

    final w = size.width;
    final h = size.height;

    // Flowing metallic curves radiating toward bottom right
    final path1 = Path()
      ..moveTo(w * 0.35, h)
      ..cubicTo(w * 0.50, h * 0.85, w * 0.70, h * 0.95, w, h * 0.65);
    drawWave(path1, 0.12, 1.0);

    final path2 = Path()
      ..moveTo(w * 0.40, h)
      ..cubicTo(w * 0.55, h * 0.82, w * 0.75, h * 0.92, w, h * 0.60);
    drawWave(path2, 0.15, 1.1);

    final path3 = Path()
      ..moveTo(w * 0.45, h)
      ..cubicTo(w * 0.60, h * 0.80, w * 0.80, h * 0.88, w, h * 0.55);
    drawWave(path3, 0.10, 0.9);

    final path4 = Path()
      ..moveTo(w * 0.50, h)
      ..cubicTo(w * 0.65, h * 0.78, w * 0.85, h * 0.84, w, h * 0.50);
    drawWave(path4, 0.14, 1.2);

    final path5 = Path()
      ..moveTo(w * 0.55, h)
      ..cubicTo(w * 0.70, h * 0.75, w * 0.90, h * 0.80, w, h * 0.45);
    drawWave(path5, 0.08, 0.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
