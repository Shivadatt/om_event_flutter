import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/payment_model.dart';
import '../../../controllers/admin_controller.dart';

class AddPaymentDialog extends StatelessWidget {
  final AdminController controller;

  const AddPaymentDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bookingIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    String providerVal = 'cash';
    String statusVal = 'captured';

    return AlertDialog(
      title: const Text("Add Manual Payment"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bookingIdCtrl,
              decoration: const InputDecoration(
                labelText: "Booking Number / ID",
              ),
            ),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: "Amount (Rs.)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: refCtrl,
              decoration: const InputDecoration(
                labelText: "Payment Reference ID (Optional)",
              ),
            ),
            DropdownButtonFormField<String>(
              value: providerVal,
              decoration: const InputDecoration(labelText: "Provider"),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text("Cash")),
                DropdownMenuItem(value: 'upi', child: Text("UPI")),
                DropdownMenuItem(value: 'razorpay', child: Text("Razorpay")),
              ],
              onChanged: (val) {
                if (val != null) providerVal = val;
              },
            ),
            DropdownButtonFormField<String>(
              value: statusVal,
              decoration: const InputDecoration(labelText: "Status"),
              items: const [
                DropdownMenuItem(value: 'captured', child: Text("Captured")),
                DropdownMenuItem(value: 'pending', child: Text("Pending")),
                DropdownMenuItem(value: 'failed', child: Text("Failed")),
              ],
              onChanged: (val) {
                if (val != null) statusVal = val;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            final bookingId = bookingIdCtrl.text.trim();
            final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
            final ref = refCtrl.text.trim();
            if (bookingId.isEmpty || amount <= 0) {
              Get.snackbar("Error", "Please fill valid Booking ID and Amount.");
              return;
            }

            final newPayment = PaymentModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              bookingId: bookingId,
              provider: providerVal,
              reference:
                  ref.isEmpty
                      ? 'MANUAL_${DateTime.now().millisecondsSinceEpoch}'
                      : ref,
              amount: amount,
              status: statusVal,
              paidAt: DateTime.now(),
              createdAt: DateTime.now(),
            );

            controller.savePayment(newPayment, isEdit: false);
            Get.back();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
