import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Event Gallery view for customers displaying shared assets in Album/Carousel views.
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
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My Event Gallery", style: AppTheme.serifHeader(fontSize: 24)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.grid_view, color: isGridView ? const Color(0xFFC9A77E) : Colors.white60),
                    onPressed: () => setState(() => isGridView = true),
                  ),
                  IconButton(
                    icon: Icon(Icons.view_carousel, color: !isGridView ? const Color(0xFFC9A77E) : Colors.white60),
                    onPressed: () => setState(() => isGridView = false),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download_for_offline_outlined, size: 16),
                    label: const Text("Download All"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A77E), foregroundColor: const Color(0xFF091210)),
                    onPressed: () {
                      Get.snackbar("Exporting Gallery", "Preparing zip download of all decoration assets...");
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (widget.controller.rxSelectedBookingGallery.isEmpty) {
                return const Center(child: Text("No event gallery collections mapped yet. Expand your Booking detail tab to fetch gallery items."));
              }
              final gallery = widget.controller.rxSelectedBookingGallery.first;
              
              if (isGridView) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: gallery.mediaUrls.length,
                  itemBuilder: (context, index) {
                    final url = gallery.mediaUrls[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC9A77E).withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white24),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              radius: 14,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.download, color: Color(0xFFC9A77E), size: 14),
                                onPressed: () => Get.snackbar("Download Status", "Preparing download link..."),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              } else {
                return PageView.builder(
                  itemCount: gallery.mediaUrls.length,
                  itemBuilder: (context, index) {
                    final url = gallery.mediaUrls[index];
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFC9A77E), width: 2),
                        ),
                        child: Image.network(url, fit: BoxFit.contain),
                      ),
                    );
                  },
                );
              }
            }),
          )
        ],
      ),
    );
  }
}
