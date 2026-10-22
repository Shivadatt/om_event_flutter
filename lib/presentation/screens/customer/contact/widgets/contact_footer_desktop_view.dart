import 'package:flutter/material.dart';
import 'contact_footer_brand_block.dart';
import 'contact_footer_contact_columns.dart';
import 'contact_footer_decorative_arch.dart';
import 'contact_footer_nav_links.dart';

class ContactFooterDesktopView extends StatelessWidget {
  final Color goldColor;
  final bool isDesktop;
  final List<String> branchLines;
  final String primaryPhone;
  final String secondaryPhone;
  final String primaryEmail;
  final String instagramKadi;
  final String instagramThangadh;

  const ContactFooterDesktopView({
    super.key,
    required this.goldColor,
    required this.isDesktop,
    required this.branchLines,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.primaryEmail,
    required this.instagramKadi,
    required this.instagramThangadh,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24.0 : 18.0,
                20.0,
                isDesktop ? 14.0 : 10.0,
                20.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isDesktop ? 30 : 26,
                    child: ContactFooterBrandBlock(goldColor: goldColor),
                  ),
                  SizedBox(width: isDesktop ? 16 : 10),
                  Expanded(
                    flex: isDesktop ? 12 : 11,
                    child: ContactFooterExploreColumn(goldColor: goldColor),
                  ),
                  SizedBox(width: isDesktop ? 12 : 8),
                  Expanded(
                    flex: isDesktop ? 12 : 15,
                    child: ContactFooterHelpColumn(goldColor: goldColor),
                  ),
                  SizedBox(width: isDesktop ? 12 : 8),
                  ContactFooterVerticalDivider(goldColor: goldColor),
                  SizedBox(width: isDesktop ? 12 : 8),
                  Expanded(
                    flex: 22,
                    child: ContactFooterVisitUsColumn(
                      branches: branchLines,
                      goldColor: goldColor,
                    ),
                  ),
                  SizedBox(width: isDesktop ? 12 : 8),
                  ContactFooterVerticalDivider(goldColor: goldColor),
                  SizedBox(width: isDesktop ? 12 : 8),
                  Expanded(
                    flex: isDesktop ? 24 : 26,
                    child: ContactFooterGetInTouchColumn(
                      p1: primaryPhone,
                      p2: secondaryPhone,
                      email: primaryEmail,
                      instaKadi: instagramKadi,
                      instaThangadh: instagramThangadh,
                      goldColor: goldColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: isDesktop ? 145 : 115,
            child: ContactFooterDecorativeArch(goldColor: goldColor),
          ),
        ],
      ),
    );
  }
}
