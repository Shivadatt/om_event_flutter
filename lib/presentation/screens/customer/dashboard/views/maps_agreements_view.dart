import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Renders Maps branch locations and legal agreements with digital signatures.
class MapsAgreementsView extends StatefulWidget {
  final CustomerDashboardController controller;

  const MapsAgreementsView({
    super.key,
    required this.controller,
  });

  @override
  State<MapsAgreementsView> createState() => _MapsAgreementsViewState();
}

class _MapsAgreementsViewState extends State<MapsAgreementsView> {
  final signatureCtrl = TextEditingController();
  bool termsAccepted = false;
  bool privacyAccepted = false;
  bool signed = false;

  @override
  void dispose() {
    signatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Maps & Venues Navigation", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 16),

          // Google Maps location container
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.3)),
            ),
            child: const Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: Color(0xFFC9A77E)),
                      SizedBox(height: 12),
                      Text("Google Maps Integration Active", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Om Events Studio - Kadi Branch", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.navigation, size: 16),
                label: const Text("Navigate to Kadi Branch"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.navigation, size: 16),
                label: const Text("Navigate to Thangadh Branch"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),

          Text("Legal Booking Agreement", style: AppTheme.serifHeader(fontSize: 20)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF12271F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Terms of Booking & Cancellation Rules:\n"
                  "1. The 25% advance booking fee is non-refundable.\n"
                  "2. Any cancellation request must be submitted 15 days prior to the event.\n"
                  "3. Decoration revisions are locked 7 days before event preparation starts.",
                  style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text("I accept the Event Booking Agreement terms", style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: termsAccepted,
                  activeColor: const Color(0xFFC9A77E),
                  onChanged: (val) => setState(() => termsAccepted = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text("I agree to the Customer Privacy Policy", style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: privacyAccepted,
                  activeColor: const Color(0xFFC9A77E),
                  onChanged: (val) => setState(() => privacyAccepted = val ?? false),
                ),
                const SizedBox(height: 16),
                const Text("Digital Signature (Type Full Name to Sign)", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
                TextField(
                  controller: signatureCtrl,
                  decoration: const InputDecoration(hintText: "Enter full legal name..."),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) {
                    setState(() => signed = val.isNotEmpty);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A77E),
                    foregroundColor: const Color(0xFF091210),
                    disabledBackgroundColor: Colors.white12,
                  ),
                  onPressed: (termsAccepted && privacyAccepted && signed)
                      ? () {
                          Get.snackbar("Signed Successfully", "Agreement digital signature captured.");
                        }
                      : null,
                  child: const Text("Confirm & Submit Signature"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
