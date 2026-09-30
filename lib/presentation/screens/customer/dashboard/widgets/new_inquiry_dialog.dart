import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_branches.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Luxury two-panel modal for submitting a new design inquiry matching Option 2 Modern Card Style.
class NewInquiryDialog extends StatefulWidget {
  final CustomerDashboardController controller;
  final VoidCallback? onSuccess;

  const NewInquiryDialog({
    super.key,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<NewInquiryDialog> createState() => _NewInquiryDialogState();
}

class _NewInquiryDialogState extends State<NewInquiryDialog> {
  final serviceCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  String selectedBranch = AppBranches.kadi;
  DateTime? eventDate;
  bool isSubmitting = false;

  @override
  void dispose() {
    serviceCtrl.dispose();
    budgetCtrl.dispose();
    super.dispose();
  }

  static InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: const Color(0xFF09120E),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x22D4AF37)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x22D4AF37)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
      ),
    );
  }

  static Widget _label(String text) {
    return Text(
      text,
      style: AppTheme.sansBody(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFD4AF37),
        letterSpacing: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 740;

          return Container(
            width: 900,
            constraints: const BoxConstraints(maxHeight: 680),
            padding: EdgeInsets.all(isDesktop ? 26 : 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1410),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row (Title on Left, Branding + Close on Right)
                  _buildTopBar(isDesktop: isDesktop),
                  const SizedBox(height: 20),

                  // Main Two-Panel Content or Stacked on Mobile
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Form Panel (approx 58%)
                        Expanded(
                          flex: 58,
                          child: _buildForm(isDesktop: isDesktop),
                        ),
                        const SizedBox(width: 24),

                        // Right Benefits Panel (approx 42%)
                        Expanded(
                          flex: 42,
                          child: _buildRightPanel(),
                        ),
                      ],
                    )
                  else ...[
                    _buildForm(isDesktop: isDesktop),
                    const SizedBox(height: 24),
                    _buildRightPanel(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 1. Top Bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar({required bool isDesktop}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Header Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEW DESIGN INQUIRY',
                style: GoogleFonts.italiana(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share your requirements and our curation team will connect with you.',
                style: AppTheme.sansBody(
                  fontSize: 11.5,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right: Brand Monogram + Close Button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDesktop) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14201A),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33D4AF37), blurRadius: 8),
                  ],
                ),
                child: Center(
                  child: Text(
                    "OE",
                    style: GoogleFonts.italiana(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "OM EVENTS",
                    style: GoogleFonts.italiana(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "AND DECORATORS",
                    style: AppTheme.sansBody(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE5C378),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ],
    );
  }

  // ── 2. Left Form ───────────────────────────────────────────────────────────
  Widget _buildForm({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Required
        _label('SERVICE REQUIRED *'),
        const SizedBox(height: 6),
        TextField(
          controller: serviceCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          decoration: _buildInputDecoration(
            hint: 'e.g. Wedding Mandap, Reception Decor',
            icon: Icons.celebration_outlined,
          ),
        ),
        const SizedBox(height: 16),

        // Branch Location & Approx Budget
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBranchField()),
              const SizedBox(width: 14),
              Expanded(child: _buildBudgetField()),
            ],
          )
        else ...[
          _buildBranchField(),
          const SizedBox(height: 14),
          _buildBudgetField(),
        ],
        const SizedBox(height: 16),

        // Target Event Date
        _label('TARGET EVENT DATE *'),
        const SizedBox(height: 6),
        _buildDatePickerField(),
        const SizedBox(height: 24),

        // Action Buttons (Cancel + Submit Consultation)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildBranchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('BRANCH LOCATION *'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF14201A),
          initialValue: selectedBranch,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD4AF37), size: 18),
          decoration: _buildInputDecoration(
            hint: 'Select Branch',
            icon: Icons.apartment_outlined,
          ),
          items: AppBranches.canonicalBranches.map((b) {
            return DropdownMenuItem(
              value: b,
              child: Text(b, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => selectedBranch = val);
          },
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('APPROX. BUDGET (INR)'),
        const SizedBox(height: 6),
        TextField(
          controller: budgetCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          decoration: _buildInputDecoration(
            hint: 'e.g. 50000',
            icon: Icons.currency_rupee,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    final String dateDisplay = eventDate != null
        ? DateFormat('dd MMM yyyy').format(eventDate!)
        : 'Select event date';

    return InkWell(
      onTap: _pickEventDate,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF09120E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x22D4AF37)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFFD4AF37),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  dateDisplay,
                  style: TextStyle(
                    fontSize: 13,
                    color: eventDate != null ? Colors.white : Colors.white24,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFD4AF37),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickEventDate() async {
    final initial = eventDate ?? DateTime.now().add(const Duration(days: 7));
    final chosen = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            onPrimary: Color(0xFF091210),
            surface: Color(0xFF14201A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (chosen != null) {
      setState(() => eventDate = chosen);
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          flex: 4,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x33D4AF37)),
              backgroundColor: const Color(0x0DD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'CANCEL',
              style: AppTheme.sansBody(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Submit Consultation Button
        Expanded(
          flex: 6,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5C378),
              foregroundColor: const Color(0xFF091210),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
            ),
            onPressed: isSubmitting ? null : _submitInquiry,
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF091210),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SUBMIT CONSULTATION',
                        style: AppTheme.sansBody(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: const Color(0xFF091210),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: Color(0xFF091210),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── 3. Right Benefits Panel ────────────────────────────────────────────────
  Widget _buildRightPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF111915),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Feature: Get Expert Consultation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF18241E),
                  border: Border.all(color: const Color(0x66D4AF37), width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22D4AF37), blurRadius: 10),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.headset_mic_outlined,
                    color: Color(0xFFD4AF37),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Get Expert Consultation",
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE5C378),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Our curation coordinators will help you with the best design ideas.",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x1AD4AF37)),
          const SizedBox(height: 18),

          // Benefit 1: Personalized Suggestions
          _buildBenefitRow(
            icon: Icons.verified_user_outlined,
            title: "Personalized Suggestions",
          ),
          const SizedBox(height: 14),

          // Benefit 2: Exclusive Design Options
          _buildBenefitRow(
            icon: Icons.auto_awesome_outlined,
            title: "Exclusive Design Options",
          ),
          const SizedBox(height: 14),

          // Benefit 3: Quick Response
          _buildBenefitRow(
            icon: Icons.bolt_outlined,
            title: "Quick Response",
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF16211B),
            border: Border.all(color: const Color(0x40D4AF37)),
          ),
          child: Center(
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. Submission Handler ──────────────────────────────────────────────────
  Future<void> _submitInquiry() async {
    if (isSubmitting) return;

    final service = serviceCtrl.text.trim();
    if (service.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter the service or decor style required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
        borderColor: const Color(0x33D4AF37),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (selectedBranch.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select a branch location.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
        borderColor: const Color(0x33D4AF37),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (eventDate == null) {
      Get.snackbar(
        'Required Field',
        'Please select a target event date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: const Color(0xFFD4AF37),
        borderColor: const Color(0x33D4AF37),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final budget = double.tryParse(budgetCtrl.text.trim()) ?? 0.0;

      await widget.controller.submitLead(
        service: service,
        branch: selectedBranch,
        budget: budget,
        eventDate: eventDate!,
      );

      // Only close and navigate after confirmed successful Firestore write
      Get.back();
      widget.onSuccess?.call();

      Get.snackbar(
        'Inquiry Submitted',
        'Your design inquiry has been submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14201A),
        colorText: const Color(0xFFD4AF37),
        borderColor: const Color(0x33D4AF37),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      // Modal remains open on error, allowing user to retry
      Get.snackbar(
        'Submission Error',
        'Failed to submit inquiry. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF171411),
        colorText: Colors.redAccent,
        borderColor: const Color(0x33EF4444),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }
}
