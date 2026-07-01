import 'package:flutter/material.dart';

/// Configurator tab for general business branding options.
class SettingsGeneralTab extends StatelessWidget {
  /// Controller for business name.
  final TextEditingController nameCtrl;

  /// Controller for business tagline.
  final TextEditingController taglineCtrl;

  /// Controller for business description.
  final TextEditingController descriptionCtrl;

  /// Controller for business logo URL.
  final TextEditingController logoUrlCtrl;

  /// Controller for favicon URL.
  final TextEditingController faviconUrlCtrl;

  /// Creates a [SettingsGeneralTab] widget instance.
  const SettingsGeneralTab({
    super.key,
    required this.nameCtrl,
    required this.taglineCtrl,
    required this.descriptionCtrl,
    required this.logoUrlCtrl,
    required this.faviconUrlCtrl,
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
          _buildTextField("BUSINESS NAME", nameCtrl),
          const SizedBox(height: 16),
          _buildTextField("BUSINESS TAGLINE", taglineCtrl),
          const SizedBox(height: 16),
          _buildTextField("COMPANY DESCRIPTION", descriptionCtrl, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField("LOGO PUBLIC URL", logoUrlCtrl),
          const SizedBox(height: 16),
          _buildTextField("FAVICON PUBLIC URL", faviconUrlCtrl),
        ],
      ),
    );
  }
}
