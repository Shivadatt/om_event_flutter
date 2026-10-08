import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/services/booking_availability_service.dart';
import '../../../../../core/utils/booking_status_helper.dart';
import '../../../../../domain/entities/quotation.dart';
import '../../../../controllers/admin_booking_controller.dart';

class AdminCalendarWidget extends StatelessWidget {
  const AdminCalendarWidget({super.key});

  static const Color goldColor = Color(0xFFECC24A);
  static const Color pendingColor = Color(0xFFF59E0B);
  static const Color cardBg = Color(0xFF0C1914);
  static const Color cellAvailableBg = Color(0xFF0A1712);
  static const Color cellBorderColor = Color(0xFF162B22);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminBookingController>();

    return Obx(() {
      final currentMonth = controller.selectedCalendarMonth.value;
      final selectedDate = controller.selectedCalendarDate.value;
      final bookingsMap = controller.bookingsByDateMap;

      final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
      final firstDayWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
      final paddingDays = firstDayWeekday - 1;

      final monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Month Header ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    controller.selectedCalendarMonth.value =
                        DateTime(currentMonth.year, currentMonth.month - 1, 1);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 22,
                      color: goldColor.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                Text(
                  "${monthNames[currentMonth.month - 1]} ${currentMonth.year}".toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    letterSpacing: 1.5,
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.selectedCalendarMonth.value =
                        DateTime(currentMonth.year, currentMonth.month + 1, 1);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: goldColor.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Weekday Labels (MON - SUN) ─────────────────────────────
            Row(
              children: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // ── Day Cells Grid ─────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final double totalWidth = constraints.maxWidth;
                final double cellWidth = (totalWidth - (6 * 8)) / 7;
                // Compact height targeting 52px on desktop and 44px on mobile
                final double targetHeight = totalWidth > 500 ? 52.0 : 44.0;
                final double aspectRatio = (cellWidth / targetHeight).clamp(1.0, 1.6);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paddingDays + daysInMonth,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: aspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    if (index < paddingDays) {
                      return const SizedBox.shrink();
                    }

                    final dayNum = index - paddingDays + 1;
                    final cellDate = DateTime(currentMonth.year, currentMonth.month, dayNum);
                    final dateKey = BookingAvailabilityService.normalizeDateString(cellDate);

                    final booking = bookingsMap[dateKey] ??
                        controller.rxAllBookings.firstWhereOrNull((b) {
                          if (b.status == QuotationStatus.cancelled ||
                              b.status == QuotationStatus.rejectedByClient) {
                            return false;
                          }
                          final ist = BookingAvailabilityService.toIst(b.eventDate);
                          return ist.year == cellDate.year &&
                              ist.month == cellDate.month &&
                              ist.day == cellDate.day;
                        });

                    final bool isPast = BookingStatusHelper.isEventDatePassed(cellDate);
                    final now = DateTime.now();
                    final bool isToday = cellDate.year == now.year &&
                        cellDate.month == now.month &&
                        cellDate.day == now.day;

                    final bool isSelected = !isPast &&
                        selectedDate != null &&
                        selectedDate.year == cellDate.year &&
                        selectedDate.month == cellDate.month &&
                        selectedDate.day == cellDate.day;

                    final bool isConfirmed = !isPast &&
                        booking != null &&
                        (booking.status == QuotationStatus.bookingConfirmed ||
                            booking.status == QuotationStatus.acceptedByClient ||
                            booking.status == QuotationStatus.inProgress ||
                            booking.status == QuotationStatus.completed);

                    final bool isPending = !isPast && booking != null && !isConfirmed;

                    // Compute cell styling based on state
                    Color cellBg;
                    Color cellBorder;
                    Color textColor;

                    if (isPast) {
                      // Visually disabled / past date cell
                      cellBg = const Color(0xFF070F0C);
                      cellBorder = const Color(0xFF101D17);
                      textColor = Colors.white24;
                    } else if (isSelected) {
                      cellBg = goldColor.withValues(alpha: 0.14);
                      cellBorder = goldColor;
                      textColor = goldColor;
                    } else if (isConfirmed) {
                      cellBg = const Color(0xFF0F1E18);
                      cellBorder = goldColor.withValues(alpha: 0.35);
                      textColor = goldColor;
                    } else if (isPending) {
                      cellBg = const Color(0xFF0F1E18);
                      cellBorder = pendingColor.withValues(alpha: 0.35);
                      textColor = Colors.white;
                    } else if (isToday) {
                      // Distinct current date styling
                      cellBg = const Color(0xFF0E1F18);
                      cellBorder = goldColor.withValues(alpha: 0.35);
                      textColor = Colors.white;
                    } else {
                      cellBg = cellAvailableBg;
                      cellBorder = cellBorderColor;
                      textColor = Colors.white70;
                    }

                    return InkWell(
                      onTap: isPast
                          ? null
                          : () {
                              controller.selectedCalendarDate.value = cellDate;
                            },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: isPast ? Colors.transparent : null,
                      highlightColor: isPast ? Colors.transparent : null,
                      hoverColor: isPast ? Colors.transparent : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cellBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: cellBorder,
                            width: isSelected ? 1.8 : 0.9,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: goldColor.withValues(alpha: 0.20),
                                    blurRadius: 8,
                                    spreadRadius: 0.5,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNum.toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : (isToday ? FontWeight.bold : FontWeight.w600),
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (!isPast && isConfirmed)
                              Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: goldColor,
                                ),
                              )
                            else if (!isPast && isPending)
                              Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: pendingColor,
                                ),
                              )
                            else
                              const SizedBox(height: 5.5),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
