import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Dialog for submitting a new design inquiry from the Client Portal.
class NewInquiryDialog extends StatefulWidget {
  final CustomerDashboardController controller;

  const NewInquiryDialog({super.key, required this.controller});

  @override
  State<NewInquiryDialog> createState() => _NewInquiryDialogState();
}

class _NewInquiryDialogState extends State<NewInquiryDialog> {
  final serviceCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  String selectedBranch = 'Ahmedabad';
  DateTime eventDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    serviceCtrl.dispose();
    budgetCtrl.dispose();
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

  static Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEW DESIGN INQUIRY', style: GoogleFonts.italiana(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('Submit details to consult our curation coordinators', style: AppTheme.sansBody(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 24),
              const Divider(color: Color(0x1AD4AF37), height: 1),
              const SizedBox(height: 24),
              _label('Service Required'),
              const SizedBox(height: 8),
              TextField(
                controller: serviceCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration(hint: 'e.g., Wedding Mandap, Reception Decor', icon: Icons.celebration_outlined),
              ),
              const SizedBox(height: 20),
              _buildBranchAndBudgetRow(),
              const SizedBox(height: 20),
              _label('Target Event Date'),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchAndBudgetRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Branch Location'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF171411),
                initialValue: selectedBranch,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration(hint: 'Select Branch', icon: Icons.business_outlined),
                items: const [
                  DropdownMenuItem(value: 'Ahmedabad', child: Text('Ahmedabad')),
                  DropdownMenuItem(value: 'Kadi', child: Text('Kadi')),
                  DropdownMenuItem(value: 'Thangadh', child: Text('Thangadh')),
                ],
                onChanged: (val) { if (val != null) setState(() => selectedBranch = val); },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Approx. Budget (INR)'),
              const SizedBox(height: 8),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildInputDecoration(hint: 'e.g., 50000', icon: Icons.currency_rupee),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final chosen = await showDatePicker(
          context: context,
          initialDate: eventDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFD4AF37),
                onPrimary: Color(0xFF091210),
                surface: Color(0xFF171411),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (chosen != null) setState(() => eventDate = chosen);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, color: Color(0xFFD4AF37), size: 18),
                const SizedBox(width: 12),
                Text(
                  '--',
                  style: AppTheme.sansBody(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            elevation: 4,
          ),
          onPressed: () {
            final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
            widget.controller.submitLead(service: serviceCtrl.text, branch: selectedBranch, budget: budget, eventDate: eventDate);
            Get.back();
            Get.snackbar(
              'Inquiry Submitted',
              'Your design consultation request has been successfully created.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF171411),
              colorText: const Color(0xFFD4AF37),
            );
          },
          child: const Text('SUBMIT CONSULTATION'),
        ),
      ],
    );
  }
}
