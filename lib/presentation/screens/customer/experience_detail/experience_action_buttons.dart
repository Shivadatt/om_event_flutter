import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/package_option.dart';
import '../../../controllers/cart_controller.dart';
import '../helpers/customer_drawer_helper.dart';
import '../widgets/customer_booking_dialog.dart';

class ExperienceActionButtons extends StatelessWidget {
  final dynamic item;
  final PackageOption? currentPkg;
  final String selectedColor;
  final String selectedTheme;
  final TextEditingController notesController;
  final CartController cartController;
  final bool isDesktop;
  final Color goldColor;

  const ExperienceActionButtons({
    super.key,
    required this.item,
    required this.currentPkg,
    required this.selectedColor,
    required this.selectedTheme,
    required this.notesController,
    required this.cartController,
    required this.isDesktop,
    required this.goldColor,
  });

  Widget _buildBenefitItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_rounded, color: goldColor, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.sansBody(
            fontSize: 10.5,
            color: Colors.white60,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryBookingButton(BuildContext context) {
    final tierName = (currentPkg?.tier ?? 'basic').toUpperCase();

    return ElevatedButton(
      onPressed: () {
        final pkg =
            currentPkg ??
            (item.dynamicPackages.isNotEmpty
                ? item.dynamicPackages.first
                : null);
        if (pkg != null) {
          showCustomerBookingDialog(
            context,
            experience: item,
            selectedPackage: pkg,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: goldColor,
        foregroundColor: const Color(0xFF09120E),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        "BOOK THIS PACKAGE ($tierName)",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.sansBody(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF09120E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSecondaryAddButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        final experienceToCart =
            currentPkg != null
                ? item.copyWith(
                  price: currentPkg!.price,
                  offerPrice: currentPkg!.effectivePrice,
                )
                : item;
        cartController.addToCart(
          experienceToCart,
          color: selectedColor,
          theme: selectedTheme,
          notes: notesController.text,
        );
        CustomerDrawerHelper.openEventCanvas(context);
        Get.snackbar(
          "Added to Selection",
          "${item.name} added to your selection.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF171411),
          colorText: goldColor,
          margin: const EdgeInsets.all(16),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: goldColor,
        side: BorderSide(color: goldColor, width: 1.2),
        backgroundColor: const Color(0xFF0E1713),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        "ADD TO MY SELECTION",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.sansBody(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: goldColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _buildBenefitItem("Styling & Installation"),
            _buildBenefitItem("Teardown"),
            _buildBenefitItem("Dedicated Coordinator"),
          ],
        ),
        const SizedBox(height: 18),
        if (isDesktop)
          Row(
            children: [
              Expanded(flex: 3, child: _buildPrimaryBookingButton(context)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildSecondaryAddButton(context)),
            ],
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildPrimaryBookingButton(context),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _buildSecondaryAddButton(context),
              ),
            ],
          ),
      ],
    );
  }
}
