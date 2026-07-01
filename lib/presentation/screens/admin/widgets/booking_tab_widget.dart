import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/booking_model.dart';
import '../../../controllers/admin_controller.dart';

/// A widget representing the Bookings management tab in the Admin panel.
///
/// Responsibilities:
/// - List all active event bookings
/// - Allow modifying booking statuses (Pending, Confirmed, Completed, Cancelled)
/// - Allow toggling payment status (Unpaid, Partial, Paid)
/// - Delete individual bookings with confirmation dialog
class BookingTabWidget extends StatelessWidget {
  final AdminController controller;
  final bool isDark;

  /// Creates a [BookingTabWidget] with specified [controller] and [isDark] theme configuration.
  const BookingTabWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bookings = controller.rxBookings;
      if (bookings.isEmpty) {
        return const Center(child: Text("No bookings registered yet."));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.bookingNumber,
                        style: AppTheme.sansBody(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC8A26A),
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: booking.status,
                            items: const [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text("Pending"),
                              ),
                              DropdownMenuItem(
                                value: 'confirmed',
                                child: Text("Confirmed"),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text("Completed"),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Text("Cancelled"),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                final updated = BookingModel(
                                  id: booking.id,
                                  bookingNumber: booking.bookingNumber,
                                  quotationId: booking.quotationId,
                                  advanceAmount: booking.advanceAmount,
                                  paymentStatus: booking.paymentStatus,
                                  status: val,
                                  createdAt: booking.createdAt,
                                  updatedAt: DateTime.now(),
                                );
                                controller.saveBooking(updated, isEdit: true);
                              }
                            },
                            style: const TextStyle(fontSize: 12),
                            underline: const SizedBox(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed:
                                () =>
                                    _confirmDeleteBooking(context, booking.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Quotation: ${booking.quotationId}",
                    style: AppTheme.sansBody(fontSize: 13),
                  ),
                  Text(
                    "Advance: ${AppFormatters.formatCurrency(booking.advanceAmount)}",
                    style: AppTheme.sansBody(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.payment,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          DropdownButton<String>(
                            value: booking.paymentStatus,
                            items: const [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text("Unpaid"),
                              ),
                              DropdownMenuItem(
                                value: 'partially_paid',
                                child: Text("Partial"),
                              ),
                              DropdownMenuItem(
                                value: 'paid',
                                child: Text("Fully Paid"),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                final updated = BookingModel(
                                  id: booking.id,
                                  bookingNumber: booking.bookingNumber,
                                  quotationId: booking.quotationId,
                                  advanceAmount: booking.advanceAmount,
                                  paymentStatus: val,
                                  status: booking.status,
                                  createdAt: booking.createdAt,
                                  updatedAt: DateTime.now(),
                                );
                                controller.saveBooking(updated, isEdit: true);
                              }
                            },
                            style: const TextStyle(fontSize: 12),
                            underline: const SizedBox(),
                          ),
                        ],
                      ),
                      Text(
                        "Created: ${AppFormatters.formatShortDate(booking.createdAt)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _confirmDeleteBooking(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Booking"),
        content: const Text(
          "Are you sure you want to permanently delete this booking?",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              controller.deleteBooking(id);
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
