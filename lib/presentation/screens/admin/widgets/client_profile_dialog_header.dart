import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

class ClientProfileDialogHeader extends StatelessWidget {
  final String clientName;
  final TabController tabController;
  final bool isMobile;

  const ClientProfileDialogHeader({
    super.key,
    required this.clientName,
    required this.tabController,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final Color primaryAccent = AppColors.primaryAccent;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 28,
        isMobile ? 20 : 24,
        isMobile ? 20 : 28,
        0,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  clientName.toUpperCase(),
                  style: GoogleFonts.italiana(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: textColor.withValues(alpha: 0.6),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 20,
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: primaryAccent,
            unselectedLabelColor: textColor.withValues(alpha: 0.4),
            indicatorColor: primaryAccent,
            indicatorWeight: 1.5,
            labelStyle: AppTheme.sansBody(
              fontSize: isMobile ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            unselectedLabelStyle: AppTheme.sansBody(
              fontSize: isMobile ? 9 : 10,
              letterSpacing: 1.2,
            ),
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: "PROFILE"),
              Tab(text: "INQUIRIES"),
              Tab(text: "MEDIA"),
            ],
          ),
        ],
      ),
    );
  }
}
