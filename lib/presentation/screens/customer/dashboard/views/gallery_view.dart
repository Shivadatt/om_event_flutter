import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../controllers/catalog_controller.dart';
import '../../../../../core/widgets/app_image.dart';

class GalleryView extends StatefulWidget {
  final CustomerDashboardController controller;

  const GalleryView({
    super.key,
    required this.controller,
  });

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  String selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final catalogCtrl = Get.find<CatalogController>();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "STUDIO PORTFOLIO",
                    style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Luxury Event Gallery",
                    style: GoogleFonts.italiana(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download_for_offline_outlined, size: 16),
                label: const Text("DOWNLOAD ALL ASSETS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF091210),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Get.snackbar(
                    "Preparing Download",
                    "Zipping and compiling high-res event photography collections...",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF171411),
                    colorText: const Color(0xFFD4AF37),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters Row
          Row(
            children: ['ALL', 'WEDDINGS', 'BIRTHDAYS', 'RECEPTIONS'].map((filter) {
              final isActive = selectedFilter == filter;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF091210) : const Color(0xFFD4AF37),
                      letterSpacing: 0.5,
                    ),
                  ),
                  selected: isActive,
                  selectedColor: const Color(0xFFD4AF37),
                  backgroundColor: const Color(0xFF171411),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: isActive ? 1 : 0.3)),
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => selectedFilter = filter);
                    }
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Portfolio Masonry Grid
          Expanded(
            child: Obx(() {
              final experiences = catalogCtrl.rxExperiences.where((exp) {
                if (selectedFilter == 'ALL') return true;
                return exp.categoryName.toUpperCase() == selectedFilter;
              }).toList();

              if (experiences.isEmpty) {
                return const Center(
                  child: Text(
                    "No event gallery collections found for this category.",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
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
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  final exp = experiences[index];
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
                                exp.imageUrl.isNotEmpty
                                    ? AppImage(
                                        url: exp.imageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(color: Colors.black26),
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
                                      icon: const Icon(Icons.download, size: 14, color: Color(0xFFD4AF37)),
                                      onPressed: () {
                                        Get.snackbar("Downloading Asset", "Accessing high-res image link...");
                                      },
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
                                exp.categoryName.toUpperCase(),
                                style: const TextStyle(fontSize: 8, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1.0),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exp.name.toUpperCase(),
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
