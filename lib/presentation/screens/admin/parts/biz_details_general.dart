part of '../business_details_screen.dart';

extension BusinessDetailsGeneral on BusinessDetailsScreen {
  Widget _buildGeneralTab(BusinessDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Heading matching Option 4 Reference ──────────────────────
        Text(
          "GENERAL PROFILE",
          style: GoogleFonts.italiana(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE2B755),
            letterSpacing: 1.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1.5,
          width: 52,
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
        ),

        // ── 1. The 6 Core Reference Fields (Exact Option 4 Match) ───
        _field(
          "Business Name *",
          controller.busNameCtrl,
          icon: Icons.storefront_outlined,
        ),
        _field(
          "Company Name",
          controller.compNameCtrl,
          icon: Icons.apartment_outlined,
        ),
        _field(
          "Business Tagline",
          controller.taglineCtrl,
          icon: Icons.local_offer_outlined,
        ),
        _field(
          "Business Description",
          controller.descCtrl,
          maxLines: 2,
          icon: Icons.description_outlined,
        ),
        _field(
          "Owner Name",
          controller.ownerNameCtrl,
          icon: Icons.person_outline_rounded,
        ),
        _field(
          "Owner Designation",
          controller.ownerDesignationCtrl,
          icon: Icons.work_outline_rounded,
        ),

        // ── 2. Business Registration Details Subsection ─────────────
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              "BUSINESS REGISTRATION DETAILS",
              style: GoogleFonts.dmSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD4AF37),
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Divider(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                thickness: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _field(
          "Established Year",
          controller.estYearCtrl,
          icon: Icons.calendar_today_outlined,
        ),
        _field(
          "Registration Number",
          controller.regNumCtrl,
          icon: Icons.confirmation_number_outlined,
        ),
        _field(
          "GST Number",
          controller.gstNumCtrl,
          icon: Icons.receipt_long_outlined,
        ),
        _field(
          "PAN Number",
          controller.panNumCtrl,
          icon: Icons.badge_outlined,
        ),
        _field(
          "Business License Number",
          controller.licenseNumCtrl,
          icon: Icons.verified_outlined,
        ),
      ],
    );
  }
}
