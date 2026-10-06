part of '../system_settings_screen.dart';

extension _SettingsBusinessFormExtension on _SystemSettingsScreenState {
  Widget _buildBusinessForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BUSINESS PROFILE", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 12),
        Text(
          "SINGLE SOURCE OF TRUTH (SSOT)",
          style: AppTheme.sansBody(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC9A77E),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF152621),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFFC9A77E), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Centrally Managed in Business Details Studio",
                      style: AppTheme.sansBody(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "To guarantee single source of truth integrity across the public client portal, booking flows, and admin studio, business identity (name, company, branding, contact channels, branches, and banking details) is centrally edited in the dedicated Business Details screen.",
                style: AppTheme.sansBody(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A77E),
                  foregroundColor: const Color(0xFF0F1B18),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.business_center_outlined, size: 18),
                label: const Text(
                  "OPEN BUSINESS DETAILS STUDIO",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                onPressed: () => Get.toNamed(AppRoutes.businessDetails),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "CURRENT PROFILE OVERVIEW (READ-ONLY)",
          style: GoogleFonts.italiana(fontSize: 18, color: const Color(0xFFC9A77E)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF101C19),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _buildReadOnlySummaryRow("Business Name", _busName.text.isNotEmpty ? _busName.text : "Om Events & Decorators"),
              const Divider(color: Colors.white10, height: 20),
              _buildReadOnlySummaryRow("Company Legal Name", _busCompany.text.isNotEmpty ? _busCompany.text : "Om Events & Decorators"),
              const Divider(color: Colors.white10, height: 20),
              _buildReadOnlySummaryRow("Support Email", _busEmail.text.isNotEmpty ? _busEmail.text : "omeventsanddecorators@gmail.com"),
              const Divider(color: Colors.white10, height: 20),
              _buildReadOnlySummaryRow(
                "Primary Branch",
                "${_b1Name.text.isNotEmpty ? _b1Name.text : 'Main Office (Kadi)'}${_b1IsPrimary ? ' (Primary)' : ''}",
              ),
              const Divider(color: Colors.white10, height: 20),
              _buildReadOnlySummaryRow(
                "Secondary Branch",
                "${_b2Name.text.isNotEmpty ? _b2Name.text : 'Secondary Office (Thangadh)'}${_b2IsPrimary ? ' (Primary)' : ''}",
              ),
              const Divider(color: Colors.white10, height: 20),
              _buildReadOnlySummaryRow(
                "Configured Contacts",
                "${_contactNumbers.length} registered phone number(s)",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlySummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
