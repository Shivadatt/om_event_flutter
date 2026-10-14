part of '../system_settings_screen.dart';

extension _SettingsSocialFormExtension on _SystemSettingsScreenState {
  Widget _buildSocialForm() {
    return Obx(() {
      // 1. Establish canonical source of truth from BusinessDetailsService (primary SSOT)
      final hasBizService = Get.isRegistered<BusinessDetailsService>();
      final details = hasBizService ? BusinessDetailsService.to.rxDetails.value : BusinessDetailsEntity.defaultVal();
      final busProfile = AppConfigService.to.rxBusinessProfile.value;
      final socialLinks = busProfile.socialLinks;

      // Helper to return first non-empty string
      String firstNonEmpty(List<String?> items) {
        for (final item in items) {
          if (item != null) {
            final trimmed = item.trim();
            if (trimmed.isNotEmpty) return trimmed;
          }
        }
        return '';
      }

      // ── Resolve Instagram (Kadi) ───────────────────────────────────────────
      String instaKadi = '';
      String sourceKadi = 'Not configured';

      // Step A: Canonical Kadi branch record by branch identity
      for (final b in details.branches) {
        final idLower = b.id.toLowerCase();
        final nameLower = b.branchName.toLowerCase();
        final addrLower = b.fullAddress.toLowerCase();
        if (idLower.contains('kadi') || nameLower.contains('kadi') || addrLower.contains('kadi') ||
            idLower.contains('medha') || nameLower.contains('medha') || addrLower.contains('medha')) {
          if (b.instagram.trim().isNotEmpty) {
            instaKadi = b.instagram.trim();
            sourceKadi = 'Branch: ${b.branchName.isNotEmpty ? b.branchName : "Kadi"}';
            break;
          }
        }
      }

      // Step B: Canonical Business Details Social Media editor
      if (instaKadi.isEmpty && details.social.instagramKadi.trim().isNotEmpty) {
        instaKadi = details.social.instagramKadi.trim();
        sourceKadi = 'Business Details (Social)';
      }

      // Step C: AppConfigService / Firestore legacy socialLinks
      if (instaKadi.isEmpty) {
        final legacyKadi = firstNonEmpty([
          socialLinks['instagram_kadi'],
          socialLinks['instagramKadi'],
        ]);
        if (legacyKadi.isNotEmpty) {
          instaKadi = legacyKadi;
          sourceKadi = 'Canonical socialLinks';
        }
      }

      // Step D: OfficeBranches fallback
      if (instaKadi.isEmpty) {
        for (final ob in busProfile.officeBranches) {
          final idLower = ob.id.toLowerCase();
          final nameLower = ob.branchName.toLowerCase();
          final addrLower = ob.address.toLowerCase();
          if (idLower.contains('kadi') || nameLower.contains('kadi') || addrLower.contains('kadi') ||
              idLower.contains('medha') || nameLower.contains('medha') || addrLower.contains('medha')) {
            if (ob.instagram.trim().isNotEmpty) {
              instaKadi = ob.instagram.trim();
              sourceKadi = 'Office Branch: ${ob.branchName}';
              break;
            }
          }
        }
      }

      // ── Resolve Instagram (Thangadh) ───────────────────────────────────────
      String instaThangadh = '';
      String sourceThangadh = 'Not configured';

      // Step A: Canonical Thangadh branch record by branch identity
      for (final b in details.branches) {
        final idLower = b.id.toLowerCase();
        final nameLower = b.branchName.toLowerCase();
        final addrLower = b.fullAddress.toLowerCase();
        if (idLower.contains('thangadh') || nameLower.contains('thangadh') || addrLower.contains('thangadh') ||
            idLower.contains('surajdeval') || nameLower.contains('surajdeval') || addrLower.contains('surajdeval')) {
          if (b.instagram.trim().isNotEmpty) {
            instaThangadh = b.instagram.trim();
            sourceThangadh = 'Branch: ${b.branchName.isNotEmpty ? b.branchName : "Thangadh"}';
            break;
          }
        }
      }

      // Step B: Canonical Business Details Social Media editor
      if (instaThangadh.isEmpty && details.social.instagramThangadh.trim().isNotEmpty) {
        instaThangadh = details.social.instagramThangadh.trim();
        sourceThangadh = 'Business Details (Social)';
      }

      // Step C: AppConfigService / Firestore legacy socialLinks
      if (instaThangadh.isEmpty) {
        final legacyThangadh = firstNonEmpty([
          socialLinks['instagram_thangadh'],
          socialLinks['instagramThangadh'],
        ]);
        if (legacyThangadh.isNotEmpty) {
          instaThangadh = legacyThangadh;
          sourceThangadh = 'Canonical socialLinks';
        }
      }

      // Step D: OfficeBranches fallback
      if (instaThangadh.isEmpty) {
        for (final ob in busProfile.officeBranches) {
          final idLower = ob.id.toLowerCase();
          final nameLower = ob.branchName.toLowerCase();
          final addrLower = ob.address.toLowerCase();
          if (idLower.contains('thangadh') || nameLower.contains('thangadh') || addrLower.contains('thangadh') ||
              idLower.contains('surajdeval') || nameLower.contains('surajdeval') || addrLower.contains('surajdeval')) {
            if (ob.instagram.trim().isNotEmpty) {
              instaThangadh = ob.instagram.trim();
              sourceThangadh = 'Office Branch: ${ob.branchName}';
              break;
            }
          }
        }
      }

      // Step E: Legacy root instagram/instagram_url (assigned to primary business profile)
      if (instaThangadh.isEmpty) {
        final fallbackIg = firstNonEmpty([
          details.social.instagram,
          socialLinks['instagram'],
          socialLinks['instagram_url'],
        ]);
        if (fallbackIg.isNotEmpty) {
          instaThangadh = fallbackIg;
          sourceThangadh = 'Legacy Instagram';
        }
      }

      // ── Resolve Official Website ───────────────────────────────────────────
      String website = '';
      String sourceWebsite = 'Not configured';

      if (details.social.website.trim().isNotEmpty) {
        website = details.social.website.trim();
        sourceWebsite = 'Business Details (Social)';
      } else if (firstNonEmpty([socialLinks['website']]).isNotEmpty) {
        website = firstNonEmpty([socialLinks['website']]);
        sourceWebsite = 'Canonical socialLinks';
      } else if (details.seo.canonicalUrl.trim().isNotEmpty) {
        website = details.seo.canonicalUrl.trim();
        sourceWebsite = 'SEO Canonical URL';
      }

      // ── Resolve Google Business Profile ────────────────────────────────────
      String googleBiz = '';
      String sourceGoogleBiz = 'Not configured';

      if (details.social.googleBusinessProfile.trim().isNotEmpty) {
        googleBiz = details.social.googleBusinessProfile.trim();
        sourceGoogleBiz = 'Business Details (Social)';
      } else {
        final legacyGbp = firstNonEmpty([
          socialLinks['google_business_profile'],
          socialLinks['googleBusinessProfile'],
          socialLinks['google_business'],
        ]);
        if (legacyGbp.isNotEmpty) {
          googleBiz = legacyGbp;
          sourceGoogleBiz = 'Canonical socialLinks';
        }
      }

      // ── Safe, non-sensitive audit log ──────────────────────────────────────
      debugPrint('[SOCIAL_REDIRECTS_AUDIT] doc=settings/business_info '
          'instaKadi="${instaKadi.isNotEmpty ? "CONFIGURED" : "EMPTY"}" source="$sourceKadi" | '
          'instaThangadh="${instaThangadh.isNotEmpty ? "CONFIGURED" : "EMPTY"}" source="$sourceThangadh" | '
          'website="${website.isNotEmpty ? "CONFIGURED" : "EMPTY"}" source="$sourceWebsite" | '
          'googleBiz="${googleBiz.isNotEmpty ? "CONFIGURED" : "EMPTY"}" source="$sourceGoogleBiz"');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SOCIAL REDIRECT LINKS",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 16),

          // Informational Callout Card
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
                      Get.find<BusinessDetailsController>().selectedIndex.value = 4; // Social Media tab
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
            label: "Instagram (Kadi)",
            value: instaKadi,
            sourceLabel: sourceKadi,
            icon: Icons.camera_alt_outlined,
          ),
          _socialReadOnlyTile(
            label: "Instagram (Thangadh)",
            value: instaThangadh,
            sourceLabel: sourceThangadh,
            icon: Icons.camera_alt_outlined,
          ),
          _socialReadOnlyTile(
            label: "Official Website",
            value: website,
            sourceLabel: sourceWebsite,
            icon: Icons.language_outlined,
          ),
          _socialReadOnlyTile(
            label: "Google Business Profile",
            value: googleBiz,
            sourceLabel: sourceGoogleBiz,
            icon: Icons.business_outlined,
          ),
        ],
      );
    });
  }

  Widget _socialReadOnlyTile({
    required String label,
    required String value,
    required String sourceLabel,
    required IconData icon,
  }) {
    final bool isConfigured = value.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConfigured ? const Color(0xFF254235) : const Color(0xFF1F2B26),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFC9A77E), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isConfigured) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A77E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFC9A77E).withValues(alpha: 0.35),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          sourceLabel,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFFE2B755),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                SelectableText(
                  isConfigured ? value : "Not configured",
                  style: TextStyle(
                    fontSize: 13,
                    color: isConfigured ? Colors.white : Colors.white38,
                    fontStyle: isConfigured ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (isConfigured) ...[
            const SizedBox(width: 8),
            // Copy URL action button
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16, color: Color(0xFFC9A77E)),
              tooltip: "Copy URL",
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              splashRadius: 18,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.rawSnackbar(
                  message: "Copied $label URL to clipboard",
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF152621),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
              },
            ),
            const SizedBox(width: 4),
            // Open external URL action button
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 16, color: Color(0xFFC9A77E)),
              tooltip: "Open URL in new tab",
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              splashRadius: 18,
              onPressed: () async {
                final uriString = value.startsWith('http://') || value.startsWith('https://')
                    ? value
                    : 'https://$value';
                if (await canLaunchUrlString(uriString)) {
                  await launchUrlString(uriString, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
