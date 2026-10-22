import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import 'contact_inquiry_form_fields.dart';

class ContactInquiryFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final String selectedEventType;
  final List<String> eventTypes;
  final ValueChanged<String?> onEventTypeChanged;
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final Color goldColor;
  final bool isMobile;

  const ContactInquiryFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.messageController,
    required this.selectedEventType,
    required this.eventTypes,
    required this.onEventTypeChanged,
    required this.selectedDate,
    required this.onSelectDate,
    required this.isSubmitting,
    required this.onSubmit,
    required this.goldColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF091410),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldColor.withValues(alpha: 0.30),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    size: 16,
                    color: goldColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "SEND US AN INQUIRY",
                  style: GoogleFonts.italiana(
                    fontSize: isMobile ? 17 : 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Share your event vision and our lead stylists will prepare a consultation.",
              style: AppTheme.sansBody(
                fontSize: isMobile ? 11 : 11.5,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 18),

            ContactInquiryFormFields(
              nameController: nameController,
              phoneController: phoneController,
              emailController: emailController,
              messageController: messageController,
              selectedEventType: selectedEventType,
              eventTypes: eventTypes,
              onEventTypeChanged: onEventTypeChanged,
              selectedDate: selectedDate,
              onSelectDate: onSelectDate,
              goldColor: goldColor,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE5C378),
                      Color(0xFFD4AF37),
                      Color(0xFFC59D2E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(23),
                    onTap: isSubmitting ? null : onSubmit,
                    child: Center(
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF091210),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.send_rounded,
                                  size: 14,
                                  color: Color(0xFF091210),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "SUBMIT INQUIRY",
                                  style: AppTheme.sansBody(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: const Color(0xFF091210),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
