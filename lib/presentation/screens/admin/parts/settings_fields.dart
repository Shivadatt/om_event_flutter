part of '../system_settings_screen.dart';

extension _SettingsFieldsExtension on _SystemSettingsScreenState {
  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: AppTheme.sansBody(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.sansBody(fontSize: 12),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _jsonField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.italiana(
            fontSize: 18,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 15,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            fillColor: const Color(0xFF131D1A),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF254235)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            try {
              jsonDecode(value);
              return null;
            } catch (e) {
              return "Invalid JSON syntax: $e";
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
