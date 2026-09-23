import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
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

  void _checkCoverage() {
    final query = _pincodeCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return;

    // Primary Hubs & Pincodes
    // Kadi (382715), Thangadh (363530), Ahmedabad (380xxx), Gandhinagar (382xxx), Mehsana (384xxx), Surendranagar (363001)
    if (query.contains('kadi') ||
        query == '382715' ||
        query.contains('thangadh') ||
        query == '363530' ||
        query.contains('ahmedabad') ||
        query.startsWith('380') ||
        query.contains('gandhinagar') ||
        query.startsWith('3820') ||
        query.contains('kalol') ||
        query == '382721' ||
        query.contains('mehsana') ||
        query.startsWith('3840') ||
        query.contains('surendranagar') ||
        query == '363001' ||
        query.contains('wadhwan') ||
        query == '363030' ||
        query.contains('chotila') ||
        query == '363520') {
      setState(() {
        _checkResult = {
          'zone': 'Zone 1 — Primary Studio Hub',
          'status': 'FULL SERVICE GUARANTEED',
          'color': const Color(0xFF4EBA7A),
          'fee': 'Standard Local Delivery (₹500 / Free on Packages)',
          'leadTime': '7 Days Standard Advance Notice',
          'details': 'Your location is directly serviced by our primary teams in Kadi & Thangadh. Full stage setups, balloon artistry, and flower procurement are readily available.',
        };
      });
      return;
    }

    // Extended Gujarat Zones
    if (query.contains('rajkot') ||
        query.startsWith('360') ||
        query.contains('sanand') ||
        query == '382110' ||
        query.contains('vadodara') ||
        query.startsWith('390') ||
        query.contains('anand') ||
        query.startsWith('388') ||
        query.contains('nadiad') ||
        query == '387001' ||
        query.contains('himatnagar') ||
        query == '383001' ||
        query.contains('morbi') ||
        query.startsWith('3636') ||
        query.contains('patan') ||
        query == '384265' ||
        query.contains('viramgam') ||
        query == '382150' ||
        query.contains('gujarat') ||
        (query.length == 6 && query.startsWith('3'))) {
      setState(() {
        _checkResult = {
          'zone': 'Zone 2 — Extended Gujarat Region',
          'status': 'AVAILABLE WITH TRAVEL ALLOWANCE',
          'color': const Color(0xFFD4AF37),
          'fee': 'Nominal Travel & Logistics (₹15/km or flat outstation allowance)',
          'leadTime': '10-14 Days Advance Notice Recommended',
          'details': 'Our decoration crew happily travels to this location! Extra travel charge will be transparently detailed in your official proposal.',
        };
      });
      return;
    }

    // Destination / Custom Outstation
    setState(() {
      _checkResult = {
        'zone': 'Zone 3 — Destination / Custom Venue',
        'status': 'BESPOKE OUTSTATION BOOKING',
        'color': const Color(0xFF64B5F6),
        'fee': 'Custom Logistics & Staff Travel Quoted Upon Request',
        'leadTime': '15-30 Days Advance Notice',
        'details': 'We craft destination weddings and royal celebrations across India. Submit a quotation request with your venue details, and our master event coordinator will contact you.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF091210),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1B18).withValues(alpha: 0.95),
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
              style: GoogleFonts.italiana(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            actions: [
              TextButton.icon(
                icon: Icon(Icons.photo_library_outlined, size: 16, color: goldColor),
                label: Text("GALLERY", style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold)),
                onPressed: () => Get.toNamed(AppRoutes.gallery),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.track_changes_rounded, size: 16, color: Colors.white70),
                label: Text("TRACK BOOKING", style: AppTheme.sansBody(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                onPressed: () => showBookingTrackerDialog(context),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 20,
                vertical: isDesktop ? 40 : 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1B18), Color(0xFF091210)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "GUJARAT & BEYOND",
                    style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Service Locations & Coverage",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.italiana(
                      fontSize: isDesktop ? 36 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      "Operating dual creative studios in Kadi and Thangadh, OM Events & Decorators orchestrates celebrations across Ahmedabad, Gandhinagar, Mehsana, Surendranagar, and premier destinations throughout Gujarat.",
                      textAlign: TextAlign.center,
                      style: AppTheme.sansBody(fontSize: 13.5, color: Colors.white60, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Pincode / City Live Checker Box
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152621),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pin_drop_outlined, color: goldColor, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "CHECK VENUE COVERAGE",
                                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Enter your celebration city or 6-digit Gujarat pincode to verify delivery terms and travel allowances:",
                            style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pincodeCtrl,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  cursorColor: goldColor,
                                  onSubmitted: (_) => _checkCoverage(),
                                  decoration: InputDecoration(
                                    hintText: "e.g. Kadi, 382715, Ahmedabad, Thangadh...",
                                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
                                    filled: true,
                                    fillColor: const Color(0xFF0F1B18),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: goldColor.withValues(alpha: 0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: goldColor),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _checkCoverage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldColor,
                                  foregroundColor: const Color(0xFF091210),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  textStyle: AppTheme.sansBody(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                                child: const Text("CHECK"),
                              ),
                            ],
                          ),

                          // Dynamic Result Banner
                          if (_checkResult != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: (_checkResult!['color'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: (_checkResult!['color'] as Color).withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 18, color: _checkResult!['color'] as Color),
                                      const SizedBox(width: 8),
                                      Text(
                                        _checkResult!['status'] as String,
                                        style: AppTheme.sansBody(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _checkResult!['color'] as Color,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _checkResult!['zone'] as String,
                                    style: GoogleFonts.italiana(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _checkResult!['details'] as String,
                                    style: AppTheme.sansBody(fontSize: 12, color: Colors.white70, height: 1.4),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.local_shipping_outlined, size: 14, color: goldColor),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _checkResult!['fee'] as String,
                                          style: AppTheme.sansBody(fontSize: 11.5, color: goldColor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, size: 14, color: Colors.white54),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _checkResult!['leadTime'] as String,
                                          style: AppTheme.sansBody(fontSize: 11, color: Colors.white60),
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Studio Hubs Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("STUDIO BASES", style: AppTheme.sansBody(fontSize: 10.5, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Text("Our Physical Creative Studios", style: GoogleFonts.italiana(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),

                  isDesktop
                      ? Row(
                          children: [
                            Expanded(child: _buildBranchCard("Kadi Showroom & Studio", "Near Sardar Patel Chowk, Kadi, Mehsana, Gujarat 382715", "Mehsana, Gandhinagar & North Ahmedabad", goldColor)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildBranchCard("Thangadh Creative Base", "Surajdeval Road, Thangadh, Surendranagar, Gujarat 363530", "Surendranagar, Wadhwan, Chotila & Saurashtra", goldColor)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildBranchCard("Kadi Showroom & Studio", "Near Sardar Patel Chowk, Kadi, Mehsana, Gujarat 382715", "Mehsana, Gandhinagar & North Ahmedabad", goldColor),
                            const SizedBox(height: 16),
                            _buildBranchCard("Thangadh Creative Base", "Surajdeval Road, Thangadh, Surendranagar, Gujarat 363530", "Surendranagar, Wadhwan, Chotila & Saurashtra", goldColor),
                          ],
                        ),

                  const SizedBox(height: 40),

                  // Coverage Zones Details
                  Text("COVERAGE TIERS", style: AppTheme.sansBody(fontSize: 10.5, fontWeight: FontWeight.bold, color: goldColor, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Text("Detailed Delivery & Travel Guidelines", style: GoogleFonts.italiana(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),

                  _buildZoneTile(
                    "Zone 1: Primary Delivery Hubs",
                    "Kadi, Kalol, Mehsana, Nandasan, Ahmedabad Metro (S.G. Highway, Bopal, Satellite, Prahlad Nagar, Motera, Sindhu Bhavan), Gandhinagar (Koba, GIFT City), Thangadh, Surendranagar, Wadhwan, Chotila.",
                    "₹500 standard delivery / Complimentary on luxury curation packages. Dedicated on-site supervisor included.",
                    const Color(0xFF4EBA7A),
                  ),
                  const SizedBox(height: 14),
                  _buildZoneTile(
                    "Zone 2: Extended Gujarat Districts",
                    "Sanand, Bavla, Viramgam, Himatnagar, Vijapur, Unjha, Patan, Siddhpur, Nadiad, Anand, Vadodara, Rajkot, Morbi, Halvad.",
                    "Nominal travel allowance (₹15/km from closest base or flat outstation charge). 10-14 days lead time requested.",
                    goldColor,
                  ),
                  const SizedBox(height: 14),
                  _buildZoneTile(
                    "Zone 3: Royal Heritage & Destination Venues",
                    "Udaipur, Mount Abu, Surat, Bhavnagar, Jamnagar, and heritage resort banquets across Western India.",
                    "Custom transport logistics, crew accommodation, and on-site multi-day preparation arranged seamlessly.",
                    const Color(0xFF64B5F6),
                  ),

                  const SizedBox(height: 40),

                  // Bottom Action Box
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152621),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: goldColor.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text("Planning a Celebration in Your City?", style: GoogleFonts.italiana(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Our team will personally review your venue location and confirm slot availability.", style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white60)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: const Text("BOOK EVENT AT YOUR VENUE"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: goldColor,
                              foregroundColor: const Color(0xFF091210),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(String title, String address, String primaryServiced, Color goldColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF152621),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: goldColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.italiana(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(address, style: AppTheme.sansBody(fontSize: 12, color: Colors.white70, height: 1.5)),
          const Divider(color: Colors.white12, height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Primary Coverage: ", style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: goldColor)),
              Expanded(
                child: Text(primaryServiced, style: AppTheme.sansBody(fontSize: 11, color: Colors.white60)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneTile(String title, String areas, String terms, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF152621),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(title, style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 10),
          Text(areas, style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white70, height: 1.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(terms, style: AppTheme.sansBody(fontSize: 11.5, color: accentColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
