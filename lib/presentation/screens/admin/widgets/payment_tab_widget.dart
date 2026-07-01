import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../controllers/admin_controller.dart';
import 'add_payment_dialog.dart';

/// A widget representing the Payments management tab in the Admin panel.
///
/// Responsibilities:
/// - List all active payment records
/// - Allow creating manual payment records via a Floating Action Button
/// - Delete individual payment transaction records
class PaymentTabWidget extends StatelessWidget {
  final AdminController controller;
  final bool isDark;

  /// Creates a [PaymentTabWidget] with specified [controller] and [isDark] theme configuration.
  const PaymentTabWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC8A26A),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => Get.dialog(AddPaymentDialog(controller: controller)),
      ),
      body: Obx(() {
        final payments = controller.rxPayments;
        if (payments.isEmpty) {
          return const Center(child: Text("No payments registered yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
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
                          "Ref: ${payment.reference.isEmpty ? 'N/A' : payment.reference}",
                          style: AppTheme.sansBody(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC8A26A),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    payment.status == 'captured'
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                payment.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      payment.status == 'captured'
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed:
                                  () => _confirmDeletePayment(
                                    context,
                                    payment.id,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Booking Number: ${payment.bookingId}",
                      style: AppTheme.sansBody(fontSize: 13),
                    ),
                    Text(
                      "Amount: ${AppFormatters.formatCurrency(payment.amount)}",
                      style: AppTheme.sansBody(fontSize: 13),
                    ),
                    Text(
                      "Provider: ${payment.provider.toUpperCase()}",
                      style: AppTheme.sansBody(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Paid At: ${payment.paidAt != null ? AppFormatters.formatShortDate(payment.paidAt!) : 'N/A'}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Created: ${AppFormatters.formatShortDate(payment.createdAt)}",
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
      }),
    );
  }

  void _confirmDeletePayment(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Payment"),
        content: const Text(
          "Are you sure you want to permanently delete this payment transaction?",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              controller.deletePayment(id);
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
