part of '../system_settings_screen.dart';

extension _SettingsFieldsExtension on _SystemSettingsScreenState {
  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4AF37),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4.5),
          TextField(
            controller: controller,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFFD4AF37),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF080F0C),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.32),
                  width: 0.85,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.32),
                  width: 0.85,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: Color(0xFFE2B755),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
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
