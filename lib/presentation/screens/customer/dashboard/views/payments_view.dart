import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Payment transactions history and proof uploader view for customers.
class PaymentsView extends StatefulWidget {
  final CustomerDashboardController controller;

  const PaymentsView({
    super.key,
    required this.controller,
  });

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  final payAmountCtrl = TextEditingController();
  String selectedMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payments & Receipts", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF12271F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Submit Offline Payment Proof", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E), fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: payAmountCtrl,
                  decoration: const InputDecoration(labelText: "Amount (INR)", labelStyle: TextStyle(color: Color(0xFFC9A77E))),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  dropdownColor: const Color(0xFF12271F),
                  items: const [
                    DropdownMenuItem(value: 'UPI', child: Text("UPI / NetBanking", style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'Cash', child: Text("Cash", style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'Card', child: Text("Card", style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text("Bank Transfer", style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedMethod = val);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Bank Receipt File"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                  onPressed: () {
                    final amount = double.tryParse(payAmountCtrl.text) ?? 0.0;
                    if (amount > 0) {
                      widget.controller.payOffline(
                        bookingId: 'MOCK_BOOKING_ID',
                        amount: amount,
                        method: selectedMethod,
                        receiptUrl: 'https://placeholder.receipt.url/demo.pdf',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Obx(() {
              if (widget.controller.rxPayments.isEmpty) {
                return const Center(child: Text("No payment transactions logged."));
              }
              return ListView.builder(
                itemCount: widget.controller.rxPayments.length,
                itemBuilder: (context, index) {
                  final payment = widget.controller.rxPayments[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long, color: Color(0xFFC9A77E)),
                      title: Text("Amount: ₹${payment.amount.toStringAsFixed(2)} | Method: ${payment.method}"),
                      subtitle: Text("Status: ${payment.status.toUpperCase()} | Date: ${payment.paymentDate.toLocal().toString().split(' ')[0]}"),
                      trailing: payment.receiptUrl.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.download, color: Color(0xFFC9A77E)),
                              onPressed: () => Get.snackbar("Download Started", "Downloading payment invoice PDF..."),
                            )
                          : null,
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
