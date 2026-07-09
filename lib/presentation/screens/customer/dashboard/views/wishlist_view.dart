import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../core/widgets/app_image.dart';

/// Wishlist items management view for customers.
class WishlistView extends StatelessWidget {
  final CustomerDashboardController controller;

  const WishlistView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final catalogCtrl = Get.find<CatalogController>();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MY FAVORITES",
                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                "Inspiration Board",
                style: GoogleFonts.italiana(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Obx(() {
              if (controller.rxWishlist.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_outline, color: Colors.white24, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "No items saved yet. Save items from the Home portal.",
                        style: AppTheme.sansBody(fontSize: 14, color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.82,
                ),
                itemCount: controller.rxWishlist.length,
                itemBuilder: (context, index) {
                  final wish = controller.rxWishlist[index];
                  final exp = catalogCtrl.rxExperiences.firstWhereOrNull((e) => e.slug == wish.experienceId);
                  final title = exp?.name ?? wish.experienceId;
                  final category = exp?.categoryName ?? "DECORATION";
                  final imageUrl = exp?.imageUrl ?? "";

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF171411),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x1AD4AF37)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                imageUrl.isNotEmpty
                                    ? AppImage(
                                        url: imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(color: Colors.white10),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFC95C5C)),
                                      onPressed: () => controller.removeWishlist(wish.id),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.toUpperCase(),
                                style: const TextStyle(fontSize: 8, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.0),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.italiana(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
