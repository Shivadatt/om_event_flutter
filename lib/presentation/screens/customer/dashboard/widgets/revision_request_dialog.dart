import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Dialog for requesting revision on a quotation from the Client Portal.
class RevisionRequestDialog extends StatefulWidget {
  final String quoteId;
  final CustomerDashboardController controller;

  const RevisionRequestDialog({super.key, required this.quoteId, required this.controller});

  @override
  State<RevisionRequestDialog> createState() => _RevisionRequestDialogState();
}

class _RevisionRequestDialogState extends State<RevisionRequestDialog> {
  final revisionCtrl = TextEditingController();

  @override
  void dispose() {
    revisionCtrl.dispose();
    super.dispose();
  }

  static InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D1916), Color(0xFF0F0D0C)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REQUEST REVISION',
              style: GoogleFonts.italiana(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text('Describe any modifications required for this quotation proposal', style: AppTheme.sansBody(fontSize: 11, color: Colors.white54)),
            const SizedBox(height: 24),
            const Divider(color: Color(0x1AD4AF37), height: 1),
            const SizedBox(height: 24),
            Text(
              'REVISION DETAILS',
              style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: revisionCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hint: 'Describe colors, specific changes, prop items, or timeline modifications...',
                icon: Icons.edit_note,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('CANCEL', style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.0)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF091210),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
                    elevation: 4,
                  ),
                  onPressed: () {
                    widget.controller.requestRevision(widget.quoteId, revisionCtrl.text);
                    Get.back();
                    Get.snackbar(
                      'Revision Requested',
                      'Your feedback was submitted to the design coordinators.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF171411),
                      colorText: const Color(0xFFD4AF37),
                    );
                  },
                  child: const Text('SUBMIT REQUEST'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
