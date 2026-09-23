import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_routes.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../domain/entities/experience.dart';
import '../../../../../domain/entities/gallery_item.dart';
import '../../../../controllers/gallery_controller.dart';
import '../../widgets/customer_booking_dialog.dart';
import '../../widgets/home_detail_dialog.dart';

void showGalleryLightbox(BuildContext context, {required List<GalleryItem> items, required int initialIndex}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (_) => GalleryLightboxDialog(items: items, initialIndex: initialIndex),
  );
}

class GalleryLightboxDialog extends StatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const GalleryLightboxDialog({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<GalleryLightboxDialog> createState() => _GalleryLightboxDialogState();
}

class _GalleryLightboxDialogState extends State<GalleryLightboxDialog> {
  late int _currentIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.isEmpty ? 0 : widget.items.length - 1);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _currentIndex = 0); // Loop
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    } else {
      setState(() => _currentIndex = widget.items.length - 1); // Loop
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final item = widget.items[_currentIndex];
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final goldColor = const Color(0xFFD4AF37);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _next();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _prev();
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 12,
          vertical: isDesktop ? 30 : 20,
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          width: isDesktop ? 1100 : double.infinity,
          height: isDesktop ? 720 : MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content layout
              isDesktop
                  ? Row(
                      children: [
                        // Left 65%: Image viewer with interactive zoom
                        Expanded(
                          flex: 65,
                          child: _buildImageSection(item, goldColor),
                        ),
                        // Right 35%: Metadata & CTAs
                        Container(
                          width: 1.2,
                          color: goldColor.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          flex: 35,
                          child: _buildDetailsPane(item, goldColor),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile: Image on top
                        Expanded(
                          flex: 55,
                          child: _buildImageSection(item, goldColor),
                        ),
                        Container(
                          height: 1.2,
                          color: goldColor.withValues(alpha: 0.2),
                        ),
                        // Mobile: Details below
                        Expanded(
                          flex: 45,
                          child: _buildDetailsPane(item, goldColor),
                        ),
                      ],
                    ),

              // Close button (Top Right)
              Positioned(
                top: 14,
                right: 14,
                child: IconButton(
                  tooltip: "Close Viewer (Esc)",
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    hoverColor: goldColor.withValues(alpha: 0.2),
                  ),
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Counter indicator (Top Left)
              Positioned(
                top: 18,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${widget.items.length}",
                    style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(GalleryItem item, Color goldColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Zoomable & Pannable High-res Image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: AppImage(
                url: item.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Navigation arrows
        if (widget.items.length > 1) ...[
          Positioned(
            left: 12,
            child: IconButton(
              tooltip: "Previous Photo (Left Arrow)",
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xCC091210),
                shape: const CircleBorder(),
                side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
              ),
              icon: Icon(Icons.chevron_left_rounded, color: goldColor, size: 28),
              onPressed: _prev,
            ),
          ),
          Positioned(
            right: 12,
            child: IconButton(
              tooltip: "Next Photo (Right Arrow)",
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xCC091210),
                shape: const CircleBorder(),
                side: BorderSide(color: goldColor.withValues(alpha: 0.4)),
              ),
              icon: Icon(Icons.chevron_right_rounded, color: goldColor, size: 28),
              onPressed: _next,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsPane(GalleryItem item, Color goldColor) {
    Experience? matchedExp;
    if (Get.isRegistered<GalleryController>()) {
      matchedExp = GalleryController.to.findExperienceForGalleryItem(item);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Chip
          if (item.categoryName.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: goldColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                item.categoryName.toUpperCase(),
                style: AppTheme.sansBody(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Title
          Text(
            item.title,
            style: GoogleFonts.italiana(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    )
                  else
                    Text(
                      "Curated event decoration photography captured from real client celebrations crafted by Om Events & Decorators.",
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Tags
                  if (item.tags.isNotEmpty) ...[
                    Text(
                      "TAGS & THEMES",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: goldColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF152621),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            "#$tag",
                            style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white70),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Divider(color: Color(0x33D4AF37), height: 24),

          // Action Buttons: Connection to Service & Booking
          Column(
            children: [
              // Primary CTA: Book this Theme
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.event_available, size: 16),
                  label: const Text("BOOK THIS THEME"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: const Color(0xFF091210),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (matchedExp != null) {
                      showCustomerBookingDialog(
                        context,
                        experience: matchedExp,
                        selectedPackage: matchedExp.dynamicPackages.first,
                      );
                    } else {
                      // Synthetic experience to let user book this style seamlessly
                      final fallbackExp = Experience(
                        id: item.serviceId.isNotEmpty ? item.serviceId : 'gallery_${item.id}',
                        categoryId: item.categoryId,
                        categoryName: item.categoryName.isNotEmpty ? item.categoryName : 'Decor Theme',
                        categorySlug: item.categoryName.toLowerCase().replaceAll(' ', '-'),
                        name: item.title,
                        slug: item.title.toLowerCase().replaceAll(' ', '-'),
                        description: item.description,
                        price: 15000,
                        durationHours: 4,
                        popularity: 10,
                        rating: 5.0,
                        reviewCount: 1,
                        availability: 'available',
                        tags: item.tags,
                        colors: const [],
                        themes: [item.title],
                        imageUrl: item.imageUrl,
                        videoUrl: '',
                        isFeatured: false,
                        isActive: true,
                      );
                      showCustomerBookingDialog(
                        context,
                        experience: fallbackExp,
                        selectedPackage: fallbackExp.dynamicPackages.first,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Secondary CTA: View Full Service Details
              if (matchedExp != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_outward, size: 14),
                    label: const Text("VIEW SERVICE DETAILS"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: goldColor,
                      side: BorderSide(color: goldColor.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (matchedExp?.slug.isNotEmpty == true) {
                        Get.toNamed('${AppRoutes.detail}/${matchedExp!.slug}');
                      } else {
                        showExperienceDetailDialog(context, matchedExp!);
                      }
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
