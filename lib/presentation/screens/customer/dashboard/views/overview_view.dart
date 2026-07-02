import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Upgraded OverviewView with Emergency CMS announcements, announcement bars, and recently viewed themes.
class OverviewView extends StatelessWidget {
  final CustomerDashboardController controller;

  const OverviewView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeBookings = controller.rxBookings.length;
      final totalQuotes = controller.rxQuotations.length;
      final wishlistCount = controller.rxWishlist.length;

      // Event countdown calculation
      String countdownText = 'No upcoming event booked';
      if (controller.rxBookings.isNotEmpty) {
        final nextEvent = controller.rxBookings.first.date;
        final diff = nextEvent.difference(DateTime.now()).inDays;
        countdownText = diff > 0 ? "$diff Days remaining!" : "Event is today!";
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Website CMS Announcement Bar (Module 10)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              color: const Color(0xFFC9A77E),
              child: const Center(
                child: Text(
                  "🔥 FESTIVAL SPECIAL CAMPAIGN: Use coupon FEST10 for 10% off!",
                  style: TextStyle(color: Color(0xFF091210), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),

            // Emergency Notice Banner (Module 10)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "EMERGENCY NOTICE: Heavy rainfall warning. Coordination teams are preparing indoor contingencies.",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Dashboard Overview", style: AppTheme.serifHeader(fontSize: 24)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12271F),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFC9A77E)),
                  ),
                  child: const Text("Ref Code: OM-REF552", style: TextStyle(color: Color(0xFFC9A77E), fontWeight: FontWeight.bold, fontSize: 13)),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Main Stat Cards Row
            Row(
              children: [
                Expanded(child: _buildStatCard("Active Bookings", activeBookings.toString(), Icons.event_available)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("Quotations", totalQuotes.toString(), Icons.description_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("Wishlist Items", wishlistCount.toString(), Icons.favorite)),
              ],
            ),
            const SizedBox(height: 24),

            // Countdown & Loyalty section
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12271F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text("Upcoming Event Countdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(countdownText, style: AppTheme.serifHeader(fontSize: 22, color: Colors.orange)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12271F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stars, color: Color(0xFFC9A77E), size: 20),
                            SizedBox(width: 8),
                            Text("Loyalty Rewards Program", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text("Platinum Tiers (1,500 Pts)", style: AppTheme.serifHeader(fontSize: 18, color: const Color(0xFFC9A77E))),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),

            // Realtime booking checklist items
            Text("My Booking Event Checklist", style: AppTheme.serifHeader(fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF12271F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  _ChecklistItem(title: "Venue Confirmation details", isChecked: true),
                  _ChecklistItem(title: "Flower Theme Decoration Selected", isChecked: true),
                  _ChecklistItem(title: "Photo & Video Team Mapped", isChecked: false),
                  _ChecklistItem(title: "Advance Deposit Paid", isChecked: false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recently Viewed Themes (Module 5)
            Text("Recently Viewed Themes", style: AppTheme.serifHeader(fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildThemeThumbnail("Floral Canopy Backdrop", "https://placeholder.url/floral.jpg"),
                  _buildThemeThumbnail("Marigold Entrance Arch", "https://placeholder.url/marigold.jpg"),
                  _buildThemeThumbnail("Minimalist Neon Stage", "https://placeholder.url/neon.jpg"),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Offers & Promotions Banner
            if (controller.rxOffers.isNotEmpty) ...[
              Text("Latest Offers & Promotions", style: AppTheme.serifHeader(fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.rxOffers.length,
                  itemBuilder: (context, index) {
                    final offer = controller.rxOffers[index];
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12271F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(offer.title, style: AppTheme.serifHeader(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            offer.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Real-time Action Activity Timeline logs
            Text("Recent Activity Timeline", style: AppTheme.serifHeader(fontSize: 18)),
            const SizedBox(height: 16),
            if (controller.rxActivity.isEmpty)
              Text("No activity logged yet.", style: AppTheme.sansBody(fontSize: 13, color: Colors.white54))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.rxActivity.length,
                itemBuilder: (context, index) {
                  final act = controller.rxActivity[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.radio_button_checked, color: Color(0xFFC9A77E), size: 16),
                    title: Text(act.status, style: AppTheme.serifHeader(fontSize: 14)),
                    subtitle: Text(act.details, style: AppTheme.sansBody(fontSize: 12, color: Colors.white54)),
                    trailing: Text(
                      act.updatedAt.toLocal().toString().split(' ').first,
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC9A77E), size: 24),
          const SizedBox(height: 16),
          Text(val, style: AppTheme.sansBody(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: AppTheme.sansBody(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildThemeThumbnail(String title, String placeholderUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12271F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.black26,
              child: const Center(child: Icon(Icons.photo_outlined, color: Colors.white38)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  const _ChecklistItem({required this.title, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(isChecked ? Icons.check_circle : Icons.radio_button_off, color: isChecked ? Colors.green : Colors.white30, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: isChecked ? Colors.white : Colors.white54, fontSize: 13, decoration: isChecked ? TextDecoration.lineThrough : null)),
        ],
      ),
    );
  }
}
