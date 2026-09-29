import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../core/widgets/app_image.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/app_video_player.dart';

/// Overview Dashboard View for the Client Lounge.
/// Exactly matches the target reference design with compact visual density:
/// 1. Hero greeting banner with decor background & video button
/// 2. Compact festival campaign bar
/// 3. Triple card row (Platinum Membership + Active Proposals + Wishlist)
/// 4. 4 uniform Recently Viewed Themes portfolio cards
/// 5. Compact lounge activity timeline
class OverviewView extends StatelessWidget {
  final CustomerDashboardController controller;

  const OverviewView({
    super.key,
    required this.controller,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showShowcaseVideo(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF091410),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  "OM EVENTS SHOWCASE",
                  style: GoogleFonts.italiana(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFD4AF37)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: const AppVideoPlayer(
                    videoUrl: AppAssets.videoWeddingShowcase,
                    autoPlay: true,
                    looping: true,
                    showControls: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  "Contact your dedicated OM Events concierge for bespoke walkthrough footage.",
                  textAlign: TextAlign.center,
                  style: AppTheme.sansBody(fontSize: 11, color: Colors.white60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFD4AF37);
    const Color cardBg = Color(0xFF101914);
    const Color cardBorder = Color(0x28D4AF37);

    return Obx(() {
      final profile = controller.rxProfile.value;
      final totalQuotes = controller.rxQuotations.length;
      final wishlistCount = controller.rxWishlist.length;
      final clientName = profile?.fullName.isNotEmpty == true
          ? profile!.fullName
          : "SHIWA";

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Hero / Welcome Card ───
            _buildHeroCard(context, clientName, goldColor),

            const SizedBox(height: 12),

            // ─── 2. Compact Festival Special Campaign Bar ───
            _buildCampaignBar(goldColor),

            const SizedBox(height: 14),

            // ─── 3. Membership + Quick Stats Row (3 equal-height cards) ───
            _buildMembershipStatsRow(totalQuotes, wishlistCount, goldColor, cardBg, cardBorder),

            const SizedBox(height: 20),

            // ─── 4. Recently Viewed Themes (4 Cards in one row) ───
            _buildRecentlyViewedSection(goldColor, cardBg, cardBorder),

            const SizedBox(height: 20),

            // ─── 5. Lounge Activity Logs (Compact) ───
            _buildActivityLogsSection(goldColor, cardBg, cardBorder),
          ],
        ),
      );
    });
  }

  // ============================================================================
  // 1. HERO / WELCOME CARD
  // ============================================================================
  Widget _buildHeroCard(BuildContext context, String clientName, Color goldColor) {
    return Container(
      height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: goldColor.withValues(alpha: 0.32), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              'assets/images/luxury-evening-decor.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF16241C),
              ),
            ),

            // Dark Luminous Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.88),
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),

            // Foreground Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Left greeting and name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${_getGreeting()},",
                          style: AppTheme.sansBody(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE8CC8A),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          clientName.toUpperCase(),
                          style: GoogleFonts.italiana(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Your celebrations, our creative canvas.",
                          style: AppTheme.sansBody(
                            fontSize: 10.5,
                            color: Colors.white70,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: REF ID (top) and Play Video button (bottom)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reference ID badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121B16).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: goldColor.withValues(alpha: 0.45),
                            width: 0.9,
                          ),
                        ),
                        child: Text(
                          "REF: OM-REF552",
                          style: AppTheme.sansBody(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE8CC8A),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      // Play Video Button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showShowcaseVideo(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE8CC8A), Color(0xFFC8A96E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 19,
                                  height: 19,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0D1915),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      size: 13,
                                      color: Color(0xFFE8CC8A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  "Play Video",
                                  style: AppTheme.sansBody(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0D1915),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 2. COMPACT CAMPAIGN BAR
  // ============================================================================
  Widget _buildCampaignBar(Color goldColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8CC8A), Color(0xFFC8A96E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            color: Color(0xFF0D1915),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTheme.sansBody(
                  fontSize: 10.5,
                  color: const Color(0xFF0D1915),
                ),
                children: const [
                  TextSpan(
                    text: "FESTIVAL SPECIAL CAMPAIGN: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "Use coupon FEST10 for 10% off your decor contract booking fee!",
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF0D1915),
            size: 18,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 3. MEMBERSHIP + STATS ROW (3 Equal-Height Cards)
  // ============================================================================
  Widget _buildMembershipStatsRow(
    int totalQuotes,
    int wishlistCount,
    Color goldColor,
    Color cardBg,
    Color cardBorder,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isStacked = constraints.maxWidth < 680;

        if (isStacked) {
          return Column(
            children: [
              _buildMembershipCard(goldColor, cardBg, cardBorder),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.description_outlined,
                      title: "Active Contract\nProposals",
                      subtitle: "Tap to view details",
                      value: totalQuotes > 0 ? totalQuotes.toString() : "2",
                      goldColor: goldColor,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.favorite_border_rounded,
                      title: "My Inspiration\nWishlist",
                      subtitle: "Tap to view details",
                      value: wishlistCount.toString(),
                      goldColor: goldColor,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            // Card 1: Platinum Membership Card (approx 46% width)
            Expanded(
              flex: 5,
              child: _buildMembershipCard(goldColor, cardBg, cardBorder),
            ),
            const SizedBox(width: 10),

            // Card 2: Active Contract Proposals
            Expanded(
              flex: 3,
              child: _buildStatCard(
                icon: Icons.description_outlined,
                title: "Active Contract\nProposals",
                subtitle: "Tap to view details",
                value: totalQuotes > 0 ? totalQuotes.toString() : "2",
                goldColor: goldColor,
                cardBg: cardBg,
                cardBorder: cardBorder,
              ),
            ),
            const SizedBox(width: 10),

            // Card 3: My Inspiration Wishlist
            Expanded(
              flex: 3,
              child: _buildStatCard(
                icon: Icons.favorite_border_rounded,
                title: "My Inspiration\nWishlist",
                subtitle: "Tap to view details",
                value: wishlistCount.toString(),
                goldColor: goldColor,
                cardBg: cardBg,
                cardBorder: cardBorder,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMembershipCard(Color goldColor, Color cardBg, Color cardBorder) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Diamond Icon Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF14241C),
              border: Border.all(color: goldColor.withValues(alpha: 0.38), width: 1.1),
            ),
            child: Center(
              child: Icon(
                Icons.diamond_outlined,
                size: 16,
                color: goldColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title & Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "PLATINUM MEMBERSHIP",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      "1,500 PTS / 2,000 PTS",
                      style: AppTheme.sansBody(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE8CC8A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    value: 0.75,
                    minHeight: 4.5,
                    backgroundColor: Color(0xFF1C2B23),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8CC8A)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color goldColor,
    required Color cardBg,
    required Color cardBorder,
  }) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Icon Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF14241C),
              border: Border.all(color: goldColor.withValues(alpha: 0.32), width: 1.0),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 15,
                color: goldColor,
              ),
            ),
          ),
          const SizedBox(width: 9),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.sansBody(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.sansBody(
                    fontSize: 8.5,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),

          // Value Number
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 4. RECENTLY VIEWED THEMES (4 Consistent Cards in One Row)
  // ============================================================================
  Widget _buildRecentlyViewedSection(Color goldColor, Color cardBg, Color cardBorder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recently Viewed Themes",
              style: GoogleFonts.italiana(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: goldColor,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                Text(
                  "View All",
                  style: AppTheme.sansBody(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: goldColor,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 9),

        // 4 Theme Cards
        Builder(
          builder: (context) {
            final catalogCtrl = Get.isRegistered<CatalogController>()
                ? Get.find<CatalogController>()
                : null;

            final defaultThemes = [
              {"name": "BIRTHDAY CELEBRATION", "image": "assets/images/birthday-balloons.jpg"},
              {"name": "BABY SHOWER/SRIMANT...", "image": "assets/images/babyshower.jpg"},
              {"name": "CHHATHI PUJAN", "image": "assets/images/Chhathhi.jpg"},
              {"name": "BALLOON DECORATION", "image": "assets/images/Baloondecor.png"},
            ];

            List<Map<String, String>> cardsData = [];

            if (catalogCtrl != null && catalogCtrl.rxExperiences.isNotEmpty) {
              final experiences = catalogCtrl.rxExperiences.take(4).toList();
              for (var exp in experiences) {
                cardsData.add({
                  "name": exp.name.toUpperCase(),
                  "image": exp.imageUrl.isNotEmpty ? exp.imageUrl : "assets/images/luxury-evening-decor.jpg",
                });
              }
            }

            // Fill up to 4 if needed using default reference themes
            while (cardsData.length < 4) {
              cardsData.add(defaultThemes[cardsData.length % defaultThemes.length]);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 620;

                if (isNarrow) {
                  return SizedBox(
                    height: 155,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: cardsData.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final theme = cardsData[index];
                        return SizedBox(
                          width: 140,
                          child: _themeCard(theme["name"]!, theme["image"]!, goldColor, cardBg, cardBorder),
                        );
                      },
                    ),
                  );
                }

                return Row(
                  children: [
                    for (int i = 0; i < cardsData.length; i++) ...[
                      Expanded(
                        child: _themeCard(
                          cardsData[i]["name"]!,
                          cardsData[i]["image"]!,
                          goldColor,
                          cardBg,
                          cardBorder,
                        ),
                      ),
                      if (i < cardsData.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _themeCard(
    String title,
    String imageUrl,
    Color goldColor,
    Color cardBg,
    Color cardBorder,
  ) {
    return Container(
      height: 178,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Badges
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF16241C),
                            child: Icon(Icons.celebration, color: goldColor.withValues(alpha: 0.5), size: 20),
                          ),
                        )
                      : AppImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                        ),

                  // Subtle dark gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),

                  // Top-Right Wishlist Heart Button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.55),
                        border: Border.all(color: goldColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 11,
                          color: goldColor,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-Left PORTFOLIO Badge
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1915).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 0.7),
                      ),
                      child: Text(
                        "PORTFOLIO",
                        style: AppTheme.sansBody(
                          fontSize: 6.5,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Title Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sansBody(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 5. LOUNGE ACTIVITY LOGS SECTION (Compact)
  // ============================================================================
  Widget _buildActivityLogsSection(Color goldColor, Color cardBg, Color cardBorder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LOUNGE ACTIVITY LOGS",
          style: GoogleFonts.italiana(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: goldColor,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.rxActivity.isEmpty)
          Text(
            "No recent lounge activities logged yet.",
            style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white38),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder, width: 1.0),
            ),
            padding: const EdgeInsets.all(12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.rxActivity.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final act = controller.rxActivity[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 7, color: goldColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.status,
                            style: AppTheme.sansBody(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            act.details,
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      act.updatedAt.toLocal().toString().split(' ').first,
                      style: const TextStyle(fontSize: 9.5, color: Colors.white38),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
