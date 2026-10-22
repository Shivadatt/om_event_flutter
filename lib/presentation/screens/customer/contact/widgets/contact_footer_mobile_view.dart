import 'package:flutter/material.dart';
import 'contact_footer_brand_block.dart';
import 'contact_footer_contact_columns.dart';
import 'contact_footer_decorative_arch.dart';
import 'contact_footer_nav_links.dart';

class ContactFooterMobileView extends StatelessWidget {
  final Color goldColor;
  final bool isTablet;
  final List<String> branchLines;
  final String primaryPhone;
  final String secondaryPhone;
  final String primaryEmail;
  final String instagramKadi;
  final String instagramThangadh;

  const ContactFooterMobileView({
    super.key,
    required this.goldColor,
    required this.isTablet,
    required this.branchLines,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.primaryEmail,
    required this.instagramKadi,
    required this.instagramThangadh,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ContactFooterBrandBlock(goldColor: goldColor)),
                const SizedBox(width: 18),
                SizedBox(
                  width: 145,
                  height: 160,
                  child: ContactFooterDecorativeArch(
                    goldColor: goldColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ContactFooterExploreColumn(goldColor: goldColor),
                ),
                const SizedBox(width: 18),
                Expanded(child: ContactFooterHelpColumn(goldColor: goldColor)),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ContactFooterVisitUsColumn(
                    branches: branchLines,
                    goldColor: goldColor,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
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
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContactFooterBrandBlock(goldColor: goldColor),
          const SizedBox(height: 16),
          Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          ContactFooterExploreColumn(goldColor: goldColor),
          const SizedBox(height: 16),
          Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          ContactFooterHelpColumn(goldColor: goldColor),
          const SizedBox(height: 16),
          Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          ContactFooterVisitUsColumn(
            branches: branchLines,
            goldColor: goldColor,
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: goldColor.withValues(alpha: 0.18)),
          const SizedBox(height: 16),
          ContactFooterGetInTouchColumn(
            p1: primaryPhone,
            p2: secondaryPhone,
            email: primaryEmail,
            instaKadi: instagramKadi,
            instaThangadh: instagramThangadh,
            goldColor: goldColor,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 110,
            child: ContactFooterDecorativeArch(
              goldColor: goldColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}
