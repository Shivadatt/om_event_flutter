import 'package:flutter/material.dart';

/// Configurator tab for managing company phone numbers and customer emails.
class SettingsContactTab extends StatelessWidget {
  /// Controller for support email address.
  final TextEditingController supportEmailCtrl;

  /// Controller for primary contact phone.
  final TextEditingController phone1Ctrl;

  /// Controller for secondary contact phone.
  final TextEditingController phone2Ctrl;

  /// Controller for whatsapp number.
  final TextEditingController whatsappCtrl;

  /// Controller for emergency direct line.
  final TextEditingController emergencyPhoneCtrl;

  /// Creates a [SettingsContactTab] widget instance.
  const SettingsContactTab({
    super.key,
    required this.supportEmailCtrl,
    required this.phone1Ctrl,
    required this.phone2Ctrl,
    required this.whatsappCtrl,
    required this.emergencyPhoneCtrl,
  });

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC8A26A),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFFF4F4F4)),
          decoration: const InputDecoration(
            fillColor: Color(0xFF0D1915),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF254235)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC8A26A)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("SUPPORT EMAIL", supportEmailCtrl),
          const SizedBox(height: 16),
          _buildTextField("PRIMARY PHONE", phone1Ctrl),
          const SizedBox(height: 16),
          _buildTextField("SECONDARY PHONE", phone2Ctrl),
          const SizedBox(height: 16),
          _buildTextField("WHATSAPP INQUIRY NUMBER", whatsappCtrl),
          const SizedBox(height: 16),
          _buildTextField("EMERGENCY DIRECT CONTACT", emergencyPhoneCtrl),
        ],
      ),
    );
  }
}
