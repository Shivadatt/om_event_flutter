part of '../business_details_screen.dart';

extension BusinessDetailsOther on BusinessDetailsScreen {
  Widget _tabHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.italiana(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE2B755),
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 14),
          height: 1.5,
          width: 52,
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
        ),
      ],
    );
  }

  // ──── 5. SOCIAL MEDIA TAB ─────────────────────────────────────────────────────
  Widget _buildSocialTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("SOCIAL MEDIA ACCOUNTS"),
        _field("Instagram URL (Kadi Branch)", controller.socialInstaKadiCtrl, icon: Icons.camera_alt_outlined),
        _field("Instagram URL (Thangadh Branch)", controller.socialInstaThangadhCtrl, icon: Icons.camera_alt_outlined),
        _field("Official Website", controller.socialWebCtrl, icon: Icons.language_outlined),
        _field("Google Business Profile Link", controller.socialGoogleBusinessCtrl, icon: Icons.store_mall_directory_outlined),
      ],
    );
  }

  // ──── 6. WORKING HOURS TAB ───────────────────────────────────────────────────
  Widget _buildWorkingHoursTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("WORKING HOURS"),
        _field("Monday Timings", controller.workMondayCtrl, icon: Icons.schedule_outlined),
        _field("Tuesday Timings", controller.workTuesdayCtrl, icon: Icons.schedule_outlined),
        _field("Wednesday Timings", controller.workWednesdayCtrl, icon: Icons.schedule_outlined),
        _field("Thursday Timings", controller.workThursdayCtrl, icon: Icons.schedule_outlined),
        _field("Friday Timings", controller.workFridayCtrl, icon: Icons.schedule_outlined),
        _field("Saturday Timings", controller.workSaturdayCtrl, icon: Icons.schedule_outlined),
        _field("Sunday Timings", controller.workSundayCtrl, icon: Icons.schedule_outlined),
        _field("Holiday Lists & Notes", controller.workHolidayNotesCtrl, maxLines: 2, icon: Icons.event_busy_outlined),
        _field("Emergency Support Hours", controller.workEmergencyHoursCtrl, icon: Icons.support_agent_outlined),
      ],
    );
  }

  // ──── 7. BANK DETAILS TAB ─────────────────────────────────────────────────────
  Widget _buildBankDetailsTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("BANK DETAILS"),
        _field("Bank Name", controller.bankNameCtrl, icon: Icons.account_balance_outlined),
        _field("Account Holder Name", controller.bankHolderCtrl, icon: Icons.person_outline),
        _field("Account Number", controller.bankAccCtrl, icon: Icons.numbers_outlined),
        _field("IFSC Code", controller.bankIfscCtrl, icon: Icons.password_outlined),
        _field("UPI ID", controller.bankUpiCtrl, icon: Icons.qr_code_outlined),
        _field("UPI QR Code Image URL", controller.bankQrCodeCtrl, icon: Icons.image_outlined),
      ],
    );
  }

  // ──── 8. LEGAL DETAILS TAB ────────────────────────────────────────────────────
  Widget _buildLegalTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("LEGAL DOCUMENTS & REGISTRATIONS"),
        _field("GST Registration Number", controller.legalGstCtrl, icon: Icons.receipt_long_outlined),
        _field("PAN Registration Number", controller.legalPanCtrl, icon: Icons.badge_outlined),
        _field("MSME Registration Number", controller.legalMsmeCtrl, icon: Icons.verified_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFFE2B755), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Customer Policies Managed in Policies CMS",
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Customer-facing legal policies (Terms & Conditions, Privacy Policy, Refund Policy, Cancellation Policy, and Booking Policy) are centrally managed in Policies CMS to prevent duplicate and conflicting policy versions.",
                style: GoogleFonts.dmSans(
                  fontSize: 11.5,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2B755),
                  foregroundColor: const Color(0xFF0C1410),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.launch_outlined, size: 14),
                label: Text(
                  "OPEN POLICIES CMS",
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, letterSpacing: 0.8, fontSize: 11),
                ),
                onPressed: () => Get.toNamed(AppRoutes.managePolicies),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──── 9. SEO METADATA TAB ─────────────────────────────────────────────────────
  Widget _buildSeoTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("SEO SPECIFICATIONS"),
        _field("Meta Title", controller.seoTitleCtrl, icon: Icons.title_outlined),
        _field("Meta Description", controller.seoDescCtrl, maxLines: 2, icon: Icons.description_outlined),
        _field("Keywords (comma separated)", controller.seoKeywordsCtrl, icon: Icons.tag_outlined),
        _field("Canonical URL", controller.seoCanonicalCtrl, icon: Icons.link_outlined),
        _field("OpenGraph Share Image URL", controller.seoOgImageCtrl, icon: Icons.image_outlined),
        _field("Twitter Card Image URL", controller.seoTwitterImageCtrl, icon: Icons.image_outlined),
      ],
    );
  }

  // ──── 10. GOOGLE MAPS TAB ─────────────────────────────────────────────────────
  Widget _buildMapsTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("GOOGLE MAPS"),
        _field("Google Maps URL (Default)", controller.mapsUrlCtrl, icon: Icons.map_outlined),
        _field("Coordinates (e.g. 23.3000, 72.3300)", controller.mapsCoordsCtrl, icon: Icons.location_searching_outlined),
        _field("Google Map Embed iframe Code", controller.mapsEmbedCtrl, maxLines: 3, icon: Icons.code_outlined),
      ],
    );
  }

  // ──── 11. MEDIA ASSETS TAB ────────────────────────────────────────────────────
  Widget _buildMediaTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabHeader("MEDIA ASSETS"),
        _field("Business Logo Image URL", controller.logoCtrl, icon: Icons.image_outlined),
        _field("Business Cover Image URL", controller.coverImageCtrl, icon: Icons.panorama_outlined),
        _field("Business Favicon Image URL", controller.faviconCtrl, icon: Icons.star_border_outlined),
        const SizedBox(height: 12),
        Text(
          "MEDIA PREVIEWS",
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: const Color(0xFFE2B755),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _mediaPreviewCard("Logo", controller.logoCtrl),
            const SizedBox(width: 12),
            _mediaPreviewCard("Cover Image", controller.coverImageCtrl),
            const SizedBox(width: 12),
            _mediaPreviewCard("Favicon", controller.faviconCtrl),
          ],
        ),
      ],
    );
  }

  Widget _mediaPreviewCard(String label, TextEditingController ctrl) {
    return Container(
      width: 110,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF080F0C),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.28), width: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1511),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  width: 0.7,
                ),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE2B755),
                letterSpacing: 0.4,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: ctrl,
              builder: (context, value, _) {
                final url = value.text.trim();
                if (url.isEmpty || !url.startsWith("http")) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 20,
                      color: Colors.white24,
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (c, o, s) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
