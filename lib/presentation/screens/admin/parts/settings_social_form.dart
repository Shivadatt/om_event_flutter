part of '../system_settings_screen.dart';

extension _SettingsSocialFormExtension on _SystemSettingsScreenState {
  Widget _buildSocialForm() {
    final busCurrent = AppConfigService.to.rxBusinessProfile.value;
    final socialLinks = busCurrent.socialLinks;
    final instaKadi = socialLinks['instagram_kadi']?.toString() ?? '';
    final instaThangadh = socialLinks['instagram_thangadh']?.toString() ?? '';
    final website = socialLinks['website']?.toString() ?? '';
    final googleBiz = socialLinks['google_business_profile']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SOCIAL REDIRECT LINKS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF152621),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.share_outlined,
                    color: Color(0xFFC9A77E),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Social Links Managed in Business Details",
                      style: AppTheme.sansBody(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Social links (Instagram Kadi, Instagram Thangadh, Official Website, and Google Business Profile) are authoritatively managed in Business Details to preserve a single source of truth across public redirects, footers, and brand metadata.",
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.launch_outlined, size: 16),
                label: const Text(
                  "OPEN BUSINESS DETAILS (SOCIAL MEDIA)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  if (Get.isRegistered<BusinessDetailsController>()) {
                    Get.find<BusinessDetailsController>().selectedIndex.value =
                        4; // Social Media tab
                  }
                  Get.toNamed(AppRoutes.businessDetails);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          "CURRENT CANONICAL SOCIAL PROFILES (READ-ONLY)",
          style: GoogleFonts.italiana(
            fontSize: 16,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 16),
        _socialReadOnlyTile(
          "Instagram (Kadi)",
          instaKadi,
          Icons.camera_alt_outlined,
        ),
        _socialReadOnlyTile(
          "Instagram (Thangadh)",
          instaThangadh,
          Icons.camera_alt_outlined,
        ),
        _socialReadOnlyTile(
          "Official Website",
          website,
          Icons.language_outlined,
        ),
        _socialReadOnlyTile(
          "Google Business Profile",
          googleBiz,
          Icons.business_outlined,
        ),
      ],
    );
  }

  Widget _socialReadOnlyTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC9A77E), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "Not configured",
                  style: TextStyle(
                    fontSize: 13,
                    color: value.isNotEmpty ? Colors.white : Colors.white38,
                    fontStyle:
                        value.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
