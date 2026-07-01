import 'package:flutter/material.dart';

/// Configurator tab for managing company Instagram handles and profile URLs.
class SettingsSocialTab extends StatelessWidget {
  /// Controller for primary Instagram URL.
  final TextEditingController instagramCtrl;

  /// Controller for Kadi Branch Instagram URL.
  final TextEditingController instagramKadiCtrl;

  /// Controller for Thangadh Branch Instagram URL.
  final TextEditingController instagramThangadhCtrl;

  /// Creates a [SettingsSocialTab] widget instance.
  const SettingsSocialTab({
    super.key,
    required this.instagramCtrl,
    required this.instagramKadiCtrl,
    required this.instagramThangadhCtrl,
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
          _buildTextField("MAIN INSTAGRAM URL", instagramCtrl),
          const SizedBox(height: 16),
          _buildTextField("INSTAGRAM KADI BRANCH", instagramKadiCtrl),
          const SizedBox(height: 16),
          _buildTextField("INSTAGRAM THANGADH BRANCH", instagramThangadhCtrl),
        ],
      ),
    );
  }
}
