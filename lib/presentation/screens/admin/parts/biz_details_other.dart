part of '../business_details_screen.dart';

extension BusinessDetailsOther on BusinessDetailsScreen {
  // ──── 5. SOCIAL MEDIA TAB ─────────────────────────────────────────────────────
  Widget _buildSocialTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SOCIAL MEDIA ACCOUNTS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Instagram URL (Kadi Branch)", controller.socialInstaKadiCtrl),
        _field("Instagram URL (Thangadh Branch)", controller.socialInstaThangadhCtrl),
        _field("Official Website", controller.socialWebCtrl),
        _field("Google Business Profile Link", controller.socialGoogleBusinessCtrl),
      ],
    );
  }

  // ──── 6. WORKING HOURS TAB ───────────────────────────────────────────────────
  Widget _buildWorkingHoursTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("WORKING HOURS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Monday Timings", controller.workMondayCtrl),
        _field("Tuesday Timings", controller.workTuesdayCtrl),
        _field("Wednesday Timings", controller.workWednesdayCtrl),
        _field("Thursday Timings", controller.workThursdayCtrl),
        _field("Friday Timings", controller.workFridayCtrl),
        _field("Saturday Timings", controller.workSaturdayCtrl),
        _field("Sunday Timings", controller.workSundayCtrl),
        _field("Holiday Lists & Notes", controller.workHolidayNotesCtrl, maxLines: 3),
        _field("Emergency Support Hours", controller.workEmergencyHoursCtrl),
      ],
    );
  }

  // ──── 7. BANK DETAILS TAB ─────────────────────────────────────────────────────
  Widget _buildBankDetailsTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BANK DETAILS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Bank Name", controller.bankNameCtrl),
        _field("Account Holder Name", controller.bankHolderCtrl),
        _field("Account Number", controller.bankAccCtrl),
        _field("IFSC Code", controller.bankIfscCtrl),
        _field("UPI ID", controller.bankUpiCtrl),
        _field("UPI QR Code Image URL", controller.bankQrCodeCtrl),
      ],
    );
  }

  // ──── 8. LEGAL DETAILS TAB ────────────────────────────────────────────────────
  Widget _buildLegalTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("LEGAL DOCUMENTS & POLICIES", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("GST Registration Number", controller.legalGstCtrl),
        _field("PAN Registration Number", controller.legalPanCtrl),
        _field("MSME Registration Number", controller.legalMsmeCtrl),
        _field("Terms & Conditions", controller.legalTermsCtrl, maxLines: 5),
        _field("Privacy Policy", controller.legalPrivacyCtrl, maxLines: 5),
        _field("Refund Policy", controller.legalRefundCtrl, maxLines: 5),
        _field("Cancellation Policy", controller.legalCancellationCtrl, maxLines: 5),
      ],
    );
  }

  // ──── 9. SEO METADATA TAB ─────────────────────────────────────────────────────
  Widget _buildSeoTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEO SPECIFICATIONS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Meta Title", controller.seoTitleCtrl),
        _field("Meta Description", controller.seoDescCtrl, maxLines: 3),
        _field("Keywords (comma separated)", controller.seoKeywordsCtrl),
        _field("Canonical URL", controller.seoCanonicalCtrl),
        _field("OpenGraph Share Image URL", controller.seoOgImageCtrl),
        _field("Twitter Card Image URL", controller.seoTwitterImageCtrl),
      ],
    );
  }

  // ──── 10. GOOGLE MAPS TAB ─────────────────────────────────────────────────────
  Widget _buildMapsTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GOOGLE MAPS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Google Maps URL (Default)", controller.mapsUrlCtrl),
        _field("Coordinates (e.g. 23.3000, 72.3300)", controller.mapsCoordsCtrl),
        _field("Google Map Embed iframe Code", controller.mapsEmbedCtrl, maxLines: 4),
      ],
    );
  }

  // ──── 11. MEDIA ASSETS TAB ────────────────────────────────────────────────────
  Widget _buildMediaTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("MEDIA ASSETS", style: GoogleFonts.italiana(fontSize: 24, color: const Color(0xFFC9A77E))),
        const SizedBox(height: 24),
        _field("Business Logo Image URL", controller.logoCtrl),
        _field("Business Cover Image URL", controller.coverImageCtrl),
        _field("Business Favicon Image URL", controller.faviconCtrl),
        const SizedBox(height: 16),
        const Text("Media Previews", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC9A77E))),
        const SizedBox(height: 12),
        Row(
          children: [
            _mediaPreviewCard("Logo", controller.logoCtrl),
            const SizedBox(width: 16),
            _mediaPreviewCard("Cover Image", controller.coverImageCtrl),
            const SizedBox(width: 16),
            _mediaPreviewCard("Favicon", controller.faviconCtrl),
          ],
        ),
      ],
    );
  }

  Widget _mediaPreviewCard(String label, TextEditingController ctrl) {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF131D1A),
        border: Border.all(color: const Color(0xFF254235)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Obx(() {
              final url = ctrl.text.trim();
              if (url.isEmpty || !url.startsWith("http")) {
                return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey));
              }
              return Image.network(url, fit: BoxFit.contain, errorBuilder: (c, o, s) {
                return const Center(child: Icon(Icons.error_outline, color: Colors.red));
              });
            }),
          ),
        ],
      ),
    );
  }
}
