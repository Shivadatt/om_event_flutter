part of '../home_footer_section.dart';

extension FooterGrid on FooterSection {
  Widget _buildDesktopFooter(
    BusinessDetailsEntity details,
    dynamic footer,
    List<ContactItemEntity> activePhones,
    List<ContactItemEntity> activeEmails,
    String branchesText,
  ) {
    final accentColor = AppColors.secondaryAccent; // Champagne Gold

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brand Column
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandLogo(accentColor),
                  const SizedBox(height: 18),
                  Text(
                    details.general.businessName.toUpperCase(),
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Moments pass. Beautiful ones echo.",
                    style: GoogleFonts.italiana(
                      fontSize: 16,
                      color: accentColor.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    footer.description,
                    style: AppTheme.sansBody(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.5),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 60),

            // Explore Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("EXPLORE", accentColor),
                  const SizedBox(height: 18),
                  _FooterLink(
                    label: "Collections",
                    onTap: () {
                      final ctx = categoriesKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  _FooterLink(
                    label: "Experiences",
                    onTap: () {
                      final ctx = catalogKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  _FooterLink(
                    label: "Stories",
                    onTap: () {
                      final ctx = storiesKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),

            // Visit Column (Addresses)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("VISIT US", accentColor),
                  const SizedBox(height: 18),
                  if (branchesText.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: accentColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            branchesText,
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.65),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 40),

            // Contact Column (Phones, Email, Socials)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("GET IN TOUCH", accentColor),
                  const SizedBox(height: 18),
                  // Phone list
                  ...activePhones.map((cn) {
                    final cleanVal = cn.value.replaceAll(RegExp(r'\D'), '');
                    final displayVal = cleanVal.length == 10
                        ? '+91 $cleanVal'
                        : (cleanVal.length == 12 && cleanVal.startsWith('91')
                            ? '+91 ${cleanVal.substring(2)}'
                            : cn.value);
                    final linkVal = cleanVal.length == 10 ? '91$cleanVal' : cleanVal;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse("tel:+$linkVal")),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: accentColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${cn.label}: $displayVal",
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  // Email list
                  ...activeEmails.map((em) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse("mailto:${em.value}")),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 14,
                              color: accentColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              em.value,
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  // Instagram
                  if (details.social.instagramKadi.isNotEmpty)
                    _FooterLink(
                      label: "Instagram - Kadi ↗",
                      onTap: () => launchUrl(Uri.parse(details.social.instagramKadi)),
                    ),
                  if (details.social.instagramThangadh.isNotEmpty)
                    _FooterLink(
                      label: "Instagram - Thangadh ↗",
                      onTap: () => launchUrl(Uri.parse(details.social.instagramThangadh)),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 56),
        Divider(color: accentColor.withValues(alpha: 0.12), height: 1.2),
        const SizedBox(height: 24),
        _buildBottomBar(footer.copyright),
      ],
    );
  }

  Widget _buildMobileFooter(
    BusinessDetailsEntity details,
    dynamic footer,
    List<ContactItemEntity> activePhones,
    List<ContactItemEntity> activeEmails,
    String branchesText,
  ) {
    final accentColor = AppColors.secondaryAccent; // Champagne Gold

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandLogo(accentColor),
        const SizedBox(height: 16),
        Text(
          details.general.businessName.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          footer.description,
          style: AppTheme.sansBody(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("EXPLORE", accentColor),
                  const SizedBox(height: 14),
                  _FooterLink(
                    label: "Collections",
                    onTap: () {
                      final ctx = categoriesKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  _FooterLink(
                    label: "Experiences",
                    onTap: () {
                      final ctx = catalogKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  _FooterLink(
                    label: "Stories",
                    onTap: () {
                      final ctx = storiesKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("FOLLOW", accentColor),
                  const SizedBox(height: 14),
                  if (details.social.instagramKadi.isNotEmpty)
                    _FooterLink(
                      label: "Instagram - Kadi ↗",
                      onTap: () => launchUrl(Uri.parse(details.social.instagramKadi)),
                    ),
                  if (details.social.instagramThangadh.isNotEmpty)
                    _FooterLink(
                      label: "Instagram - Thangadh ↗",
                      onTap: () => launchUrl(Uri.parse(details.social.instagramThangadh)),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),
        _buildSectionHeader("VISIT US", accentColor),
        const SizedBox(height: 14),
        if (branchesText.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: accentColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  branchesText,
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 32),
        _buildSectionHeader("CONTACT", accentColor),
        const SizedBox(height: 14),
        ...activePhones.map((cn) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => launchUrl(Uri.parse("tel:${cn.value}")),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: accentColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${cn.label}: ${cn.value}",
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        ...activeEmails.map((em) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => launchUrl(Uri.parse("mailto:${em.value}")),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 13,
                    color: accentColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    em.value,
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 40),
        Divider(color: accentColor.withValues(alpha: 0.12), height: 1.2),
        const SizedBox(height: 20),
        _buildBottomBar(footer.copyright),
      ],
    );
  }

  // Double ring elegant gold brand logo
  Widget _buildBrandLogo(Color accentColor) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: accentColor,
            width: 1.5,
          ),
          gradient: RadialGradient(
            colors: [
              accentColor.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "OE",
          style: GoogleFonts.italiana(
            fontSize: 17,
            color: accentColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Clean Section Header with small Gold Underscore Line
  Widget _buildSectionHeader(String title, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.sansBody(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 20,
          height: 1.5,
          color: accentColor,
        ),
      ],
    );
  }
}
