import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../core/widgets/app_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.rxProfile.value;
      final totalQuotes = controller.rxQuotations.length;
      final wishlistCount = controller.rxWishlist.length;
      final clientName = profile?.fullName ?? "Valued Client";

      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Luxury Top Campaign Ribbon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFE6C98D)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration, color: Color(0xFF091210), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "FESTIVAL SPECIAL CAMPAIGN: Use coupon FEST10 for 10% off your decor contract booking fee!",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF091210),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Greeting & Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_getGreeting()},",
                      style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      clientName.toUpperCase(),
                      style: GoogleFonts.italiana(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171411),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "REF: OM-REF552",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 1.0,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),

            // Row containing Membership Card and Key stats
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                if (width > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildMembershipCard()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildVerticalStats(totalQuotes, wishlistCount)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildMembershipCard(),
                      const SizedBox(height: 24),
                      _buildVerticalStats(totalQuotes, wishlistCount),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 36),

            // Recently Viewed Themes (Portfolio Gallery)
            Text(
              "RECENTLY VIEWED THEMES",
              style: GoogleFonts.italiana(fontSize: 20, color: const Color(0xFFD4AF37), letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              child: Builder(
                builder: (context) {
                  final catalogCtrl = Get.find<CatalogController>();
                  return Obx(() {
                    final items = catalogCtrl.rxExperiences.take(4).toList();
                    if (items.isEmpty) {
                      return const Center(child: Text("No themes viewed yet.", style: TextStyle(color: Colors.white54, fontSize: 13)));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildThemePortfolioCard(item.name, item.imageUrl);
                      },
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 36),

            // Offers & Promotions Banner
            if (controller.rxOffers.isNotEmpty) ...[
              Text(
                "LATEST OFFERS & CAMPAIGNS",
                style: GoogleFonts.italiana(fontSize: 20, color: const Color(0xFFD4AF37), letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.rxOffers.length,
                  itemBuilder: (context, index) {
                    final offer = controller.rxOffers[index];
                    return _buildOfferCard(offer.title, offer.description);
                  },
                ),
              ),
              const SizedBox(height: 36),
            ],

            // Real-time Action Activity Timeline logs
            Text(
              "LOUNGE ACTIVITY LOGS",
              style: GoogleFonts.italiana(fontSize: 20, color: const Color(0xFFD4AF37), letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            if (controller.rxActivity.isEmpty)
              Text("No recent lounge activities logged yet.", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54))
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF171411),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x1AD4AF37)),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(24),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.rxActivity.length,
                  itemBuilder: (context, index) {
                    final act = controller.rxActivity[index];
                    final isLast = index == controller.rxActivity.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle_outlined, color: Color(0xFFD4AF37), size: 14),
                            if (!isLast)
                              Container(
                                width: 1.5,
                                height: 50,
                                color: const Color(0x33D4AF37),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(act.status, style: AppTheme.serifHeader(fontSize: 14, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(act.details, style: AppTheme.sansBody(fontSize: 12, color: Colors.white54)),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Text(
                          act.updatedAt.toLocal().toString().split(' ').first,
                          style: const TextStyle(fontSize: 10, color: Colors.white38),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildMembershipCard() {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3A2B18), // Rich Dark Bronze
            Color(0xFF1A130B), // Near Black Warm Ebony
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.45), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MEMBER CLUB CARD",
                    style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFE6C98D), letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "PLATINUM MEMBERSHIP",
                    style: GoogleFonts.italiana(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
              const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 32),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "LOYALTY STATUS",
                    style: AppTheme.sansBody(fontSize: 10, color: Colors.white54, letterSpacing: 0.5),
                  ),
                  Text(
                    "1,500 Pts / 2,000 Pts",
                    style: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalStats(int totalQuotes, int wishlistCount) {
    return Column(
      children: [
        _buildMiniStatCard("ACTIVE CONTRACT PROPOSALS", totalQuotes.toString(), Icons.description_outlined),
        const SizedBox(height: 16),
        _buildMiniStatCard("MY INSPIRATION WISHLIST", wishlistCount.toString(), Icons.favorite_outline),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF171411),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AD4AF37)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.sansBody(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 4),
                  const Text("Tap to view details", style: TextStyle(fontSize: 10, color: Colors.white24)),
                ],
              ),
            ],
          ),
          Text(
            val,
            style: GoogleFonts.italiana(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePortfolioCard(String title, String imageUrl) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF171411),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AD4AF37)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? AppImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.black38),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.favorite_outline, color: const Color(0xFFD4AF37).withValues(alpha: 0.8), size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x1AD4AF37),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("PORTFOLIO", style: TextStyle(fontSize: 8, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.italiana(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String desc) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF171411),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.serifHeader(fontSize: 15, color: const Color(0xFFD4AF37)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.local_offer_outlined, color: Color(0xFFD4AF37), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
