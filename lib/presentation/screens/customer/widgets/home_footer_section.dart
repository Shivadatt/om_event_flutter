import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';
import '../../../../core/services/business_details_service.dart';
import '../../../../domain/entities/business_details_entity.dart';

part 'parts/footer_grid.dart';

class FooterSection extends StatelessWidget {
  final bool isDesktop;
  final GlobalKey categoriesKey;
  final GlobalKey catalogKey;
  final GlobalKey storiesKey;

  const FooterSection({
    super.key,
    required this.isDesktop,
    required this.categoriesKey,
    required this.catalogKey,
    required this.storiesKey,
  });

  Widget _footerLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 32.0;

    return Container(
      color: const Color(0xFF101815),
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Obx(() {
            final details = BusinessDetailsService.to.rxDetails.value;
            final footer = AppConfigService.to.rxFooterSettings.value;
            final activePhones = details.contacts.phones.where((c) => c.isActive).toList();
            final activeEmails = details.contacts.emails.where((e) => e.isActive).toList();

            final sortedBranches = List<BranchEntity>.from(
              details.branches.where((b) => b.isActive),
            );
            sortedBranches.sort(
              (a, b) => a.displayOrder.compareTo(b.displayOrder),
            );

            final branchesText = sortedBranches
                .map(
                  (b) => "${b.branchName}\n${b.fullAddress}",
                )
                .join("\n\n");

            if (isDesktop) {
              return _buildDesktopFooter(
                details,
                footer,
                activePhones,
                activeEmails,
                branchesText,
              );
            } else {
              return _buildMobileFooter(
                details,
                footer,
                activePhones,
                activeEmails,
                branchesText,
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildBottomBar(String copyright) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          copyright,
          style: AppTheme.sansBody(fontSize: 9, color: Colors.white30),
        ),
        Row(
          children: [
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.docs),
              child: Text(
                "DEVELOPER API",
                style: AppTheme.sansBody(
                  fontSize: 9,
                  color: const Color(0xFFC9A77E),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.login),
              child: Text(
                "TEAM STUDIO",
                style: AppTheme.sansBody(
                  fontSize: 9,
                  color: const Color(0xFFC9A77E),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
