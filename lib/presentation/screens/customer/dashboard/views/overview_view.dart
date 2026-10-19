import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../core/widgets/app_image.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/widgets/app_video_player.dart';
import '../../../../../core/utils/asset_downloader.dart';

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

      return LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final bool isMobile = maxWidth < 600;
          final bool isTablet = maxWidth >= 600 && maxWidth < 1024;
          final double hPadding = isMobile ? 12.0 : (isTablet ? 18.0 : 26.0);
          final double vPadding = isMobile ? 12.0 : 20.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPadding, vPadding, hPadding, 32),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── 1. Hero / Welcome Card ───
                _buildHeroCard(context, clientName, goldColor, isMobile: isMobile),

                const SizedBox(height: 12),

                // ─── 2. Compact Festival Special Campaign Bar ───
                _buildCampaignBar(goldColor, isMobile: isMobile),

                const SizedBox(height: 14),

                // ─── 3. Membership + Quick Stats Row (3 equal-height cards) ───
                _buildMembershipStatsRow(totalQuotes, wishlistCount, goldColor, cardBg, cardBorder),

                const SizedBox(height: 20),

                // ─── 4. Recently Viewed Themes (4 Cards on desktop/tablet, 2 on mobile) ───
                _buildRecentlyViewedSection(goldColor, cardBg, cardBorder),

                const SizedBox(height: 20),

                // ─── 5. Lounge Activity Logs (Compact) ───
                _buildActivityLogsSection(goldColor, cardBg, cardBorder),
              ],
            ),
          );
        },
      );
    });
  }

  // ============================================================================
  // 1. HERO / WELCOME CARD
  // ============================================================================
  Widget _buildHeroCard(
    BuildContext context,
    String clientName,
    Color goldColor, {
    required bool isMobile,
  }) {
    return Container(
      height: isMobile ? 152 : 165,
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
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 20,
                vertical: isMobile ? 12 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section: Greeting + Name on left, REF ID on right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_getGreeting()},",
                              style: AppTheme.sansBody(
                                fontSize: isMobile ? 10.5 : 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE8CC8A),
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              clientName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.italiana(
                                fontSize: isMobile ? 21 : 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Your celebrations, our creative canvas.",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.sansBody(
                                fontSize: isMobile ? 9.5 : 10.5,
                                color: Colors.white70,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Reference ID badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 10,
                          vertical: isMobile ? 3 : 3.5,
                        ),
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
                            fontSize: isMobile ? 8.5 : 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE8CC8A),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom section: Play Video Button aligned to the right
                  Align(
                    alignment: Alignment.centerRight,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showShowcaseVideo(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 11 : 13,
                            vertical: isMobile ? 5 : 6,
                          ),
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
                                width: isMobile ? 17 : 19,
                                height: isMobile ? 17 : 19,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0D1915),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: isMobile ? 12 : 13,
                                    color: const Color(0xFFE8CC8A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Play Video",
                                style: AppTheme.sansBody(
                                  fontSize: isMobile ? 10 : 10.5,
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
  Widget _buildCampaignBar(Color goldColor, {required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 7 : 8,
      ),
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
                  fontSize: isMobile ? 9.5 : 10.5,
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
              maxLines: isMobile ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
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
        final double width = constraints.maxWidth;
        final bool isCompact = width < 720;
        final bool isUltraNarrow = width < 340;

        if (isCompact) {
          return Column(
            children: [
              _buildMembershipCard(goldColor, cardBg, cardBorder, isCompact: width < 420),
              const SizedBox(height: 8),
              if (isUltraNarrow) ...[
                _buildStatCard(
                  icon: Icons.description_outlined,
                  title: "Active Contract\nProposals",
                  subtitle: "Tap to view details",
                  value: totalQuotes > 0 ? totalQuotes.toString() : "2",
                  goldColor: goldColor,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  isCompact: true,
                ),
                const SizedBox(height: 8),
                _buildStatCard(
                  icon: Icons.favorite_border_rounded,
                  title: "My Inspiration\nWishlist",
                  subtitle: "Tap to view details",
                  value: wishlistCount.toString(),
                  goldColor: goldColor,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  isCompact: true,
                ),
              ] else
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
                        isCompact: width < 420,
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
                        isCompact: width < 420,
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
              child: _buildMembershipCard(goldColor, cardBg, cardBorder, isCompact: false),
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
                isCompact: false,
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
                isCompact: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMembershipCard(
    Color goldColor,
    Color cardBg,
    Color cardBorder, {
    bool isCompact = false,
  }) {
    return Container(
      height: 88,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 12),
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
            width: isCompact ? 32 : 36,
            height: isCompact ? 32 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF14241C),
              border: Border.all(color: goldColor.withValues(alpha: 0.38), width: 1.1),
            ),
            child: Center(
              child: Icon(
                Icons.diamond_outlined,
                size: isCompact ? 14 : 16,
                color: goldColor,
              ),
            ),
          ),
          SizedBox(width: isCompact ? 8 : 10),

          // Title & Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "PLATINUM MEMBERSHIP",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.sansBody(
                          fontSize: isCompact ? 9.8 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "1,500 PTS / 2,000 PTS",
                      style: AppTheme.sansBody(
                        fontSize: isCompact ? 8.5 : 9.5,
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
    bool isCompact = false,
  }) {
    return Container(
      height: 88,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: 10),
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
            width: isCompact ? 28 : 32,
            height: isCompact ? 28 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF14241C),
              border: Border.all(color: goldColor.withValues(alpha: 0.32), width: 1.0),
            ),
            child: Center(
              child: Icon(
                icon,
                size: isCompact ? 13 : 15,
                color: goldColor,
              ),
            ),
          ),
          SizedBox(width: isCompact ? 6 : 9),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.sansBody(
                    fontSize: isCompact ? 8.8 : 9.5,
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
                    fontSize: isCompact ? 7.8 : 8.5,
                    color: Colors.white38,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Value Number
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: isCompact ? 19 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 4. RECENTLY VIEWED THEMES (4 on Desktop/Tablet, 2 on Mobile)
  // ============================================================================
  Widget _buildRecentlyViewedSection(Color goldColor, Color cardBg, Color cardBorder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Interactive View All Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recently Viewed Themes",
              style: GoogleFonts.italiana(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: goldColor,
                letterSpacing: 0.8,
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.gallery),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: AppTheme.sansBody(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: goldColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Theme Cards Row
        Builder(
          builder: (context) {
            final catalogCtrl = Get.isRegistered<CatalogController>()
                ? Get.find<CatalogController>()
                : null;

            final defaultThemes = [
              {
                "id": "birthday_celebration",
                "slug": "birthday_celebration",
                "name": "BIRTHDAY CELEBRATION",
                "image": "assets/images/birthday-balloons.jpg",
                "category": "BIRTHDAY",
              },
              {
                "id": "baby_shower_srimant",
                "slug": "baby_shower_srimant",
                "name": "BABY SHOWER / SRIMANT",
                "image": "assets/images/babyshower.jpg",
                "category": "BABY SHOWER",
              },
              {
                "id": "chhathi_pujan",
                "slug": "chhathi_pujan",
                "name": "CHHATHI PUJAN",
                "image": "assets/images/Chhathhi.jpg",
                "category": "PUJAN",
              },
              {
                "id": "balloon_decoration",
                "slug": "balloon_decoration",
                "name": "BALLOON DECORATION",
                "image": "assets/images/Baloondecor.png",
                "category": "BALLOONS",
              },
            ];

            List<Map<String, dynamic>> cardsData = [];

            if (catalogCtrl != null && catalogCtrl.rxExperiences.isNotEmpty) {
              final experiences = catalogCtrl.rxExperiences.take(4).toList();
              for (var exp in experiences) {
                cardsData.add({
                  "id": exp.id,
                  "slug": exp.slug,
                  "name": exp.name.toUpperCase(),
                  "image": exp.imageUrl.isNotEmpty ? exp.imageUrl : "assets/images/luxury-evening-decor.jpg",
                  "category": exp.categoryId.isNotEmpty ? exp.categoryId : "PORTFOLIO",
                  "exp": exp,
                });
              }
            }

            // Fill up to 4 if needed using default reference themes
            while (cardsData.length < 4) {
              cardsData.add(defaultThemes[cardsData.length % defaultThemes.length]);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;

                // Desktop, Laptop, and Tablet (>= 720px): 4 cards in one row
                if (width >= 720) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < cardsData.length; i++) ...[
                        Expanded(
                          child: _themeCard(
                            cardsData[i],
                            goldColor,
                            cardBg,
                            cardBorder,
                            isMobile: false,
                          ),
                        ),
                        if (i < cardsData.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  );
                }

                // Mobile & Narrow Tablet (< 720px): 2 cards in a row matching mobile reference
                final mobileCards = cardsData.take(2).toList();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < mobileCards.length; i++) ...[
                      Expanded(
                        child: _themeCard(
                          mobileCards[i],
                          goldColor,
                          cardBg,
                          cardBorder,
                          isMobile: true,
                        ),
                      ),
                      if (i < mobileCards.length - 1) const SizedBox(width: 10),
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

  /// Helper to determine the optimal visual focal alignment for decoration themes
  Alignment _getThemeImageAlignment(String title, String category, String imageUrl) {
    final key = "${title.toLowerCase()} ${category.toLowerCase()} ${imageUrl.toLowerCase()}";
    if (key.contains("chhath") || key.contains("pujan") || key.contains("chhathhi")) {
      return const Alignment(0.0, -0.2);
    }
    if (key.contains("birthday")) {
      return const Alignment(0.0, -0.1);
    }
    return Alignment.center;
  }

  Widget _themeCard(
    Map<String, dynamic> theme,
    Color goldColor,
    Color cardBg,
    Color cardBorder, {
    bool isMobile = false,
  }) {
    final title = (theme["name"] as String? ?? "Theme").toUpperCase();
    final imageUrl = theme["image"] as String? ?? "";
    final category = theme["category"] as String? ?? "PORTFOLIO";
    final expId = theme["id"] as String? ?? "";
    final expSlug = theme["slug"] as String? ?? "";

    final alignment = _getThemeImageAlignment(title, category, imageUrl);

    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.gallery),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1. Full-Width 16:9 Image Area ─────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          alignment: alignment,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF16241C),
                            child: Icon(Icons.celebration, color: goldColor.withValues(alpha: 0.5), size: 28),
                          ),
                        )
                      : AppImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                          alignment: alignment,
                        ),

                  // Top-Right Actions (Download & Wishlist Heart)
                  Positioned(
                    top: isMobile ? 5 : 8,
                    right: isMobile ? 5 : 8,
                    child: Obx(() {
                      final isFavorite = controller.isExperienceInWishlist(expSlug, expId);
                      final btnSize = isMobile ? 22.0 : 26.0;
                      final iconSize = isMobile ? 11.0 : 13.0;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageUrl.isNotEmpty) ...[
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final fileName = AssetDownloader.resolveFileName(
                                    imageUrl,
                                    fallbackTitle: title,
                                  );
                                  Get.snackbar(
                                    "Download Started",
                                    "Downloading theme image for $title...",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: const Color(0xFF171411),
                                    colorText: goldColor,
                                    duration: const Duration(seconds: 2),
                                  );
                                  await AssetDownloader.download(
                                    imageUrl,
                                    fileName: fileName,
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: btnSize,
                                  height: btnSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.65),
                                    border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 0.8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.download_rounded,
                                      size: iconSize,
                                      color: goldColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isMobile ? 4 : 6),
                          ],
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await controller.toggleWishlist(theme["exp"] ?? theme, context: Get.context);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: btnSize,
                                height: btnSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFavorite
                                      ? goldColor.withValues(alpha: 0.25)
                                      : Colors.black.withValues(alpha: 0.65),
                                  border: Border.all(
                                    color: goldColor.withValues(alpha: isFavorite ? 0.7 : 0.35),
                                    width: 0.8,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: iconSize,
                                    color: goldColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  // Bottom-Left Category / Portfolio Badge Over Image
                  Positioned(
                    bottom: isMobile ? 5 : 8,
                    left: isMobile ? 5 : 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 5 : 7,
                        vertical: isMobile ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1915).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 0.7),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: AppTheme.sansBody(
                          fontSize: isMobile ? 7.5 : 8.5,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Title & Metadata Area ────────
            Container(
              height: isMobile ? 38 : 46,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sansBody(
                  fontSize: isMobile ? 9.5 : 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final act = controller.rxActivity[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 6.5, color: goldColor),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                act.status,
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                act.updatedAt.toLocal().toString().split(' ').first,
                                style: const TextStyle(fontSize: 9.5, color: Colors.white38),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
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
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
