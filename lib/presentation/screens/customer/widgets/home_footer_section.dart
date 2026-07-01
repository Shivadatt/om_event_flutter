import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:om_event/core/config/app_routes.dart';
import 'package:om_event/core/config/app_theme.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDesktop
                  ? Row(
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
                                "OM EVENTS",
                                style: AppTheme.sansBody(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Moments pass. Beautiful ones echo.",
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
                                "Branch - 1: Medha (kadi-kalyanpura road),\nBranch - 2: Thangadh (Surendranagar)\nGujarat, India 382715",
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  color: Colors.white60,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () =>
                                    launchUrl(Uri.parse("tel:+919512149944")),
                                child: Text(
                                  "+91 95121 49944",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    launchUrl(Uri.parse("tel:+919313513156")),
                                child: Text(
                                  "+91 93135 13156",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    "mailto:omeventsanddecorators@gmail.com",
                                  ),
                                ),
                                child: Text(
                                  "omeventsanddecorators\n@gmail.com",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: Colors.white60,
                                    height: 1.4,
                                  ),
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
                                "FOLLOW THE WONDER",
                                style: AppTheme.sansBody(
                                  fontSize: 9,
                                  color: const Color(0xFFC9A77E),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _footerLink(
                                "Instagram - Kadi ↗",
                                () => launchUrl(
                                  Uri.parse(
                                    "https://www.instagram.com/om_events_and_decorators/",
                                  ),
                                ),
                              ),
                              _footerLink(
                                "Instagram - Thangadh ↗",
                                () => launchUrl(
                                  Uri.parse(
                                    "https://www.instagram.com/om_events__decorators/",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
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
                          "OM EVENTS",
                          style: AppTheme.sansBody(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Moments pass. Beautiful ones echo.",
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
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                                  _footerLink("Experiences", () {
                                    final ctx = catalogKey.currentContext;
                                    if (ctx != null) {
                                      Scrollable.ensureVisible(
                                        ctx,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }),
                                  _footerLink("Stories", () {
                                    final ctx = storiesKey.currentContext;
                                    if (ctx != null) {
                                      Scrollable.ensureVisible(
                                        ctx,
                                        duration:
                                            const Duration(milliseconds: 500),
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
                                  _footerLink(
                                    "Instagram - Kadi ↗",
                                    () => launchUrl(
                                      Uri.parse(
                                        "https://www.instagram.com/om_events_and_decorators/",
                                      ),
                                    ),
                                  ),
                                  _footerLink(
                                    "Instagram - Thangadh ↗",
                                    () => launchUrl(
                                      Uri.parse(
                                        "https://www.instagram.com/om_events__decorators/",
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
                          "Branch - 1: Medha (kadi-kalyanpura road),\nBranch - 2: Thangadh (Surendranagar)\nGujarat, India 382715",
                          style: AppTheme.sansBody(
                            fontSize: 11,
                            color: Colors.white60,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse("tel:+919512149944")),
                          child: Text(
                            "+91 95121 49944",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse("tel:+919313513156")),
                          child: Text(
                            "+91 93135 13156",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => launchUrl(
                            Uri.parse(
                              "mailto:omeventsanddecorators@gmail.com",
                            ),
                          ),
                          child: Text(
                            "omeventsanddecorators@gmail.com",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 48),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "© 2026 Om Events. Made with care in Gujarat.",
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      color: Colors.white30,
                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
