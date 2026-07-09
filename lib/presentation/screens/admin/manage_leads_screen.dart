import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';

class ManageLeadsScreen extends GetView<AdminController> {
  const ManageLeadsScreen({super.key});

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 3; // Desktop
    if (width > 800) return 2;  // Laptop/Tablet
    return 1;                   // Mobile
  }

  double _getChildAspectRatio(int crossAxisCount, double width) {
    final double cardWidth = (width - 64 - (crossAxisCount - 1) * 24) / crossAxisCount;
    return cardWidth / 420; // Proportion for full height Inquiry Boards
  }

  String _getEventCoverUrl(String requestType, int index) {
    final List<String> covers = [
      'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=600', // Stage Setup
      'https://images.unsplash.com/photo-1507504038482-76210062ecee?q=80&w=600', // Romantic Dinner table
      'https://images.unsplash.com/photo-1541976844346-f18aeac57b06?q=80&w=600', // Pathway
      'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=600', // Party Decor
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=600', // Luxury Ballroom
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=600', // Ring stage
      'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?q=80&w=600', // Inside Canopy
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=600', // Gold Balloon Arch
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=600', // Evening Lights
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?q=80&w=600', // Candle pathway
    ];
    return covers[index % covers.length];
  }

  String _cleanText(String text) {
    String cleaned = text.replaceAll('bWedding/b', 'Wedding')
                         .replaceAll('bBirthday/b', 'Birthday')
                         .replaceAll('bBaby Shower/b', 'Baby Shower')
                         .replaceAll('bCandle Light/b', 'Candle Light Dinner')
                         .replaceAll('bCorporate/b', 'Corporate Event');
    // Strip HTML tags
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');
    // Clean starting 'b' and ending '/b'
    final match = RegExp(r'^b(.+)/b$').firstMatch(cleaned);
    if (match != null) {
      cleaned = match.group(1) ?? cleaned;
    }
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryAccent = AppColors.primaryAccent;
    final Color cardColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color subtitleColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final bool isInsideDrawer = AdminLayoutScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: isInsideDrawer ? null : const AdminBackButton(),
        automaticallyImplyLeading: !isInsideDrawer,
        title: Text(
          "INQUIRY SHOWCASE",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final leads = controller.rxLeads;
        if (leads.isEmpty) {
          return const Center(child: Text("No inquiries registered yet."));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final aspect = _getChildAspectRatio(crossAxisCount, constraints.maxWidth);

            return GridView.builder(
              padding: const EdgeInsets.all(32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: aspect > 0 ? aspect : 1.1,
              ),
              itemCount: leads.length,
              itemBuilder: (context, index) {
                final lead = leads[index];
                final String coverUrl = _getEventCoverUrl(lead.requestType, index);
                final String cleanType = _cleanText(lead.requestType);

                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Event Cover
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.darkForestSecondary,
                                          AppColors.darkPaper,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.celebration_rounded,
                                        color: primaryAccent.withValues(alpha: 0.4),
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Gradient Overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.1),
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            // Event Type Badge
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24, width: 0.5),
                                ),
                                child: Text(
                                  cleanType.toUpperCase(),
                                  style: AppTheme.sansBody(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: primaryAccent,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            // Budget Ribbon
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  lead.budget != null
                                      ? AppFormatters.formatCurrency(lead.budget!)
                                      : 'CUSTOM BUDGET',
                                  style: AppTheme.sansBody(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            // Title & Client Name overlay bottom
                            Positioned(
                              bottom: 16,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lead.name,
                                    style: AppTheme.serifHeader(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${lead.phone} • ${lead.email}",
                                    style: AppTheme.sansBody(
                                      fontSize: 11,
                                      color: const Color(0xFFFAF6EE).withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Inquiry details & status workflow controls
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (lead.requirements.isNotEmpty) ...[
                              Text(
                                lead.requirements,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.sansBody(
                                  fontSize: 12,
                                  color: subtitleColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 14, color: primaryAccent),
                                    const SizedBox(width: 6),
                                    Text(
                                      lead.eventDate != null
                                          ? AppFormatters.formatShortDate(lead.eventDate!)
                                          : 'TBD',
                                      style: AppTheme.sansBody(
                                        fontSize: 11,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                                // Glass status progression selector
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkForestSecondary : AppColors.lightForestSecondary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: lead.status,
                                      icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                      items: const [
                                        DropdownMenuItem(value: 'new', child: Text("New")),
                                        DropdownMenuItem(value: 'contacted', child: Text("Contacted")),
                                        DropdownMenuItem(value: 'qualified', child: Text("Qualified")),
                                        DropdownMenuItem(value: 'won', child: Text("Won")),
                                        DropdownMenuItem(value: 'closed', child: Text("Closed")),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.updateLead(lead.id, val);
                                        }
                                      },
                                      style: AppTheme.sansBody(fontSize: 12, color: textColor),
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
                );
              },
            );
          },
        );
      }),
    );
  }
}
