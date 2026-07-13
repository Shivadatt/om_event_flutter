import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/widgets/custom_button.dart';
import 'package:om_event/presentation/controllers/catalog_controller.dart';
import 'package:om_event/presentation/screens/customer/helpers/customer_dialog_helper.dart';

class ContactSection extends StatelessWidget {
  final CatalogController controller;
  final GlobalKey contactKey;
  final bool isDesktop;

  const ContactSection({
    super.key,
    required this.controller,
    required this.contactKey,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Container(
      key: contactKey,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: isDesktop ? 72 : 48,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF152621), Color(0xFF1B2D27)], // Deep Emerald Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.secondaryAccent.withValues(alpha: 0.15),
            width: 1.2,
          ),
          bottom: BorderSide(
            color: AppColors.secondaryAccent.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "HAVE SOMETHING ELSE IN MIND?",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: AppColors.secondaryAccent,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Let’s make room for the unexpected.",
                            style: GoogleFonts.italiana(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tell us the dream, the venue, and the budget outline. We’ll compose a signature celebration together.",
                            style: AppTheme.sansBody(
                              fontSize: 14.5,
                              color: AppColors.muted,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 28),
                          CustomButton(
                            text: "Start a Conversation",
                            isPrimary: false,
                            onPressed: () => CustomerDialogHelper.openLeadDialog(context),
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
                      "HAVE SOMETHING ELSE IN MIND?",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: AppColors.secondaryAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Let’s make room for the unexpected.",
                      style: GoogleFonts.italiana(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Tell us the dream, the venue, and the budget outline. We’ll compose a signature celebration together.",
                      style: AppTheme.sansBody(
                        fontSize: 14,
                        color: AppColors.muted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: "Start a Conversation",
                      isPrimary: false,
                      onPressed: () => CustomerDialogHelper.openLeadDialog(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
