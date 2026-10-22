import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../domain/entities/experience.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../widgets/customer_booking_dialog.dart';

class ServiceAreaBottomCta extends StatelessWidget {
  final Color goldColor;
  final bool isMobile;

  const ServiceAreaBottomCta({
    super.key,
    required this.goldColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E19),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withValues(alpha: 0.25)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Planning a Celebration in Your City?",
                textAlign: TextAlign.center,
                style: GoogleFonts.italiana(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Our team will personally review your venue location and confirm slot availability.",
                textAlign: TextAlign.center,
                style: AppTheme.sansBody(
                  fontSize: isMobile ? 10.5 : 11.5,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 14),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined, size: 14),
                  label: const Text("BOOK EVENT AT YOUR VENUE"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: const Color(0xFF091210),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    textStyle: AppTheme.sansBody(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Experience? exp;
                    if (Get.isRegistered<CatalogController>()) {
                      final experiences =
                          Get.find<CatalogController>().rxExperiences;
                      if (experiences.isNotEmpty) exp = experiences.first;
                    }
                    if (exp != null) {
                      showCustomerBookingDialog(
                        context,
                        experience: exp,
                        selectedPackage: exp.dynamicPackages.first,
                      );
                    } else {
                      Get.offAllNamed(AppRoutes.home);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
