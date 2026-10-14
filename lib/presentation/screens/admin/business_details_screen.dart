import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/business_details_controller.dart';
import '../../../domain/entities/business_details_entity.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/luxury_gold_waves_painter.dart';

part 'parts/biz_details_general.dart';
part 'parts/biz_details_contacts.dart';
part 'parts/biz_details_branches.dart';
part 'parts/biz_details_addresses.dart';
part 'parts/biz_details_other.dart';

/// Brand Studio Manager / Business Details Screen matching
/// Option 4 Premium Detailed Style reference design:
/// - Compact 2-panel workspace with background luxury gold wave ribbons
/// - Left navigation rail (215px) with custom gold outline icons and radiant gold active pill
/// - Right form panel with maximum width constraint (~640px) preventing overstretched fields
/// - Clean single-border input design (one single outer outline, continuous dark background,
///   borderless prefix icon, zero nested containers or duplicate borders)
/// - Compact multiline Business Description
/// - Bottom-right aligned glowing gold "SAVE & PUBLISH CMS ➔" button
/// - Full responsive support for Desktop, Tablet, and Mobile
class BusinessDetailsScreen extends GetView<BusinessDetailsController> {
  const BusinessDetailsScreen({super.key});

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _cardBg = Color(0xFF0C1511);
  static const Color _inputBg = Color(0xFF080F0C);
  static const Color _focusGold = Color(0xFFE2B755);

  static const List<Map<String, dynamic>> _tabsData = [
    {"title": "General", "icon": Icons.home_outlined},
    {"title": "Contacts", "icon": Icons.perm_contact_calendar_outlined},
    {"title": "Branches", "icon": Icons.apartment_outlined},
    {"title": "Addresses", "icon": Icons.location_on_outlined},
    {"title": "Social Media", "icon": Icons.bolt_outlined},
    {"title": "Working Hours", "icon": Icons.schedule_outlined},
    {"title": "Bank Details", "icon": Icons.account_balance_outlined},
    {"title": "Legal Details", "icon": Icons.gavel_outlined},
    {"title": "SEO Metadata", "icon": Icons.travel_explore_outlined},
    {"title": "Google Maps", "icon": Icons.map_outlined},
    {"title": "Media Assets", "icon": Icons.perm_media_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isInsideDrawer = AdminLayoutScope.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. Option 4 Luxury Gold Wave Ribbons Background ───────
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LuxuryGoldWavesPainter(),
              ),
            ),
          ),

          // ── 2. Main Content Layer ──────────────────────────────────
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Eyebrow Header: BRAND STUDIO MANAGER ───────────
                  Row(
                    children: [
                      if (!isInsideDrawer) ...[
                        const AdminBackButton(),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        "BRAND STUDIO MANAGER",
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _goldColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Responsive Layout: Left Nav + Form Panel ───────
                  Expanded(
                    child: Obx(() {
                      if (isMobile) {
                        return _buildMobileLayout(context);
                      }
                      return _buildDesktopLayout(context, screenWidth);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop Layout: Side-by-Side Compact Workspace ─────────────────
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final navWidth = screenWidth < 1000 ? 190.0 : 215.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left Navigation Panel (Option 4 Compact Rail) ───────────
        Container(
          width: navWidth,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _goldColor.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _tabsData.length,
              itemBuilder: (context, index) {
                final isSelected = index == controller.selectedIndex.value;
                final tab = _tabsData[index];
                final title = tab["title"] as String;
                final icon = tab["icon"] as IconData;

                return InkWell(
                  onTap: () => controller.selectedIndex.value = index,
                  borderRadius: BorderRadius.circular(9),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFE5A93C), Color(0xFFC88A24)],
                            )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _goldColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 15.5,
                          color: isSelected ? const Color(0xFF0C1410) : _goldColor,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF0C1410) : Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ── Main Form Area (Option 4 Compact Luxury Container) ──────
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            width: screenWidth >= 1050 ? 640 : (screenWidth - navWidth - 64).clamp(320.0, 640.0),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _goldColor.withValues(alpha: 0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Content Form Area (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTabContent(context),
                  ),
                ),

                // Subtle Divider
                const SizedBox(height: 6),
                Divider(
                  height: 14,
                  thickness: 0.8,
                  color: _goldColor.withValues(alpha: 0.22),
                ),
                const SizedBox(height: 4),

                // Footer: SAVE & PUBLISH CMS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSaveButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout: Top Horizontal Tab Bar + Form Panel ─────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Horizontal Scrollable Tab Bar
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _tabsData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final isSelected = index == controller.selectedIndex.value;
              final tab = _tabsData[index];
              final title = tab["title"] as String;
              final icon = tab["icon"] as IconData;

              return InkWell(
                onTap: () => controller.selectedIndex.value = index,
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFE5A93C), Color(0xFFC88A24)],
                          )
                        : null,
                    color: isSelected ? null : _cardBg,
                    borderRadius: BorderRadius.circular(9),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: _goldColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? const Color(0xFF0C1410) : _goldColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0C1410) : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Main Form Panel
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _goldColor.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildTabContent(context),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  height: 14,
                  thickness: 0.8,
                  color: _goldColor.withValues(alpha: 0.22),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: _buildSaveButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Signature Radiant Gold Save Button ─────────────────────────────
  Widget _buildSaveButton() {
    return Obx(() {
      final isSaving = controller.isSaving.value;

      return InkWell(
        onTap: isSaving ? null : () => controller.saveCentralizedDetails(),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF3C456),
                Color(0xFFD89B27),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _goldColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0C1410),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "SAVE & PUBLISH CMS",
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0C1410),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF0C1410),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  // ── Tab Router ─────────────────────────────────────────────────────
  Widget _buildTabContent(BuildContext context) {
    switch (controller.selectedIndex.value) {
      case 0:
        return _buildGeneralTab(controller);
      case 1:
        return _buildContactsTab(context, controller);
      case 2:
        return _buildBranchesTab(context, controller);
      case 3:
        return _buildAddressesTab(context, controller);
      case 4:
        return _buildSocialTab(controller);
      case 5:
        return _buildWorkingHoursTab(controller);
      case 6:
        return _buildBankDetailsTab(controller);
      case 7:
        return _buildLegalTab(controller);
      case 8:
        return _buildSeoTab(controller);
      case 9:
        return _buildMapsTab(controller);
      case 10:
        return _buildMediaTab(context, controller);
      default:
        return const SizedBox();
    }
  }

  // ── Clean Single-Border Input Decoration Helper ────────────────────
  // One continuous dark background, one thin gold border, transparent prefix icon
  static InputDecoration _option4InputDecoration({
    required IconData? icon,
    String? hint,
    bool isMultiline = false,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: _inputBg,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isMultiline ? 9.5 : 8.5,
      ),
      prefixIcon: icon != null
          ? Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 8,
                top: isMultiline ? 8 : 0,
              ),
              child: isMultiline
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 15.5,
                          color: _focusGold,
                        ),
                      ],
                    )
                  : Icon(
                      icon,
                      size: 15.5,
                      color: _focusGold,
                    ),
            )
          : null,
      prefixIconConstraints: BoxConstraints(
        minWidth: 36,
        minHeight: isMultiline ? 24 : 36,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: _goldColor.withValues(alpha: 0.32),
          width: 0.85,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: _goldColor.withValues(alpha: 0.32),
          width: 0.85,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: _focusGold,
          width: 1.2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: _goldColor.withValues(alpha: 0.18),
          width: 0.85,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 0.85,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
        fontSize: 12.5,
        color: Colors.white30,
      ),
    );
  }

  // ── Unified Field Builder: Single Widget, Zero Nested Containers ───
  Widget _field(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    IconData? icon,
    String? hint,
    FormFieldValidator<String>? validator,
  }) {
    final effectiveIcon = _resolveFieldIcon(label, icon);
    final isMultiline = maxLines > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: _goldColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4.5),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            validator: validator,
            cursorColor: _goldColor,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: _option4InputDecoration(
              icon: effectiveIcon,
              hint: hint,
              isMultiline: isMultiline,
            ),
          ),
        ],
      ),
    );
  }

  // ── Field Icon Resolver for Consistent Visual Detail ───────────────
  IconData _resolveFieldIcon(String label, IconData? explicit) {
    if (explicit != null) return explicit;
    final l = label.toLowerCase();
    if (l.contains('business name')) return Icons.storefront_outlined;
    if (l.contains('company')) return Icons.apartment_outlined;
    if (l.contains('tagline')) return Icons.local_offer_outlined;
    if (l.contains('description')) return Icons.description_outlined;
    if (l.contains('owner name')) return Icons.person_outline_rounded;
    if (l.contains('designation') || l.contains('job')) return Icons.work_outline_rounded;
    if (l.contains('year') || l.contains('established')) return Icons.calendar_today_outlined;
    if (l.contains('license')) return Icons.verified_outlined;
    if (l.contains('registration') || l.contains('reg')) return Icons.confirmation_number_outlined;
    if (l.contains('gst') || l.contains('pan') || l.contains('tax') || l.contains('msme')) return Icons.receipt_long_outlined;
    if (l.contains('insta')) return Icons.camera_alt_outlined;
    if (l.contains('web') || l.contains('site') || l.contains('canonical')) return Icons.language_outlined;
    if (l.contains('map') || l.contains('coord')) return Icons.place_outlined;
    if (l.contains('time') || l.contains('hour') || l.contains('day')) return Icons.schedule_outlined;
    if (l.contains('bank name')) return Icons.account_balance_outlined;
    if (l.contains('holder') || l.contains('account name')) return Icons.person_outline;
    if (l.contains('account num') || l.contains('acc')) return Icons.numbers_outlined;
    if (l.contains('ifsc')) return Icons.password_outlined;
    if (l.contains('upi') || l.contains('qr')) return Icons.qr_code_outlined;
    if (l.contains('seo') || l.contains('keyword') || l.contains('title')) return Icons.travel_explore_outlined;
    if (l.contains('logo') || l.contains('cover') || l.contains('favicon') || l.contains('image')) return Icons.image_outlined;
    return Icons.edit_note_outlined;
  }

  // ── Compact Dialog Field with Gold Accent ───────────────────────────
  Widget _dialogField(String label, TextEditingController ctrl, {IconData? icon}) {
    final effectiveIcon = _resolveFieldIcon(label, icon);

    return Padding(
      padding: const EdgeInsets.only(bottom: 11.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: _goldColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            style: GoogleFonts.dmSans(fontSize: 12.5, color: Colors.white),
            cursorColor: _goldColor,
            decoration: _option4InputDecoration(
              icon: effectiveIcon,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to safely extract city details from branch address
extension BranchEntityCity on BranchEntity {
  String get cityText {
    final parts = fullAddress.split(',');
    if (parts.length >= 2) {
      final c = parts[parts.length - 2].trim();
      if (c.isNotEmpty) return c;
    }
    final nameCity = branchName.split('(').first.trim();
    if (nameCity.isNotEmpty && nameCity.length <= 25) {
      return nameCity;
    }
    return 'Office';
  }
}
