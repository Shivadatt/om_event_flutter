import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import 'contact_inquiry_event_selectors.dart';

class ContactInquiryFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final String selectedEventType;
  final List<String> eventTypes;
  final ValueChanged<String?> onEventTypeChanged;
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final Color goldColor;

  const ContactInquiryFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.messageController,
    required this.selectedEventType,
    required this.eventTypes,
    required this.onEventTypeChanged,
    required this.selectedDate,
    required this.onSelectDate,
    required this.goldColor,
  });

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        text,
        style: AppTheme.sansBody(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: goldColor,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
      prefixIcon: Icon(icon, size: 16, color: goldColor.withValues(alpha: 0.75)),
      filled: true,
      fillColor: const Color(0xFF071410),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: goldColor, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("FULL NAME *"),
        TextFormField(
          controller: nameController,
          style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
          validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your full name." : null,
          decoration: _inputDecoration("e.g. Priyaben Patel", Icons.person_outline),
        ),
        const SizedBox(height: 12),

        _buildFieldLabel("PHONE NUMBER * (10 DIGITS)"),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Please enter your phone number.";
            final clean = v.replaceAll(RegExp(r'\D'), '');
            if (clean.length < 10) return "Please enter a valid 10-digit phone number.";
            return null;
          },
          decoration: _inputDecoration("e.g. 9876543210", Icons.phone_outlined),
        ),
        const SizedBox(height: 12),

        _buildFieldLabel("EMAIL ADDRESS (OPTIONAL)"),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
          validator: (v) {
            if (v != null && v.trim().isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(v.trim())) return "Please enter a valid email address.";
            }
            return null;
          },
          decoration: _inputDecoration("e.g. priya@gmail.com", Icons.email_outlined),
        ),
        const SizedBox(height: 12),

        ContactInquiryEventSelectors(
          selectedEventType: selectedEventType,
          eventTypes: eventTypes,
          onEventTypeChanged: onEventTypeChanged,
          selectedDate: selectedDate,
          onSelectDate: onSelectDate,
          goldColor: goldColor,
        ),
        const SizedBox(height: 12),

        _buildFieldLabel("MESSAGE / SPECIAL REQUIREMENTS *"),
        TextFormField(
          controller: messageController,
          maxLines: 4,
          maxLength: 500,
          style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Please enter your message.";
            if (v.trim().length < 10) return "Message must be at least 10 characters.";
            return null;
          },
          decoration: InputDecoration(
            hintText: "Tell us about your venue, theme preferences, special requests...",
            hintStyle: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
            prefixIcon: const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 50),
              child: Icon(Icons.chat_outlined, size: 16, color: AppColors.secondaryAccent),
            ),
            filled: true,
            fillColor: const Color(0xFF071410),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: goldColor.withValues(alpha: 0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: goldColor, width: 1.2),
            ),
            counterStyle: AppTheme.sansBody(fontSize: 9.5, color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
