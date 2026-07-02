import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/services/app_config_service.dart';
import '../../../../core/services/business_details_service.dart';
import '../../../../domain/entities/business_details_entity.dart';

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
                  (b) =>
                      "${b.branchName}\n${b.fullAddress}",
                )
                .join("\n\n");

            if (isDesktop) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "OE",
                              style: AppTheme.serifHeader(
                                fontSize: 28,
                                color: const Color(0xFFC9A77E),
                              ),
                            ),
                            Text(
                              details.general.businessName.toUpperCase(),
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              footer.description,
                              style: AppTheme.serifHeader(
                                fontSize: 14,
                                color: const Color(0xFFC9A77E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EXPLORE",
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                color: const Color(0xFFC9A77E),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _footerLink("Collections", () {
                              final ctx = categoriesKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }),
                            _footerLink("Experiences", () {
                              final ctx = catalogKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }),
                            _footerLink("Stories", () {
                              final ctx = storiesKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }),
                            _footerLink(
                              "API docs",
                              () => Get.toNamed(AppRoutes.docs),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "VISIT",
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                color: const Color(0xFFC9A77E),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              branchesText.isNotEmpty ? branchesText : "",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                color: Colors.white60,
                                height: 1.4,
                              ),
                            ),
                             const SizedBox(height: 12),
                             if (activePhones.length > 1) ...[
                               Text(
                                 "CALL US",
                                 style: AppTheme.sansBody(
                                   fontSize: 9,
                                   color: const Color(0xFFC9A77E),
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: 1.5,
                                 ),
                               ),
                               const SizedBox(height: 8),
                             ],
                             ...activePhones.map((cn) {
                               final cleanVal = cn.value.replaceAll(RegExp(r'\D'), '');
                               final displayVal = cleanVal.length == 10 ? '+91 $cleanVal' : (cleanVal.length == 12 && cleanVal.startsWith('91') ? '+91 ${cleanVal.substring(2)}' : cn.value);
                               final linkVal = cleanVal.length == 10 ? '91$cleanVal' : cleanVal;
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: InkWell(
                                   onTap: () => launchUrl(Uri.parse("tel:+$linkVal")),
                                   child: Text(
                                     "${cn.label}: $displayVal",
                                     style: AppTheme.sansBody(
                                       fontSize: 11,
                                       color: Colors.white60,
                                     ),
                                   ),
                                 ),
                               );
                             }),
                             const SizedBox(height: 12),
                             ...activeEmails.map((em) {
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: InkWell(
                                   onTap: () => launchUrl(Uri.parse("mailto:${em.value}")),
                                   child: Text(
                                     em.value,
                                     style: AppTheme.sansBody(
                                       fontSize: 11,
                                       color: Colors.white60,
                                       height: 1.4,
                                     ),
                                   ),
                                 ),
                               );
                             }),
                           ],
                         ),
                       ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "FOLLOW THE WONDER",
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                color: const Color(0xFFC9A77E),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (details.social.instagramKadi.isNotEmpty)
                              _footerLink(
                                "Instagram – Kadi ↗",
                                () => launchUrl(
                                  Uri.parse(
                                    details.social.instagramKadi,
                                  ),
                                ),
                              ),
                            if (details.social.instagramThangadh.isNotEmpty)
                              _footerLink(
                                "Instagram – Thangadh ↗",
                                () => launchUrl(
                                  Uri.parse(
                                    details.social.instagramThangadh,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  _buildBottomBar(footer.copyright),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OE",
                    style: AppTheme.serifHeader(
                      fontSize: 24,
                      color: const Color(0xFFC9A77E),
                    ),
                  ),
                  Text(
                    details.general.businessName.toUpperCase(),
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    footer.description,
                    style: AppTheme.serifHeader(
                      fontSize: 16,
                      color: const Color(0xFFC9A77E),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EXPLORE",
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                color: const Color(0xFFC9A77E),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _footerLink("Collections", () {
                              final ctx = categoriesKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }),
                            _footerLink("Experiences", () {
                              final ctx = catalogKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }),
                            _footerLink("Stories", () {
                              final ctx = storiesKey.currentContext;
                              if (ctx != null) {
                                Scrollable.ensureVisible(
                                  ctx,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }),
                            _footerLink(
                              "API docs",
                              () => Get.toNamed(AppRoutes.docs),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "FOLLOW THE WONDER",
                              style: AppTheme.sansBody(
                                fontSize: 9,
                                color: const Color(0xFFC9A77E),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (details.social.instagramKadi.isNotEmpty)
                              _footerLink(
                                "Instagram – Kadi ↗",
                                () => launchUrl(
                                  Uri.parse(
                                    details.social.instagramKadi,
                                  ),
                                ),
                              ),
                            if (details.social.instagramThangadh.isNotEmpty)
                              _footerLink(
                                "Instagram – Thangadh ↗",
                                () => launchUrl(
                                  Uri.parse(
                                    details.social.instagramThangadh,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "VISIT",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: const Color(0xFFC9A77E),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    branchesText.isNotEmpty ? branchesText : "",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (activePhones.length > 1) ...[
                    Text(
                      "CALL US",
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        color: const Color(0xFFC9A77E),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...activePhones.map((cn) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse("tel:${cn.value}")),
                        child: Text(
                          "${cn.label}: ${cn.value}",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  ...details.contacts.emails.where((e) => e.isActive).map((em) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse("mailto:${em.value}")),
                        child: Text(
                          em.value,
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 48),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  _buildBottomBar(footer.copyright),
                ],
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
