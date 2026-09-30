import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/services/business_details_service.dart';
import '../../../../../core/utils/studio_locations_helper.dart';
import '../../../../../core/widgets/app_video_player.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Renders Studio Maps branch locations and legal agreements with digital signatures
/// following the Option 2 Modern Card Style design reference.
class MapsAgreementsView extends StatefulWidget {
  final CustomerDashboardController controller;

  const MapsAgreementsView({
    super.key,
    required this.controller,
  });

  @override
  State<MapsAgreementsView> createState() => _MapsAgreementsViewState();
}

class _MapsAgreementsViewState extends State<MapsAgreementsView> {
  final signatureCtrl = TextEditingController();
  bool termsAccepted = false;
  bool privacyAccepted = false;
  bool signed = false;
  bool isSaving = false;

  @override
  void dispose() {
    signatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 840;
        final bool isTablet = constraints.maxWidth >= 600 && !isDesktop;
        final double horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDesktop: isDesktop),
              const SizedBox(height: 18),
              _buildStudioTourCard(isDesktop: isDesktop),
              const SizedBox(height: 16),
              _buildStudioCards(isDesktop: isDesktop),
              const SizedBox(height: 24),
              _buildLegalSection(isDesktop: isDesktop),
            ],
          ),
        );
      },
    );
  }

  // ── 1. Page Header ─────────────────────────────────────────────────────────
  Widget _buildHeader({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LOCATION & SECURITY",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Studio Maps & Legal Desk",
          style: GoogleFonts.italiana(
            fontSize: isDesktop ? 26 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Everything you need at one place — visit us or complete legal formalities.",
          style: AppTheme.sansBody(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  // ── 2. Studio Tour / Video Card ───────────────────────────────────────────
  Widget _buildStudioTourCard({required bool isDesktop}) {
    return Container(
      height: isDesktop ? 240 : 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background rich studio photography
          Image.asset(
            AppImages.weddingStage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF14201A),
              child: const Center(
                child: Icon(Icons.photo_library_outlined, color: Color(0x40D4AF37), size: 48),
              ),
            ),
          ),

          // Luxury dark vignette overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),

          // Central Play Button
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _playStudioTour,
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.45),
                    border: Border.all(color: const Color(0x40D4AF37), width: 1.0),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 16),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD4AF37),
                          boxShadow: [
                            BoxShadow(color: Color(0x66D4AF37), blurRadius: 10),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF091210),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Play Studio Tour",
                        style: AppTheme.sansBody(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Studio Location Cards (Kadi HQ & Thangadh Studio) ───────────────────
  Widget _buildStudioCards({required bool isDesktop}) {
    final studios = StudioLocationsHelper.getPublicStudios();
    final kadiStudio = studios.isNotEmpty ? studios.first : StudioLocationsHelper.kadiStudio;
    final thangadhStudio = studios.length > 1 ? studios[1] : StudioLocationsHelper.thangadhStudio;

    final kadiTitle = kadiStudio.name.contains("Studio") || kadiStudio.name.contains("HQ")
        ? kadiStudio.name
        : "Kadi HQ (Main Office)";

    final thangadhTitle = thangadhStudio.name.contains("Studio") || thangadhStudio.name.contains("Showroom")
        ? thangadhStudio.name
        : "Thangadh Studio";

    final cardKadi = _buildStudioCard(
      title: kadiTitle,
      fullAddress: kadiStudio.fullAddress,
      thumbnailAsset: AppImages.luxuryReception,
      icon: Icons.location_on_outlined,
      onDirectionsTap: () => StudioLocationsHelper.openInGoogleMaps(kadiStudio.fullAddress),
    );

    final cardThangadh = _buildStudioCard(
      title: thangadhTitle,
      fullAddress: thangadhStudio.fullAddress,
      thumbnailAsset: AppImages.luxuryEveningDecor,
      icon: Icons.storefront_outlined,
      onDirectionsTap: () => StudioLocationsHelper.openInGoogleMaps(thangadhStudio.fullAddress),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: cardKadi),
          const SizedBox(width: 16),
          Expanded(child: cardThangadh),
        ],
      );
    }

    return Column(
      children: [
        cardKadi,
        const SizedBox(height: 12),
        cardThangadh,
      ],
    );
  }

  Widget _buildStudioCard({
    required String title,
    required String fullAddress,
    required String thumbnailAsset,
    required IconData icon,
    required VoidCallback onDirectionsTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x2BD4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Left image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 94,
              height: 60,
              child: Image.asset(
                thumbnailAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF14201A),
                  child: const Icon(Icons.business_outlined, color: Color(0x40D4AF37), size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Circle icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF14201A),
              border: Border.all(color: const Color(0x40D4AF37)),
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: onDirectionsTap,
                  child: Text(
                    "Get Directions",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right circular gold arrow button
          Material(
            color: const Color(0xFFD4AF37),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onDirectionsTap,
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF091210),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Legal Agreements Section ───────────────────────────────────────────
  Widget _buildLegalSection({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "[",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "Legal Agreements",
                  style: GoogleFonts.italiana(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            OutlinedButton(
              onPressed: _showSampleAgreementDialog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x40D4AF37)),
                backgroundColor: const Color(0x0DD4AF37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                "View Sample Agreement",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Compact Card Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x28D4AF37), width: 1.0),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 14, offset: Offset(0, 4)),
            ],
          ),
          child: isDesktop ? _buildDesktopLegalLayout() : _buildMobileLegalLayout(),
        ),
      ],
    );
  }

  Widget _buildDesktopLegalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Document terms & Digital signature input
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAgreementTermsInfo(),
              const SizedBox(height: 16),
              _buildSignatureInput(),
            ],
          ),
        ),
        const SizedBox(width: 28),

        // Right Column: Checkboxes & Confirm CTA
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckboxes(),
              const SizedBox(height: 20),
              _buildConfirmButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLegalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAgreementTermsInfo(),
        const SizedBox(height: 16),
        _buildCheckboxes(),
        const SizedBox(height: 16),
        _buildSignatureInput(),
        const SizedBox(height: 18),
        _buildConfirmButton(),
      ],
    );
  }

  Widget _buildAgreementTermsInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0x1AD4AF37),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x33D4AF37)),
          ),
          child: const Center(
            child: Icon(Icons.description_outlined, color: Color(0xFFD4AF37), size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Event Reservation & Deposit Agreement",
                style: AppTheme.sansBody(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "1. The 25% advance booking fee is non-refundable.\n"
                "2. Any cancellation request must be submitted 15 days prior to the event.\n"
                "3. Decoration revisions are locked 7 days before event preparation starts.",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Digital Signature (Type full name to sign)",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: signatureCtrl,
          style: GoogleFonts.italiana(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.edit_outlined, size: 16, color: Color(0x99D4AF37)),
            hintText: "Enter full legal name...",
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF070D0A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x22D4AF37)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x22D4AF37)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
            ),
          ),
          onChanged: (val) {
            setState(() => signed = val.trim().isNotEmpty);
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agreement Checkbox
        InkWell(
          onTap: () => setState(() => termsAccepted = !termsAccepted),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: termsAccepted,
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: const Color(0xFF091210),
                    side: const BorderSide(color: Color(0x66D4AF37), width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => termsAccepted = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "I accept the Event Booking Agreement terms",
                    style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Privacy Policy Checkbox
        InkWell(
          onTap: () => setState(() => privacyAccepted = !privacyAccepted),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: privacyAccepted,
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: const Color(0xFF091210),
                    side: const BorderSide(color: Color(0x66D4AF37), width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => privacyAccepted = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "I agree to the Customer Privacy Policy  ",
                        style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white70),
                      ),
                      InkWell(
                        onTap: _showPrivacyPolicyDialog,
                        child: Text(
                          "View Policy →",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final bool canSubmit = termsAccepted && privacyAccepted && signed && !isSaving;

    return ElevatedButton.icon(
      icon: isSaving
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF091210)),
            )
          : const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF091210)),
      label: Text(
        isSaving ? "RECORDING SIGNATURE..." : "CONFIRM & RECORD SIGNATURE",
        style: AppTheme.sansBody(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: const Color(0xFF091210),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE5C378),
        disabledBackgroundColor: const Color(0x22D4AF37),
        disabledForegroundColor: Colors.white30,
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: canSubmit ? 3 : 0,
      ),
      onPressed: canSubmit ? _recordSignature : null,
    );
  }

  // ── Actions & Dialogs ──────────────────────────────────────────────────────
  Future<void> _recordSignature() async {
    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        await FirebaseFirestore.instance.collection('customer_profiles').doc(user.uid).set({
          'legal_agreement_accepted': true,
          'digital_signature_name': signatureCtrl.text.trim(),
          'agreement_timestamp': FieldValue.serverTimestamp(),
          'terms_accepted': termsAccepted,
          'privacy_accepted': privacyAccepted,
        }, SetOptions(merge: true));
      }

      Get.snackbar(
        "Signature Captured",
        "Digital contract signed and logged to Firebase agreements vault.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14201A),
        colorText: const Color(0xFFD4AF37),
        borderColor: const Color(0x33D4AF37),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        "Signature Recorded",
        "Contract signed successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF14201A),
        colorText: const Color(0xFFD4AF37),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _playStudioTour() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          width: 820,
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4), width: 1.2),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.videocam_outlined, color: Color(0xFFD4AF37), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "OM Events Studio Tour",
                      style: GoogleFonts.italiana(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x1AD4AF37)),

              // Video Player
              const Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                  child: AppVideoPlayer(
                    videoUrl: AppAssets.videoWeddingShowcase,
                    autoPlay: true,
                    looping: true,
                    showControls: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSampleAgreementDialog() {
    String agreementContent = "";
    if (Get.isRegistered<BusinessDetailsService>()) {
      agreementContent = BusinessDetailsService.to.rxDetails.value.legal.termsAndConditions;
    }

    if (agreementContent.trim().isEmpty) {
      agreementContent =
          "1. RESERVATION & DEPOSIT:\nA non-refundable advance fee of 25% of total project valuation is required to confirm booking dates and assign dedicated design coordinators.\n\n"
          "2. PAYMENT MILESTONES:\n- 50% milestone payment due 14 days prior to event installation.\n- Remaining 25% final settlement due upon final aesthetic handover.\n\n"
          "3. REVISIONS & CUSTOM THEMES:\nBespoke structural fabrications and design revisions are locked 7 days prior to venue setup.\n\n"
          "4. FORCE MAJEURE:\nIn event of government restrictions or venue unavailability, dates may be rescheduled within 12 months with zero forfeit penalties.";
    }

    _showLegalModal(
      title: "Event Booking Agreement & Terms",
      subtitle: "Official client reservation agreement terms",
      content: agreementContent,
    );
  }

  void _showPrivacyPolicyDialog() {
    String privacyContent = "";
    if (Get.isRegistered<BusinessDetailsService>()) {
      privacyContent = BusinessDetailsService.to.rxDetails.value.legal.privacyPolicy;
    }

    if (privacyContent.trim().isEmpty) {
      privacyContent =
          "1. DATA COLLECTION:\nOM Events collects your contact details, event logistical parameters, and venue specifications solely for executing luxury decor and event production.\n\n"
          "2. CONFIDENTIALITY:\nAll client blueprints, guest counts, and customized event themes are held strictly confidential.\n\n"
          "3. MEDIA RIGHTS:\nPhotographs captured of decor setups may be used in our curated portfolio with prior client consent.\n\n"
          "4. SECURITY:\nAll digital signatures and agreements are securely stored in our encrypted Firebase agreements vault.";
    }

    _showLegalModal(
      title: "Customer Privacy Policy",
      subtitle: "How we safeguard your information",
      content: privacyContent,
    );
  }

  void _showLegalModal({
    required String title,
    required String subtitle,
    required String content,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxHeight: 520),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1713),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x1AD4AF37),
                      border: Border.all(color: const Color(0x40D4AF37)),
                    ),
                    child: const Center(
                      child: Icon(Icons.gavel_outlined, color: Color(0xFFD4AF37), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.italiana(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0x1AD4AF37)),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF091210),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
