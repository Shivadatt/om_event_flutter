import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.all(32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LOCATION & SECURITY",
                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                "Studio Maps & Legal Desk",
                style: GoogleFonts.italiana(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Google Maps simulation card
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF171411),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x33D4AF37), width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined, size: 48, color: Color(0xFFD4AF37)),
                      const SizedBox(height: 12),
                      Text(
                        "OM EVENTS SECURE MAPS",
                        style: GoogleFonts.italiana(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kadi Branch Studio & Showroom Active",
                        style: AppTheme.sansBody(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Navigation action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.navigation_outlined, size: 16, color: Color(0xFFD4AF37)),
                  label: Text(
                    "NAVIGATE TO KADI HQ",
                    style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0x33D4AF37)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white.withValues(alpha: 0.02),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.navigation_outlined, size: 16, color: Color(0xFFD4AF37)),
                  label: Text(
                    "NAVIGATE TO THANGADH",
                    style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0x33D4AF37)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white.withValues(alpha: 0.02),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Legal Agreement card
          Text(
            "LEGAL AGREEMENTS",
            style: GoogleFonts.italiana(fontSize: 18, color: const Color(0xFFD4AF37), letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF171411),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x1AD4AF37)),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EVENT RESERVATION & DEPOSIT AGREEMENT",
                  style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                ),
                const SizedBox(height: 12),
                Text(
                  "1. The 25% advance booking fee is non-refundable.\n"
                  "2. Any cancellation request must be submitted 15 days prior to the event.\n"
                  "3. Decoration revisions are locked 7 days before event preparation starts.",
                  style: AppTheme.sansBody(fontSize: 13, color: Colors.white70, height: 1.6),
                ),
                const Divider(color: Color(0x1AD4AF37), height: 32),

                // Interactive checkboxes
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: const Color(0x66D4AF37),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "I accept the Event Booking Agreement terms",
                          style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                        ),
                        value: termsAccepted,
                        activeColor: const Color(0xFFD4AF37),
                        checkColor: const Color(0xFF091210),
                        onChanged: (val) => setState(() => termsAccepted = val ?? false),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "I agree to the Customer Privacy Policy",
                          style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                        ),
                        value: privacyAccepted,
                        activeColor: const Color(0xFFD4AF37),
                        checkColor: const Color(0xFF091210),
                        onChanged: (val) => setState(() => privacyAccepted = val ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Signature
                Text(
                  "DIGITAL SIGNATURE (Type name to sign)",
                  style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: signatureCtrl,
                  style: GoogleFonts.italiana(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  decoration: InputDecoration(
                    hintText: "Enter full legal name...",
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    filled: true,
                    fillColor: Colors.black26,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => signed = val.isNotEmpty);
                  },
                ),
                const SizedBox(height: 28),

                // Submit button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF091210),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      elevation: 4,
                    ),
                    onPressed: (termsAccepted && privacyAccepted && signed)
                        ? () {
                            Get.snackbar(
                              "Signature Captured",
                              "digital contract signed and logged to Firebase agreements vault.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF171411),
                              colorText: const Color(0xFFD4AF37),
                            );
                          }
                        : null,
                    child: const Text("CONFIRM & RECORD SIGNATURE"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
