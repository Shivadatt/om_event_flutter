part of '../system_settings_screen.dart';

extension _SettingsBusinessFormExtension on _SystemSettingsScreenState {
  Widget _buildBusinessForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Heading matching Option 4 Reference ───────────────────
        Text(
          "BUSINESS PROFILE",
          style: GoogleFonts.italiana(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE2B755),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "SINGLE SOURCE OF TRUTH (SSOT)",
          style: GoogleFonts.dmSans(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.4,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 14),
          height: 1.5,
          width: 52,
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
        ),

        // ── 2. Information Banner Card (Centrally Managed) ───────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF080F0C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.32),
              width: 0.95,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Glowing Gold Rounded Square with Crown Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3C456), Color(0xFFD89B27)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 26,
                    color: Color(0xFF0C1410),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Centrally Managed in Business Details Studio",
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "To guarantee single source of truth integrity across the public client portal, booking flows, and admin identity (name, company, branding, contact channels, branches, details) is centrally edited in the dedicated Business Details screen.",
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => Get.toNamed(AppRoutes.businessDetails),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF3C456), Color(0xFFD89B27)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.business_center_outlined,
                              size: 13,
                              color: Color(0xFF0C1410),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "OPEN BUSINESS DETAILS STUDIO",
                              style: GoogleFonts.dmSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0C1410),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // ── 3. Current Profile Overview (Read Only) ───────────────────
        Text(
          "CURRENT PROFILE OVERVIEW (READ ONLY)",
          style: GoogleFonts.dmSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF080F0C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
              width: 0.9,
            ),
          ),
          child: Column(
            children: [
              _buildOverviewRow(
                icon: Icons.storefront_outlined,
                label: "Business Name",
                value: _busName.text.isNotEmpty ? _busName.text : "Om Events & Decorators",
              ),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 12, thickness: 0.7),
              _buildOverviewRow(
                icon: Icons.verified_outlined,
                label: "Company Legal Name",
                value: _busCompany.text.isNotEmpty ? _busCompany.text : "Om Events & Decorators",
              ),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 12, thickness: 0.7),
              _buildOverviewRow(
                icon: Icons.mail_outline_rounded,
                label: "Support Email",
                value: _busEmail.text.isNotEmpty ? _busEmail.text : "omeventsanddecorators@gmail.com",
              ),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 12, thickness: 0.7),
              _buildOverviewRow(
                icon: Icons.location_on_outlined,
                label: "Primary Branch",
                value: "${_b1Name.text.isNotEmpty ? _b1Name.text : 'Kadi (Medha)'}${_b1IsPrimary ? ' (Primary)' : ''}",
              ),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 12, thickness: 0.7),
              _buildOverviewRow(
                icon: Icons.apartment_outlined,
                label: "Secondary Branch",
                value: "${_b2Name.text.isNotEmpty ? _b2Name.text : 'Thangadh'}${_b2IsPrimary ? ' (Primary)' : ''}",
              ),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 12, thickness: 0.7),
              _buildOverviewRow(
                icon: Icons.contact_phone_outlined,
                label: "Configured Contacts",
                value: "${_contactNumbers.isNotEmpty ? _contactNumbers.length : 2} registered phone number(s)",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Icon(icon, size: 14.5, color: const Color(0xFFE2B755)),
          const SizedBox(width: 10),
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
