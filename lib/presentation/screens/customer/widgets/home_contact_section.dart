import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';
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
        vertical: 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8D623E), Color(0xFFBE9162)],
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
                            "Have something else in mind?",
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              color: const Color(0xFFF6DFC4),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Let’s make room for the unexpected.",
                            style: AppTheme.serifHeader(
                              fontSize: 36,
                              color: Colors.white,
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
                            "Tell us the dream, the venue, and the number you want to stay near. We’ll shape the rest together.",
                            style: AppTheme.sansBody(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                          CustomButton(
                            text: "Start a Conversation",
                            isPrimary: false,
                            onPressed: () =>
                                CustomerDialogHelper.openLeadDialog(context),
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
                      "Have something else in mind?",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: const Color(0xFFF6DFC4),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Let’s make room for the unexpected.",
                      style: AppTheme.serifHeader(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Tell us the dream, the venue, and the number you want to stay near. We’ll shape the rest together.",
                      style: AppTheme.sansBody(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: "Start a Conversation",
                      isPrimary: false,
                      onPressed: () =>
                          CustomerDialogHelper.openLeadDialog(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
