import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../core/config/app_routes.dart';
import '../../../../../../core/widgets/app_image.dart';
import '../../../../../../domain/entities/experience.dart';
import '../../../../../../domain/entities/gallery_item.dart';
import '../../../widgets/customer_booking_dialog.dart';
import '../../../widgets/home_detail_dialog.dart';

Widget buildLightboxBlurredBackground(String imageUrl) {
  return Positioned.fill(
    child: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 1.15,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: AppImage(
                url: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.45)),
        ],
      ),
    ),
  );
}

Experience createFallbackGalleryExperience(GalleryItem item) {
  return Experience(
    id: item.serviceId.isNotEmpty ? item.serviceId : 'gallery_${item.id}',
    categoryId: item.categoryId,
    categoryName:
        item.categoryName.isNotEmpty ? item.categoryName : 'Decor Theme',
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
}

void showLightboxFavoriteSnackBar(
  BuildContext context,
  bool isFav,
  String title,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isFav ? "Saved to favorites: $title" : "Removed from favorites",
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
      ),
      backgroundColor: const Color(0xFF10201B),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

void copyAndShowLightboxShareSnackBar(
  BuildContext context,
  String imageUrl,
) {
  Clipboard.setData(ClipboardData(text: imageUrl));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Theme link copied to clipboard!",
        style: TextStyle(color: Colors.white, fontSize: 12.5),
      ),
      backgroundColor: Color(0xFF10201B),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

void handleLightboxBookTheme(
  BuildContext context,
  GalleryItem item,
  Experience? matchedExp,
) {
  Navigator.of(context).pop();
  final targetExp = matchedExp ?? createFallbackGalleryExperience(item);
  showCustomerBookingDialog(
    context,
    experience: targetExp,
    selectedPackage: targetExp.dynamicPackages.first,
  );
}

void handleLightboxViewDetails(
  BuildContext context,
  GalleryItem item,
  Experience? matchedExp,
) {
  Navigator.of(context).pop();
  if (matchedExp != null && matchedExp.slug.isNotEmpty) {
    Get.toNamed('${AppRoutes.detail}/${matchedExp.slug}');
  } else {
    showExperienceDetailDialog(
      context,
      matchedExp ?? createFallbackGalleryExperience(item),
    );
  }
}

void scrollThumbStripTo(ScrollController ctrl, int index) {
  if (!ctrl.hasClients) return;
  const itemWidth = 72.0;
  final targetOffset = (index * itemWidth) - 140;
  ctrl.animateTo(
    targetOffset.clamp(0.0, ctrl.position.maxScrollExtent),
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );
}

void handleLightboxKeyEvent(
  KeyEvent event, {
  required VoidCallback onNext,
  required VoidCallback onPrev,
  required VoidCallback onClose,
}) {
  if (event is KeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      onNext();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onPrev();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      onClose();
    }
  }
}

