import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/utils/studio_locations_helper.dart';
import '../../../../domain/entities/experience.dart';
import '../../../controllers/catalog_controller.dart';
import '../widgets/booking_tracker_dialog.dart';
import '../widgets/customer_booking_dialog.dart';

class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  final TextEditingController _pincodeCtrl = TextEditingController();
  Map<String, dynamic>? _checkResult;

  @override
  void dispose() {
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _checkCoverage([String? overrideQuery]) {
    final query = (overrideQuery ?? _pincodeCtrl.text).trim().toLowerCase();
    if (query.isEmpty) return;

    if (overrideQuery != null) {
      _pincodeCtrl.text = overrideQuery;
    }

    // ZONE 1: Primary Delivery Hubs
    if (query.contains('kadi') ||
        query == '382715' ||
        query.contains('kalol') ||
        query == '382721' ||
        query.contains('mehsana') ||
        query.startsWith('3840') ||
        query.contains('nandasan') ||
        query == '382725' ||
        query.contains('ahmedabad') ||
        query.startsWith('380') ||
        query.contains('gandhinagar') ||
        query.startsWith('3820')) {
      setState(() {
        _checkResult = {
          'zone': 'Zone 1: Primary Delivery Hubs',
          'status': 'FULL SERVICE GUARANTEED',
          'color': const Color(0xFF4EBA7A),
          'fee': '₹500 standard delivery / Complimentary on luxury packages',
          'leadTime': '7 Days Standard Advance Notice',
          'details': 'Direct coverage from our Kadi Showroom & Studio and Ahmedabad operations hub. Full stage setups, bespoke decor, and dedicated on-site supervisors are guaranteed.',
        };
      });
      return;
    }

    // ZONE 2: Extended Gujarat Districts
    if (query.contains('sanand') ||
        query == '382110' ||
        query.contains('bavla') ||
        query == '382220' ||
        query.contains('viramgam') ||
        query == '382150' ||
        query.contains('himatnagar') ||
        query == '383001' ||
        query.contains('vijapur') ||
        query == '382870' ||
        query.contains('unjha') ||
        query == '384170' ||
        query.contains('patan') ||
        query.startsWith('3842') ||
        query.contains('surendranagar') ||
        query == '363001' ||
        query.contains('thangadh') ||
        query == '363530' ||
        query.contains('chotila') ||
        query == '363520' ||
        query.contains('wadhwan') ||
        query == '363030' ||
        query.contains('rajkot') ||
        query.startsWith('360')) {
      setState(() {
        _checkResult = {
          'zone': 'Zone 2: Extended Gujarat Districts',
          'status': 'EXTENDED COVERAGE GUARANTEED',
          'color': const Color(0xFFE2C074),
          'fee': 'Nominal travel allowance (₹15/km or flat outstation allowance)',
          'leadTime': '7-10 Days Advance Notice',
          'details': 'Serviced directly via our Thangadh Creative Base and regional deployment teams. Seamless equipment transport and dedicated on-site crew coordination.',
        };
      });
      return;
    }

    // ZONE 3: Royal Heritage & Destinations
    setState(() {
      _checkResult = {
        'zone': 'Zone 3: Royal Heritage & Destinations',
        'status': 'BESPOKE OUTSTATION BOOKING',
        'color': const Color(0xFF64B5F6),
        'fee': 'Custom logistics & accommodation quoted upon request',
        'leadTime': '15-30 Days Advance Notice',
        'details': 'For royal destinations, palaces, and heritage venues across Gujarat, Rajasthan, and beyond (Udaipur, Mount Abu, Surat, Bhavnagar, Jamnagar), custom logistics and accommodation are quoted upon request.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF060D0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF08120E).withValues(alpha: 0.98),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
            ),
            title: Text(
              "SERVICE AREA & COVERAGE",
              style: GoogleFonts.italiana(
                fontSize: isDesktop ? 17 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.track_changes_rounded, size: 15, color: Colors.white70),
                label: Text("TRACK BOOKING", style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.bold)),
                onPressed: () => showBookingTrackerDialog(context),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Main Centered Dashboard Panel
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 12,
                    vertical: isDesktop ? 16 : 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF08120E),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: goldColor.withValues(alpha: 0.22),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isDesktop ? 22 : 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header Row matching Image 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "GUJARAT & BEYOND",
                              style: AppTheme.sansBody(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: goldColor,
                                letterSpacing: 2.2,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.home_outlined, size: 13, color: goldColor.withValues(alpha: 0.8)),
                                const SizedBox(width: 5),
                                Text(
                                  "SERVICE AREA & COVERAGE",
                                  style: AppTheme.sansBody(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // HERO SECTION (Left Content + Gujarat Map)
                        _buildHeroSection(isDesktop: isDesktop, isTablet: isTablet, goldColor: goldColor),

                        const SizedBox(height: 24),

                        // PHYSICAL CREATIVE STUDIOS SECTION
                        _buildStudiosSection(isDesktop: isDesktop, isTablet: isTablet, goldColor: goldColor),

                        const SizedBox(height: 24),

                        // COVERAGE ZONES SECTION (3 EQUAL CARDS — ZERO OVERFLOW)
                        _buildCoverageZonesSection(isDesktop: isDesktop, isTablet: isTablet, goldColor: goldColor),

                        const SizedBox(height: 26),

                        // COMPACT BOTTOM CTA CARD
                        _buildBottomCtaCard(goldColor: goldColor),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HERO SECTION
  // ==========================================
  Widget _buildHeroSection({
    required bool isDesktop,
    required bool isTablet,
    required Color goldColor,
  }) {
    final leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Heading
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Service Locations\n",
                style: GoogleFonts.italiana(
                  fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: 0.3,
                ),
              ),
              TextSpan(
                text: "& Coverage",
                style: GoogleFonts.italiana(
                  fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                  height: 1.15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle matching Image 2
        Text(
          "Operating dual creative studios in Kadi and Thangadh, OM Events & Decorators orchestrates across Ahmedabad, Gandhinagar, Mehsana, Surendranagar, and premier destinations throughout Gujarat.",
          style: AppTheme.sansBody(
            fontSize: 12.5,
            color: Colors.white70,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),

        // Compact Venue Coverage Search Card
        _buildVenueSearchCard(goldColor: goldColor),

        const SizedBox(height: 16),

        // Compact 4 Feature Highlights Row matching Image 2
        _buildFeatureHighlights(goldColor: goldColor, isDesktop: isDesktop),
      ],
    );

    final rightMap = _GujaratCoverageMap(
      goldColor: goldColor,
      onCitySelected: (cityName) => _checkCoverage(cityName),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 42,
            child: leftContent,
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 58,
            child: SizedBox(
              height: 400,
              child: rightMap,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftContent,
          const SizedBox(height: 20),
          SizedBox(
            height: isTablet ? 380 : 340,
            child: rightMap,
          ),
        ],
      );
    }
  }

  // ==========================================
  // VENUE COVERAGE SEARCH CARD
  // ==========================================
  Widget _buildVenueSearchCard({required Color goldColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: goldColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pin_drop_outlined, color: goldColor, size: 14),
              const SizedBox(width: 6),
              Text(
                "Check Venue Coverage",
                style: AppTheme.sansBody(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _pincodeCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    cursorColor: goldColor,
                    onSubmitted: (_) => _checkCoverage(),
                    decoration: InputDecoration(
                      hintText: "e.g. Kadi, 382715, Ahmedabad...",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF060F0C),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: goldColor, width: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: goldColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _checkCoverage(),
                  child: Container(
                    height: 38,
                    width: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF091210),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Dynamic Result Card
          if (_checkResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_checkResult!['color'] as Color).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (_checkResult!['color'] as Color).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 15, color: _checkResult!['color'] as Color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _checkResult!['status'] as String,
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _checkResult!['color'] as Color,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _checkResult = null),
                        child: const Icon(Icons.close_rounded, size: 15, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _checkResult!['zone'] as String,
                    style: GoogleFonts.italiana(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _checkResult!['details'] as String,
                    style: AppTheme.sansBody(fontSize: 11, color: Colors.white70, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 12, color: goldColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _checkResult!['fee'] as String,
                          style: AppTheme.sansBody(fontSize: 10.5, color: goldColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: Colors.white54),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _checkResult!['leadTime'] as String,
                          style: AppTheme.sansBody(fontSize: 10, color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // COMPACT 4 FEATURE HIGHLIGHTS ROW (MATCHING IMAGE 2)
  // ==========================================
  Widget _buildFeatureHighlights({required Color goldColor, required bool isDesktop}) {
    final items = [
      (
        icon: Icons.verified_outlined,
        line1: "Verified Coverage",
        line2: "Across Gujarat",
      ),
      (
        icon: Icons.directions_car_outlined,
        line1: "Custom Travel",
        line2: "Arrangements",
      ),
      (
        icon: Icons.groups_outlined,
        line1: "On-Site Team",
        line2: "Support",
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        line1: "Transparent",
        line2: "Communication",
      ),
    ];

    Widget buildItem({required IconData icon, required String line1, required String line2}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: goldColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: goldColor.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, size: 13, color: goldColor),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line1,
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                Text(
                  line2,
                  style: AppTheme.sansBody(
                    fontSize: 9.5,
                    color: Colors.white60,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((it) => Expanded(child: buildItem(icon: it.icon, line1: it.line1, line2: it.line2))).toList(),
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 10,
        children: items
            .map((it) => SizedBox(
                  width: 150,
                  child: buildItem(icon: it.icon, line1: it.line1, line2: it.line2),
                ))
            .toList(),
      );
    }
  }

  // ==========================================
  // PHYSICAL CREATIVE STUDIOS SECTION
  // ==========================================
  Widget _buildStudiosSection({
    required bool isDesktop,
    required bool isTablet,
    required Color goldColor,
  }) {
    final studios = StudioLocationsHelper.getPublicStudios();
    final kadiStudio = studios.isNotEmpty ? studios.first : StudioLocationsHelper.kadiStudio;
    final thangadhStudio = studios.length > 1 ? studios[1] : StudioLocationsHelper.thangadhStudio;

    final kadiTitle = kadiStudio.name.contains("Studio") ? kadiStudio.name : "Kadi Showroom & Studio";
    final thangadhTitle = thangadhStudio.name.contains("Base") || thangadhStudio.name.contains("Showroom")
        ? thangadhStudio.name
        : "Thangadh Creative Base";

    final card1 = _buildStudioCard(
      title: kadiTitle,
      address: kadiStudio.fullAddress,
      primaryCoverage: "Mehsana, Gandhinagar & North Ahmedabad",
      imageAsset: AppImages.luxuryReception,
      goldColor: goldColor,
      onArrowTap: () => StudioLocationsHelper.openInGoogleMaps(kadiStudio.fullAddress),
    );

    final card2 = _buildStudioCard(
      title: thangadhTitle,
      address: thangadhStudio.fullAddress,
      primaryCoverage: "Surendranagar, Wadhwan, Chotila & Surroundings",
      imageAsset: AppImages.luxuryEveningDecor,
      goldColor: goldColor,
      onArrowTap: () => StudioLocationsHelper.openInGoogleMaps(thangadhStudio.fullAddress),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Physical Creative Studios",
          style: GoogleFonts.italiana(
            fontSize: isDesktop ? 21 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        if (isDesktop || isTablet)
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 14),
              Expanded(child: card2),
            ],
          )
        else
          Column(
            children: [
              card1,
              const SizedBox(height: 12),
              card2,
            ],
          ),
      ],
    );
  }

  Widget _buildStudioCard({
    required String title,
    required String address,
    required String primaryCoverage,
    required String imageAsset,
    required Color goldColor,
    required VoidCallback onArrowTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 125),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 38% Card Width Image
            Expanded(
              flex: 38,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF14241F),
                    child: Icon(Icons.storefront_rounded, color: goldColor, size: 28),
                  ),
                ),
              ),
            ),

            // 62% Card Width Information
            Expanded(
              flex: 62,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Studio Header with icon and arrow button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            color: goldColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.storefront_rounded, color: goldColor, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.italiana(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Material(
                          color: goldColor,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onArrowTap,
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Color(0xFF091210),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Address
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 10.5,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Primary Coverage
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Primary Coverage: ",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                            ),
                          ),
                          TextSpan(
                            text: primaryCoverage,
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: Colors.white60,
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
        ),
      ),
    );
  }

  // ==========================================
  // COVERAGE ZONES SECTION (MATCHING IMAGE 2 — ZERO OVERFLOW)
  // ==========================================
  Widget _buildCoverageZonesSection({
    required bool isDesktop,
    required bool isTablet,
    required Color goldColor,
  }) {
    final zone1 = _buildZoneCard(
      icon: Icons.local_shipping_outlined,
      title: "Zone 1: Primary Delivery Hubs",
      locations: "Kadi, Kalol, Mehsana, Nandasan, Ahmedabad Metro, Gandhinagar",
      allowanceBadge: "₹500 standard delivery",
      badgeColor: const Color(0xFF4EBA7A),
      goldColor: goldColor,
    );

    final zone2 = _buildZoneCard(
      icon: Icons.location_on_outlined,
      title: "Zone 2: Extended Gujarat Districts",
      locations: "Sanand, Bavla, Viramgam, Himatnagar, Vijapur, Unjha, Patan, etc.",
      allowanceBadge: "Nominal travel allowance",
      badgeColor: const Color(0xFFE2C074),
      goldColor: goldColor,
    );

    final zone3 = _buildZoneCard(
      icon: Icons.workspace_premium_outlined,
      title: "Zone 3: Royal Heritage & Destinations",
      locations: "Udaipur, Mount Abu, Surat, Bhavnagar, Jamnagar and heritage venues.",
      allowanceBadge: "Custom logistics & accommodation",
      badgeColor: const Color(0xFF64B5F6),
      goldColor: goldColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Coverage Zones",
              style: GoogleFonts.italiana(
                fontSize: isDesktop ? 21 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 1.5,
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isDesktop)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: zone1),
                const SizedBox(width: 12),
                Expanded(child: zone2),
                const SizedBox(width: 12),
                Expanded(child: zone3),
              ],
            ),
          )
        else
          Column(
            children: [
              zone1,
              const SizedBox(height: 12),
              zone2,
              const SizedBox(height: 12),
              zone3,
            ],
          ),
      ],
    );
  }

  Widget _buildZoneCard({
    required IconData icon,
    required String title,
    required String locations,
    required String allowanceBadge,
    required Color badgeColor,
    required Color goldColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1914),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon on left + (Title + Locations) on right (Matches Image 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: goldColor.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, size: 16, color: goldColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.italiana(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locations,
                      style: AppTheme.sansBody(
                        fontSize: 10.5,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Clean Pill Badge at Bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              allowanceBadge,
              style: AppTheme.sansBody(
                fontSize: 10,
                color: badgeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COMPACT BOTTOM CTA CARD
  // ==========================================
  Widget _buildBottomCtaCard({required Color goldColor}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E19),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Planning a Celebration in Your City?",
                textAlign: TextAlign.center,
                style: GoogleFonts.italiana(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Our team will personally review your venue location and confirm slot availability.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: 11.5,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 14),
                label: const Text("BOOK EVENT AT YOUR VENUE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: const Color(0xFF091210),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Experience? exp;
                  if (Get.isRegistered<CatalogController>()) {
                    final experiences = Get.find<CatalogController>().rxExperiences;
                    if (experiences.isNotEmpty) exp = experiences.first;
                  }
                  if (exp != null) {
                    showCustomerBookingDialog(
                      context,
                      experience: exp,
                      selectedPackage: exp.dynamicPackages.first,
                    );
                  } else {
                    Get.offAllNamed(AppRoutes.home);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STYLIZED GUJARAT COVERAGE MAP (MATCHING OPTION 2 REFERENCE)
// ============================================================================
enum _MarkerLevel {
  primaryStudio,    // Kadi, Thangadh
  majorCoverage,    // Ahmedabad, Gandhinagar, Mehsana, Surendranagar, Rajkot
  extendedCoverage, // Patan, Viramgam, Vadodara
  destinationEvents,// Surat
}

class _MapCity {
  final String name;
  final double x;
  final double y;
  final _MarkerLevel level;
  final bool labelOnRight;

  const _MapCity({
    required this.name,
    required this.x,
    required this.y,
    required this.level,
    required this.labelOnRight,
  });
}

class _GujaratCoverageMap extends StatelessWidget {
  final Color goldColor;
  final ValueChanged<String> onCitySelected;

  const _GujaratCoverageMap({
    required this.goldColor,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF091511),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldColor.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 20 || constraints.maxHeight < 20) {
              return const SizedBox.shrink();
            }
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            final cities = [
              const _MapCity(name: "Patan", x: 0.49, y: 0.18, level: _MarkerLevel.extendedCoverage, labelOnRight: false),
              const _MapCity(name: "Mehsana", x: 0.58, y: 0.16, level: _MarkerLevel.majorCoverage, labelOnRight: false),
              const _MapCity(name: "Kadi", x: 0.59, y: 0.23, level: _MarkerLevel.primaryStudio, labelOnRight: false),
              const _MapCity(name: "Gandhinagar", x: 0.67, y: 0.21, level: _MarkerLevel.majorCoverage, labelOnRight: true),
              const _MapCity(name: "Ahmedabad", x: 0.66, y: 0.27, level: _MarkerLevel.majorCoverage, labelOnRight: true),
              const _MapCity(name: "Viramgam", x: 0.53, y: 0.26, level: _MarkerLevel.extendedCoverage, labelOnRight: false),
              const _MapCity(name: "Surendranagar", x: 0.50, y: 0.34, level: _MarkerLevel.majorCoverage, labelOnRight: false),
              const _MapCity(name: "Thangadh", x: 0.45, y: 0.41, level: _MarkerLevel.primaryStudio, labelOnRight: false),
              const _MapCity(name: "Rajkot", x: 0.38, y: 0.53, level: _MarkerLevel.majorCoverage, labelOnRight: false),
              const _MapCity(name: "Vadodara", x: 0.70, y: 0.40, level: _MarkerLevel.extendedCoverage, labelOnRight: true),
              const _MapCity(name: "Surat", x: 0.68, y: 0.55, level: _MarkerLevel.destinationEvents, labelOnRight: true),
            ];

            return Stack(
              children: [
                // Custom Painter for Gujarat Vector Silhouette, Halos & Highway Rays
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GujaratMapPainter(goldColor: goldColor),
                  ),
                ),

                // City Markers & Labels
                ...cities.map((city) {
                  final pillWidthOffset = city.labelOnRight ? 6.0 : 72.0;

                  return Positioned(
                    left: city.x * w - pillWidthOffset,
                    top: city.y * h - 11,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onCitySelected(city.name),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!city.labelOnRight) ...[
                            _buildCityPill(city, goldColor),
                            const SizedBox(width: 4),
                          ],
                          _buildMarker(city.level, goldColor),
                          if (city.labelOnRight) ...[
                            const SizedBox(width: 4),
                            _buildCityPill(city, goldColor),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                // Floating Map Legend (Top-Right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07120E).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: goldColor.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLegendItem(
                          icon: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: goldColor),
                            child: const Center(child: Icon(Icons.star, size: 5, color: Color(0xFF091210))),
                          ),
                          label: "Primary Studio",
                        ),
                        const SizedBox(height: 4),
                        _buildLegendItem(
                          icon: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: goldColor,
                              boxShadow: [
                                BoxShadow(color: goldColor.withValues(alpha: 0.6), blurRadius: 4),
                              ],
                            ),
                          ),
                          label: "Major Coverage",
                        ),
                        const SizedBox(height: 4),
                        _buildLegendItem(
                          icon: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: goldColor.withValues(alpha: 0.8), width: 1.2),
                            ),
                            child: Center(
                              child: Container(width: 2, height: 2, decoration: BoxDecoration(shape: BoxShape.circle, color: goldColor)),
                            ),
                          ),
                          label: "Extended Coverage",
                        ),
                        const SizedBox(height: 4),
                        _buildLegendItem(
                          icon: Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: goldColor.withValues(alpha: 0.45),
                            ),
                          ),
                          label: "Destination Events",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCityPill(_MapCity city, Color goldColor) {
    final isStudio = city.level == _MarkerLevel.primaryStudio;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF07120E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isStudio ? goldColor : goldColor.withValues(alpha: 0.75),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        city.name,
        style: GoogleFonts.montserrat(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: isStudio ? const Color(0xFFE5C378) : Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildMarker(_MarkerLevel level, Color goldColor) {
    if (level == _MarkerLevel.primaryStudio) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: goldColor,
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.7),
              blurRadius: 7,
              spreadRadius: 1.5,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.star, size: 9, color: Color(0xFF091210)),
        ),
      );
    }

    if (level == _MarkerLevel.majorCoverage) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: goldColor.withValues(alpha: 0.30),
          border: Border.all(color: goldColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.65),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5C378),
            ),
          ),
        ),
      );
    }

    if (level == _MarkerLevel.extendedCoverage) {
      return Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: goldColor.withValues(alpha: 0.18),
          border: Border.all(color: goldColor.withValues(alpha: 0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldColor,
            ),
          ),
        ),
      );
    }

    // destinationEvents
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: goldColor.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Widget icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 9,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// GUJARAT MAP CUSTOM PAINTER WITH AUTHENTIC STYLIZED CONTOURS & HALOS
// ============================================================================
class _GujaratMapPainter extends CustomPainter {
  final Color goldColor;

  _GujaratMapPainter({required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 20 || size.height < 20) return;
    final w = size.width;
    final h = size.height;

    // 1. Ambient Background Radial Glow
    final radialPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.2, -0.1),
        radius: 0.9,
        colors: [
          goldColor.withValues(alpha: 0.12),
          const Color(0xFF102820).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), radialPaint);

    // 2. Halos around Studios and Major Hubs
    final kadiCenter = Offset(w * 0.59, h * 0.23);
    final kadiGlow = Paint()
      ..shader = RadialGradient(
        colors: [goldColor.withValues(alpha: 0.24), Colors.transparent],
      ).createShader(Rect.fromCircle(center: kadiCenter, radius: 55));
    canvas.drawCircle(kadiCenter, 55, kadiGlow);

    final thangadhCenter = Offset(w * 0.45, h * 0.41);
    final thangadhGlow = Paint()
      ..shader = RadialGradient(
        colors: [goldColor.withValues(alpha: 0.24), Colors.transparent],
      ).createShader(Rect.fromCircle(center: thangadhCenter, radius: 55));
    canvas.drawCircle(thangadhCenter, 55, thangadhGlow);

    // 3. Golden Highway Rays Linking Hubs
    final highwayGlow = Paint()
      ..color = goldColor.withValues(alpha: 0.14)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final highwayCore = Paint()
      ..color = goldColor.withValues(alpha: 0.50)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final connections = [
      (Offset(w * 0.49, h * 0.18), Offset(w * 0.58, h * 0.16)), // Patan - Mehsana
      (Offset(w * 0.58, h * 0.16), Offset(w * 0.59, h * 0.23)), // Mehsana - Kadi
      (Offset(w * 0.59, h * 0.23), Offset(w * 0.67, h * 0.21)), // Kadi - Gandhinagar
      (Offset(w * 0.59, h * 0.23), Offset(w * 0.66, h * 0.27)), // Kadi - Ahmedabad
      (Offset(w * 0.67, h * 0.21), Offset(w * 0.66, h * 0.27)), // Gandhinagar - Ahmedabad
      (Offset(w * 0.59, h * 0.23), Offset(w * 0.53, h * 0.26)), // Kadi - Viramgam
      (Offset(w * 0.53, h * 0.26), Offset(w * 0.50, h * 0.34)), // Viramgam - Surendranagar
      (Offset(w * 0.50, h * 0.34), Offset(w * 0.45, h * 0.41)), // Surendranagar - Thangadh
      (Offset(w * 0.45, h * 0.41), Offset(w * 0.38, h * 0.53)), // Thangadh - Rajkot
      (Offset(w * 0.66, h * 0.27), Offset(w * 0.70, h * 0.40)), // Ahmedabad - Vadodara
      (Offset(w * 0.70, h * 0.40), Offset(w * 0.68, h * 0.55)), // Vadodara - Surat
    ];

    for (final conn in connections) {
      canvas.drawLine(conn.$1, conn.$2, highwayGlow);
      canvas.drawLine(conn.$1, conn.$2, highwayCore);
    }

    // Fine Ambient Network Lines from Kadi Studio
    final webPaint = Paint()
      ..color = goldColor.withValues(alpha: 0.08)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final hub = Offset(w * 0.59, h * 0.23);
    for (int i = 0; i < 6; i++) {
      final rad = (i * 60) * math.pi / 180.0;
      final end = Offset(hub.dx + 240 * math.cos(rad), hub.dy + 240 * math.sin(rad));
      canvas.drawLine(hub, end, webPaint);
    }

    // 4. Stylized Gujarat Geographic Silhouette Path (Authentic Contours Matching Image 2)
    final path = Path();
    path.moveTo(w * 0.38, h * 0.22); // West Kutch
    path.quadraticBezierTo(w * 0.46, h * 0.16, w * 0.54, h * 0.14); // North Kutch to Banaskantha
    path.quadraticBezierTo(w * 0.62, h * 0.12, w * 0.68, h * 0.14); // North Gujarat border
    path.quadraticBezierTo(w * 0.74, h * 0.18, w * 0.78, h * 0.26); // North-East border
    path.quadraticBezierTo(w * 0.80, h * 0.34, w * 0.78, h * 0.44); // Eastern border
    path.quadraticBezierTo(w * 0.76, h * 0.52, w * 0.73, h * 0.60); // Central-East corridor
    path.quadraticBezierTo(w * 0.71, h * 0.68, w * 0.69, h * 0.76); // South Gujarat corridor
    path.quadraticBezierTo(w * 0.67, h * 0.78, w * 0.65, h * 0.76); // South Gujarat tip
    path.quadraticBezierTo(w * 0.63, h * 0.68, w * 0.61, h * 0.58); // Coast of South Gujarat
    path.quadraticBezierTo(w * 0.59, h * 0.48, w * 0.56, h * 0.47); // Gulf of Khambhat head
    path.quadraticBezierTo(w * 0.54, h * 0.52, w * 0.52, h * 0.60); // East Saurashtra (Bhavnagar)
    path.quadraticBezierTo(w * 0.47, h * 0.68, w * 0.38, h * 0.68); // South Saurashtra (Gir Somnath)
    path.quadraticBezierTo(w * 0.30, h * 0.64, w * 0.26, h * 0.54); // South-West Saurashtra (Porbandar)
    path.quadraticBezierTo(w * 0.24, h * 0.45, w * 0.28, h * 0.38); // West tip (Dwarka cape)
    path.quadraticBezierTo(w * 0.34, h * 0.36, w * 0.42, h * 0.35); // Gulf of Kutch South coast
    path.quadraticBezierTo(w * 0.46, h * 0.33, w * 0.46, h * 0.30); // Little Rann head
    path.quadraticBezierTo(w * 0.40, h * 0.29, w * 0.34, h * 0.27); // Gulf of Kutch North coast
    path.quadraticBezierTo(w * 0.30, h * 0.25, w * 0.38, h * 0.22); // Close to West Kutch
    path.close();

    // 5. Interior Fill of Gujarat Path
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F261F).withValues(alpha: 0.38),
          const Color(0xFF091410).withValues(alpha: 0.20),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 6. Layered Pure-Vector Gold Glow Strokes
    final glowPaint1 = Paint()
      ..color = goldColor.withValues(alpha: 0.10)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint1);

    final glowPaint2 = Paint()
      ..color = goldColor.withValues(alpha: 0.22)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glowPaint2);

    // 7. Crisp Champagne Gold Inner Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFFE2C074)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
