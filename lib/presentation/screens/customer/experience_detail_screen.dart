import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../../domain/entities/package_option.dart';
import 'experience_detail/experience_hero_image.dart';
import 'experience_detail/experience_not_found_card.dart';
import 'experience_detail/experience_service_details.dart';

class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({super.key});

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final _notesController = TextEditingController();
  String _selectedColor = '';
  String _selectedTheme = '';
  PackageOption? _selectedPackage;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _cardBgColor = Color(0xFF09120E);
  static const Color _inputBgColor = Color(0xFF0D1713);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildBackNavigation(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).canPop()
          ? Navigator.of(context).pop()
          : Get.offAllNamed(AppRoutes.home),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1814),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _goldColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 12,
              color: _goldColor,
            ),
            const SizedBox(width: 8),
            Text(
              "Back to Experiences",
              style: AppTheme.sansBody(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _goldColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slug = Get.parameters['slug'];
    final catalogController = Get.find<CatalogController>();
    final cartController = Get.find<CartController>();
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 900;
    final bool isMobile = width < 600;

    return Obx(() {
      if (catalogController.isLoadingExperiences.value &&
          catalogController.rxExperiences.isEmpty) {
        return Scaffold(
          backgroundColor: const Color(0xFF070C0A),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: _goldColor),
                const SizedBox(height: 16),
                Text(
                  "Loading Experience Details...",
                  style: AppTheme.sansBody(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      }

      final item = catalogController.rxExperiences.firstWhereOrNull(
        (element) => element.slug == slug,
      );

      if (item == null) {
        return const Scaffold(
          backgroundColor: Color(0xFF070C0A),
          body: ExperienceNotFoundCard(
            goldColor: _goldColor,
            cardBgColor: _cardBgColor,
          ),
        );
      }

      if (_selectedColor.isEmpty && item.colors.isNotEmpty) {
        _selectedColor = item.colors.first;
      }
      if (_selectedTheme.isEmpty && item.themes.isNotEmpty) {
        _selectedTheme = item.themes.first;
      }
      if (_selectedPackage == null && item.dynamicPackages.isNotEmpty) {
        _selectedPackage = item.dynamicPackages.first;
      }

      final currentPkg =
          _selectedPackage ??
          (item.dynamicPackages.isNotEmpty ? item.dynamicPackages.first : null);
      final isLargeDesktop = width >= 1440;
      final double hPadding =
          isLargeDesktop ? 56 : (isDesktop ? 40 : (isMobile ? 16 : 24));
      final double imageDesktopHeight = (MediaQuery.of(context).size.height *
              0.72)
          .clamp(520.0, 600.0);

      final heroImage = ExperienceHeroImage(
        item: item,
        height: isDesktop ? imageDesktopHeight : (isMobile ? 320 : 420),
        goldColor: _goldColor,
      );
      final serviceDetails = ExperienceServiceDetails(
        item: item,
        currentPkg: currentPkg,
        cartController: cartController,
        selectedColor: _selectedColor,
        selectedTheme: _selectedTheme,
        notesController: _notesController,
        onSelectPackage: (pkg) => setState(() => _selectedPackage = pkg),
        onColorChanged:
            (val) => val != null ? setState(() => _selectedColor = val) : null,
        onThemeChanged:
            (val) => val != null ? setState(() => _selectedTheme = val) : null,
        isDesktop: isDesktop,
        goldColor: _goldColor,
        inputBgColor: _inputBgColor,
      );

      return Scaffold(
        backgroundColor: const Color(0xFF070C0A),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: isDesktop ? 24 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackNavigation(context),
                const SizedBox(height: 22),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 44, child: heroImage),
                      const SizedBox(width: 36),
                      Expanded(flex: 56, child: serviceDetails),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heroImage,
                      const SizedBox(height: 22),
                      serviceDetails,
                    ],
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      );
    });
  }
}
