import 'package:flutter/material.dart';
import 'contact_inquiry_form_card.dart';
import 'contact_inquiry_success_card.dart';

class ContactInquirySection extends StatelessWidget {
  final bool isSuccess;
  final VoidCallback onReset;
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

  const ContactInquirySection({
    super.key,
    required this.isSuccess,
    required this.onReset,
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
    if (isSuccess) {
      return ContactInquirySuccessCard(
        goldColor: goldColor,
        isMobile: isMobile,
        onReset: onReset,
      );
    }

    return ContactInquiryFormCard(
      formKey: formKey,
      nameController: nameController,
      phoneController: phoneController,
      emailController: emailController,
      messageController: messageController,
      selectedEventType: selectedEventType,
      eventTypes: eventTypes,
      onEventTypeChanged: onEventTypeChanged,
      selectedDate: selectedDate,
      onSelectDate: onSelectDate,
      isSubmitting: isSubmitting,
      onSubmit: onSubmit,
      goldColor: goldColor,
      isMobile: isMobile,
    );
  }
}
