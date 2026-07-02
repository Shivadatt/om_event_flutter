import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Bookings tracking view for customers.
class BookingsView extends StatelessWidget {
  final CustomerDashboardController controller;
  final Function(String) onRebookPressed;
  final Function(String) onWriteReviewPressed;

  const BookingsView({
    super.key,
    required this.controller,
    required this.onRebookPressed,
    required this.onWriteReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Bookings", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.rxBookings.isEmpty) {
                return Center(
                  child: Text("No active bookings found.", style: AppTheme.sansBody(fontSize: 14, color: Colors.white54)),
                );
              }
              return ListView.builder(
                itemCount: controller.rxBookings.length,
                itemBuilder: (context, index) {
                  final booking = controller.rxBookings[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      iconColor: const Color(0xFFC9A77E),
                      collapsedIconColor: Colors.white70,
                      title: Text(booking.eventName, style: AppTheme.serifHeader(fontSize: 16)),
                      subtitle: Text(
                        "Date: ${booking.date.toLocal().toString().split(' ')[0]} | Package: ${booking.package}",
                        style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                      ),
                      onExpansionChanged: (expanded) {
                        if (expanded) {
                          controller.fetchBookingTimeline(booking.id);
                          controller.fetchBookingGallery(booking.id);
                        }
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Venue: ${booking.venue}", style: AppTheme.sansBody(fontSize: 14)),
                              const SizedBox(height: 8),
                              Text("Total Amount: ₹${booking.amount}", style: AppTheme.sansBody(fontSize: 14)),
                              Text("Advance Paid: ₹${booking.advancePaid}", style: AppTheme.sansBody(fontSize: 14)),
                              Text("Remaining: ₹${booking.remainingAmount}", style: AppTheme.sansBody(fontSize: 14)),
                              const SizedBox(height: 12),
                              Text("Assigned Coordinator: ${booking.assignedContact}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                              const Text("Support Hotline: +91 98765 43210", style: TextStyle(color: Colors.white54, fontSize: 13)),
                              const Divider(color: Colors.white24, height: 24),
                              
                              const Text("Booking Timeline Tracker", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                              const SizedBox(height: 8),
                              Obx(() {
                                if (controller.rxSelectedBookingTimeline.isEmpty) {
                                  return const Text("No timeline checkpoints mapped yet.", style: TextStyle(color: Colors.white54, fontSize: 12));
                                }
                                return Column(
                                  children: controller.rxSelectedBookingTimeline.map((time) {
                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.check_circle_outline, color: Color(0xFFC9A77E), size: 18),
                                      title: Text(time.status, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      subtitle: Text("${time.notes} | ${time.updatedTime.toLocal()}"),
                                    );
                                  }).toList(),
                                );
                              }),
                              const Divider(color: Colors.white24, height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Coordinator: ${booking.assignedContact}", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54)),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E)),
                                        onPressed: () => onRebookPressed(booking.id),
                                        child: const Text("Rebook Event", style: TextStyle(color: Color(0xFF091210))),
                                      ),
                                      const SizedBox(width: 8),
                                      if (booking.status.toLowerCase() == 'completed')
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFC9A77E),
                                            foregroundColor: const Color(0xFF091210),
                                          ),
                                          onPressed: () => onWriteReviewPressed(booking.id),
                                          child: const Text("Write Review"),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
